import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import '../entities/user_track.dart';
import '../enums/track_status.dart';
import '../repositories/user_track_repository.dart';
import 'gps_data_manager.dart';
import 'track_manager.dart';
import 'package:fieldforce/app/services/app_session_service.dart';

/// Высокопроизводительный сервис GPS трекинга с буферизацией
/// 
/// Новая архитектура:
/// - GpsBuffer: буферизация точек в памяти
/// - OptimizedTrackManager: управление треками с batch записью
/// - Разделение UI и persistence слоёв
/// - Оптимизация для real-time обновлений
class LocationTrackingService implements LocationTrackingServiceBase  {
  static const String _tag = 'LocationTracking';
  final GpsDataManager _gpsDataManager;
  late final TrackManager _trackManager;
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

  final UserTrackRepository _trackRepository = GetIt.instance<UserTrackRepository>();
  
  // Настройки трекинга
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // минимальное расстояние между точками в метрах
  );
  
  // Настройки фильтрации
  static const double _minAccuracy = 20.0;
  static const double _maxSpeed = 150.0; // км/ч - максимальная разумная скорость
  static const int _stationaryThreshold = 5; // количество статичных точек для паузы
  static const double _minDistanceMeters = 5.0; // минимальное расстояние между точками

  LocationTrackingService(this._gpsDataManager) {
    _trackManager = TrackManager(_trackRepository);
    _trackingStateController.add(false);
    _pauseStateController.add(false);
  }

  /// Стримы для подписки на обновлени��
  Stream<Position> get positionStream => _positionController.stream;
  @override
  Stream<UserTrack> get trackUpdateStream => _trackManager.trackUpdateStream;
  Stream<bool> get trackingStateStream => _trackingStateController.stream;
  Stream<bool> get pauseStateStream => _pauseStateController.stream;
  
  /// Текущее состояние
  Stream<UserTrack?> get currentTrackStream => _trackManager.trackUpdateStream;
  UserTrack? get currentTrack => _trackManager.currentTrackForUI;
  @override
  bool get isTracking => _positionSubscription != null;
  bool get isActive => _isActive;
  bool get isPaused => isTracking && !_isActive;
  
  /// Проверяет разрешения на геолокацию
  Future<bool> checkPermissions() async {
    try {
      return await _gpsDataManager.checkPermissions();
    } catch (e) {
      print('$_tag: Ошибка проверки разрешений: $e');
      return false;
    }
  }
  
  /// Единый метод запуска трекинга - TrackManager сам определит нужно ли создавать новый трек или продолжать существующий
  @override
  Future<bool> startTracking(NavigationUser user) async {
    try {
      if (isTracking) {
        print('$_tag: Трекинг уже запущен');
        return false;
      }

      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        print('$_tag: Нет разрешений на геолокацию');
        return false;
      }


      final success = await _trackManager.startTracking(user: user);

      if (!success) {
        print('$_tag: Не удалось запустить трек менеджер');
        return false;
      }
      
      _isActive = true;
      _trackingStateController.add(true);
      
      _lastPosition = null;
      _stationaryCount = 0;
      
      // Устанавливаем последнюю позицию из трека если он существует
      final currentTrack = _trackManager.currentTrackForUI;
      if (currentTrack != null && currentTrack.isNotEmpty) {
        _setLastPositionFromTrack(currentTrack);
      }

      // Запускаем GPS источник данных
      print('$_tag: 🚀 Запускаем GPS источник данных...');
      final gpsStarted = await _gpsDataManager.startGps();
      if (!gpsStarted) {
        print('$_tag: ❌ Не удалось запустить GPS источник данных');
        return false;
      }
      print('$_tag: ✅ GPS источник данных запущен');

      // Запускаем подписку на GPS
      print('$_tag: 📡 Создаем подписку на GPS поток...');
      _positionSubscription = _gpsDataManager.getPositionStream(
        settings: _locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);
      print('$_tag: ✅ Подписка на GPS поток создана');

      final trackId = _trackManager.currentTrackForUI?.id;
      if (trackId != null) {
        print('$_tag: Продолжение трекинга для трека $trackId');
      } else {
        print('$_tag: Трекинг запущен для пользователя ${user.id}');
      }
      return true;
      
    } catch (e) {
      print('$_tag: Ошибка запуска трекинга: $e');
      return false;
    }
  }
  
  /// Автоматический запуск трекинга - упрощенная версия, просто вызывает startTracking
  @override
  Future<bool> autoStartTracking({required NavigationUser user}) async {
    print('$_tag: Автозапуск трекинга для пользователя ${user.id}');

    // Получаем ID пользователя для логирования
    final currentSession = AppSessionService.currentSession;
    if (currentSession?.appUser.employee != null) {
      final userId = currentSession!.appUser.employee.id;
      print('✅ Получен внутренний ID из AppUser.employee: $userId');
    }

    // Вся логика поиска существующих треков теперь в TrackManager.startTracking
    return await startTracking(user);
  }

  /// Останавливает трекинг
  @override
  Future<bool> stopTracking() async {
    try {
      await _positionSubscription?.cancel();
      print('$_tag: Продолжение трек��нга для трека');

      if (_trackManager.currentTrackForUI != null) {
        await _trackManager.stopTracking();
      }
      
      _isActive = false;
      _trackingStateController.add(false);
      _pauseStateController.add(false);
      
      print('$_tag: Трекинг остановлен');
      return true;
      
    } catch (e) {
      print('$_tag: Ошибка остановки трекинга: $e');
      return false;
    }
  }

  /// Ставит трекинг на паузу
  @override
  Future<bool> pauseTracking() async {
    try {
      if (!isActive) {
        print('$_tag: Трекинг не активен');
        return false;
      }
      
      await _trackManager.pauseTracking();
      
      _isActive = false;
      _pauseStateController.add(true);
      
      print('$_tag: Трекинг поставлен на паузу');
      return true;
      
    } catch (e) {
      print('$_tag: О��ибка паузы трекинга: $e');
      return false;
    }
  }

  /// Возобновляет трекинг после паузы
  @override
  Future<bool> resumeTracking() async {
    try {
      if (!isPaused) {
        print('$_tag: Трекинг не на паузе');
        return false;
      }
      
      await _trackManager.resumeTracking();
      
      _isActive = true;
      _pauseStateController.add(false);
      
      print('$_tag: Трекинг возобновлён');
      return true;
      
    } catch (e) {
      print('$_tag: Ошибка возобновления трекинга: $e');
      return false;
    }
  }

  /// Обработчик новой позиции GPS
  void _onPositionUpdate(Position position) {
    try {
      print('$_tag: 🔄 _onPositionUpdate() - обрабатываем позицию ${position.latitude}, ${position.longitude}');

      // Фильтруем некачественные точки
      if (!_isValidPosition(position)) {
        print('$_tag: ❌ Позиция отфильтрована как невалидная (точность: ${position.accuracy})');
        return;
      }
      
      // Проверяем минимальное расстояние
      if (!_shouldRecordPosition(position)) {
        print('$_tag: ❌ Позиция отфильтрована по минимальному расстоянию');
        return;
      }

      print('$_tag: ✅ Позиция прошла фильтры, обрабатываем');

      // Добавляем точку в track manager (он использует буферизацию)
      if (_isActive) {
        print('$_tag: 📊 Добавляем точку в TrackManager');
        _trackManager.addGpsPoint(position);
      } else {
        print('$_tag: ⚠️ Трекинг неактивен - НЕ добавляем точку в TrackManager');
      }

      _lastPosition = position;

      // Проверяем стационарность
      _checkStationaryState(position);
      
      // Отправляем позицию в стрим для UI
      print('$_tag: 📤 Отправляем позицию в UI стрим');
      _positionController.add(position);
      
    } catch (e) {
      print('$_tag: ❌ Ошибка обработки позиции: $e');
    }
  }

  /// Обработчик ошибок GPS
  void _onPositionError(dynamic error) {
    print('$_tag: Ошибка GPS: $error');
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
    if (_stationaryCount >= _stationaryThreshold && _isActive && _gpsDataManager.currentMode == GpsMode.real) {
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

    print('$_tag: Последняя позиция установлена: $lat, $lng');
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
