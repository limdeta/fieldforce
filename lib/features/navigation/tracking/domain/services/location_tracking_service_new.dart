import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import '../entities/user_track.dart';
import '../enums/track_status.dart';
import '../repositories/user_track_repository.dart';
import 'gps_data_manager.dart';
import 'optimized_track_manager.dart';
import 'package:fieldforce/app/services/app_session_service.dart';

/// Высокопроизводительный сервис GPS трекинга с буферизацией
/// 
/// Новая архитектура:
/// - GpsBuffer: буферизация точек в памяти
/// - OptimizedTrackManager: управление треками с batch записью
/// - Разделение UI и persistence слоёв
/// - Оптимизация для real-time обновлений
class LocationTrackingService {
  static const String _tag = 'LocationTracking';
  
  late final OptimizedTrackManager _trackManager;
  StreamSubscription<Position>? _positionSubscription;
  
  final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
      
  final StreamController<bool> _trackingStateController = 
      StreamController<bool>.broadcast();
      
  final StreamController<bool> _pauseStateController = 
      StreamController<bool>.broadcast();
  
  Position? _lastPosition;
  bool _isActive = false;
  int _stationaryCount = 0;

  // GPS менеджер для управления источниками данных
  final GpsDataManager _gpsManager = GpsDataManager();
  
  // Репозиторий для работы с треками
  final UserTrackRepository _trackRepository = GetIt.instance<UserTrackRepository>();
  
  // Настройки трекинга
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // минимальное расстояние между точками в метрах
  );
  
  // Настройки фильтрации
  static const double _minAccuracy = 20.0; // метры
  static const double _maxSpeed = 150.0; // км/ч - максимальная разумная скорость
  static const int _stationaryThreshold = 5; // количество статичных точек для паузы
  static const double _minDistanceMeters = 5.0; // минимальное расстояние между точками

  LocationTrackingService() {
    // Инициализируем OptimizedTrackManager
    _trackManager = OptimizedTrackManager(_trackRepository);
    
    // Инициализируем GPS менеджер с реальным GPS по умолчанию
    _gpsManager.initialize(mode: GpsMode.real);
    
    // Отправляем начальные состояния
    _trackingStateController.add(false);
    _pauseStateController.add(false);
  }

  /// Стримы для подписки на обновления
  Stream<Position> get positionStream => _positionController.stream;
  Stream<UserTrack> get trackUpdateStream => _trackManager.trackUpdateStream;
  Stream<bool> get trackingStateStream => _trackingStateController.stream;
  Stream<bool> get pauseStateStream => _pauseStateController.stream;
  
  /// Текущее состояние
  UserTrack? get currentTrack => _trackManager.currentTrackForUI;
  bool get isTracking => _positionSubscription != null;
  bool get isActive => _isActive;
  bool get isPaused => isTracking && !_isActive;
  
  /// Проверяет разрешения на геолокацию
  Future<bool> checkPermissions() async {
    try {
      return await _gpsManager.checkPermissions();
    } catch (e) {
      debugPrint('$_tag: Ошибка проверки разрешений: $e');
      return false;
    }
  }
  
  /// Начинает новый трек
  Future<bool> startTracking({required NavigationUser user, String? routeId}) async {
    try {
      if (isTracking) {
        debugPrint('$_tag: Трекинг уже запущен');
        return false;
      }
      
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        debugPrint('$_tag: Нет разрешений на геолокацию');
        return false;
      }

      // Начинаем трекинг через OptimizedTrackManager
      final success = await _trackManager.startTracking(
        user: user,
        routeId: routeId,
      );
      
      if (!success) {
        debugPrint('$_tag: Не удалось запустить трек менеджер');
        return false;
      }
      
      _isActive = true;
      _trackingStateController.add(true);
      
      _lastPosition = null;
      _stationaryCount = 0;
      
      // Запускаем подписку на GPS
      _positionSubscription = _gpsManager.getPositionStream(
        settings: _locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);
      
      debugPrint('$_tag: Трекинг запущен для пользователя ${user.id}');
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка запуска трекинга: $e');
      return false;
    }
  }
  
  /// Продолжает существующий трек
  Future<bool> continueTracking({required UserTrack existingTrack, String? routeId}) async {
    try {
      if (isTracking) {
        debugPrint('$_tag: Трекинг уже запущен');
        return false;
      }
      
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        debugPrint('$_tag: Нет разрешений на геолокацию');
        return false;
      }

      // Продолжаем трек через OptimizedTrackManager
      final success = await _trackManager.continueTracking(existingTrack);
      
      if (!success) {
        debugPrint('$_tag: Не удалось продолжить трек');
        return false;
      }
      
      _isActive = true;
      _trackingStateController.add(true);
      
      // Устанавливаем последнюю позицию из существующего трека
      _setLastPositionFromTrack(existingTrack);
      _stationaryCount = 0;
      
      // Запускаем подписку на GPS
      _positionSubscription = _gpsManager.getPositionStream(
        settings: _locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);
      
      debugPrint('$_tag: Продолжение трекинга для трека ${existingTrack.id}');
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка продолжения трекинга: $e');
      return false;
    }
  }

  /// Останавливает трекинг
  Future<bool> stopTracking() async {
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      
      if (_trackManager.currentTrackForUI != null) {
        await _trackManager.stopTracking();
      }
      
      _isActive = false;
      _trackingStateController.add(false);
      _pauseStateController.add(false);
      
      debugPrint('$_tag: Трекинг остановлен');
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка остановки трекинга: $e');
      return false;
    }
  }

  /// Ставит трекинг на паузу
  Future<bool> pauseTracking() async {
    try {
      if (!isActive) {
        debugPrint('$_tag: Трекинг не активен');
        return false;
      }
      
      await _trackManager.pauseTracking();
      
      _isActive = false;
      _pauseStateController.add(true);
      
      debugPrint('$_tag: Трекинг поставлен на паузу');
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка паузы трекинга: $e');
      return false;
    }
  }

  /// Возобновляет трекинг после паузы
  Future<bool> resumeTracking() async {
    try {
      if (!isPaused) {
        debugPrint('$_tag: Трекинг не на паузе');
        return false;
      }
      
      await _trackManager.resumeTracking();
      
      _isActive = true;
      _pauseStateController.add(false);
      
      debugPrint('$_tag: Трекинг возобновлён');
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка возобновления трекинга: $e');
      return false;
    }
  }

  /// Автоматический запуск трекинга с поиском существующих треков
  Future<bool> autoStartTracking({required NavigationUser user, String? routeId}) async {
    try {
      if (isTracking) {
        debugPrint('$_tag: Трекинг уже запущен');
        return false;
      }

      debugPrint('$_tag: Автозапуск трекинга для пользователя ${user.id}');

      // Получаем ID пользователя
      final currentSession = AppSessionService.currentSession;
      if (currentSession?.appUser.employee == null) {
        debugPrint('$_tag: Не удалось получить ID пользователя');
        return false;
      }

      final userId = currentSession!.appUser.employee.id;
      debugPrint('✅ Получен внутренний ID из AppUser.employee: $userId');

      // Ищем треки за сегодня
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final tracksResult = await _trackRepository.getUserTracksByDateRange(
        user, startOfDay, endOfDay
      );

      if (tracksResult.isLeft()) {
        debugPrint('$_tag: Создаем новый трек с route_id: $routeId');
        return await startTracking(user: user, routeId: routeId);
      }

      final tracks = tracksResult.getOrElse(() => []);
      
      // Ищем завершенный трек за сегодня для продолжения
      final completedTrack = tracks.where((track) => track.status == TrackStatus.completed).firstOrNull;
      
      if (completedTrack != null) {
        debugPrint('$_tag: ПРОДОЛЖАЕМ пройденную часть трека (ID: ${completedTrack.id}, ${completedTrack.totalPoints} точек)');
        
        // Меняем статус на active и продолжаем трекинг
        final trackToContinue = completedTrack.copyWith(
          status: TrackStatus.active,
          endTime: null, // убираем время завершения
        );
        
        return await continueTracking(existingTrack: trackToContinue, routeId: routeId);
      }

      // Создаем новый трек с route_id
      debugPrint('$_tag: Создаем новый трек с route_id: $routeId');
      return await startTracking(user: user, routeId: routeId);

    } catch (e) {
      debugPrint('$_tag: Ошибка автозапуска трекинга: $e');
      return false;
    }
  }
  
  /// Обработчик новой позиции GPS
  void _onPositionUpdate(Position position) {
    try {
      // Фильтруем некачественные точки
      if (!_isValidPosition(position)) {
        return;
      }
      
      // Проверяем минимальное расстояние
      if (!_shouldRecordPosition(position)) {
        return;
      }
      
      // Добавляем точку в track manager (он использует буферизацию)
      if (_isActive) {
        _trackManager.addGpsPoint(position);
      }
      
      _lastPosition = position;
      
      // Проверяем стационарность
      _checkStationaryState(position);
      
      // Отправляем позицию в стрим
      _positionController.add(position);
      
    } catch (e) {
      debugPrint('$_tag: Ошибка обработки позиции: $e');
    }
  }
  
  /// Обработчик ошибок GPS
  void _onPositionError(dynamic error) {
    debugPrint('$_tag: Ошибка GPS: $error');
  }
  
  /// Проверяет валидность GPS позиции
  bool _isValidPosition(Position position) {
    // Проверяем точность
    if (position.accuracy > _minAccuracy) {
      return false;
    }
    
    // Проверяем скорость (фильтруем аномально высокие скорости)
    final speedKmh = position.speed * 3.6;
    if (speedKmh > _maxSpeed) {
      return false;
    }
    
    return true;
  }
  
  /// Определяет, нужно ли записывать позицию
  bool _shouldRecordPosition(Position position) {
    if (_lastPosition == null) return true;
    
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );
    
    return distance >= _minDistanceMeters;
  }
  
  /// Проверяет стационарность
  void _checkStationaryState(Position position) {
    if (_lastPosition == null) return;
    
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );
    
    if (distance < _minDistanceMeters) {
      _stationaryCount++;
    } else {
      _stationaryCount = 0;
    }
    
    // Автоматическая пауза при длительной стационарности (только для реального GPS)
    if (_stationaryCount >= _stationaryThreshold && _isActive && _gpsManager.currentMode == GpsMode.real) {
      pauseTracking();
    }
  }

  /// Устанавливает последнюю позицию из существующего трека
  void _setLastPositionFromTrack(UserTrack track) {
    if (track.segments.isEmpty) return;
    
    final lastSegment = track.segments.last;
    if (lastSegment.pointCount == 0) return;
    
    final lastIndex = lastSegment.pointCount - 1;
    final (lat, lng) = lastSegment.getCoordinates(lastIndex);
    final timestamp = lastSegment.getTimestamp(lastIndex);
    
    _lastPosition = Position(
      latitude: lat,
      longitude: lng,
      timestamp: timestamp,
      accuracy: lastSegment.getAccuracy(lastIndex) ?? 5.0,
      altitude: 0.0,
      altitudeAccuracy: 10.0,
      heading: lastSegment.getBearing(lastIndex) ?? 0.0,
      headingAccuracy: 15.0,
      speed: (lastSegment.getSpeed(lastIndex) ?? 30.0) / 3.6, // км/ч -> м/с
      speedAccuracy: 2.0,
    );
    
    debugPrint('$_tag: Последняя позиция установлена: $lat, $lng');
  }

  /// Освобождает ресурсы
  void dispose() {
    _positionSubscription?.cancel();
    _trackManager.dispose();
    _positionController.close();
    _trackingStateController.close();
    _pauseStateController.close();
  }
}
