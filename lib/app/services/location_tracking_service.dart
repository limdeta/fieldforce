import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import '../../features/navigation/tracking/domain/entities/user_track.dart';
import '../../features/navigation/tracking/domain/services/optimized_track_manager.dart';
import '../../features/navigation/tracking/domain/repositories/user_track_repository.dart';
import '../../features/navigation/tracking/domain/entities/navigation_user.dart';
import '../../features/navigation/tracking/domain/services/mock_gps_data_source.dart';
import 'app_session_service.dart';

/// LocationTrackingService на уровне приложения
/// 
/// Интегрирует GPS трекинг с AppSessionService для получения текущего пользователя
/// Использует новую архитектуру с буферизацией и оптимизированным управлением треками
class LocationTrackingService {
  static const String _tag = '[LocationTrackingService]';
  
  // GPS и управление треками
  late final OptimizedTrackManager _trackManager;
  final MockGpsDataSource _gpsManager = MockGpsDataSource();
  final UserTrackRepository _trackRepository = GetIt.instance<UserTrackRepository>();
  
  // Стримы
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  final StreamController<bool> _trackingStateController = StreamController<bool>.broadcast();
  final StreamController<bool> _pauseStateController = StreamController<bool>.broadcast();
  
  // Состояние
  StreamSubscription<Position>? _positionSubscription;
  bool _isActive = false;
  
  // Настройки фильтрации
  static const double _minAccuracy = 20.0; // метры
  static const double _maxSpeed = 150.0; // км/ч - максимальная разумная скорость

  LocationTrackingService() {
    // Инициализируем OptimizedTrackManager
    _trackManager = OptimizedTrackManager(_trackRepository);
    
    // Загружаем mock GPS данные
    _gpsManager.loadRoute('assets/data/tracks/continuation_scenario.json');
    
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

  /// Получает текущего пользователя из AppSessionService
  NavigationUser? _getCurrentUser() {
    final session = AppSessionService.currentSession;
    return session?.appUser;
  }

  /// Запуск GPS трекинга
  Future<bool> startTracking() async {
    try {
      final currentUser = _getCurrentUser();
      if (currentUser == null) {
        debugPrint('$_tag: Пользователь не найден в сессии');
        return false;
      }

      if (isTracking) {
        debugPrint('$_tag: Трекинг уже запущен');
        return false;
      }

      debugPrint('$_tag: Запуск трекинга для пользователя ${currentUser.fullName}');

      // Для mock GPS всегда разрешаем доступ
      debugPrint('$_tag: Используем mock GPS - разрешения не требуются');

      // Пытаемся продолжить существующий трек или создать новый
      final tracksResult = await _trackRepository.getUserTracks(currentUser);
      final todayTracks = await tracksResult.fold(
        (failure) async => <UserTrack>[],
        (tracks) async {
          final today = DateTime.now();
          final startOfDay = DateTime(today.year, today.month, today.day);
          return tracks.where((track) {
            return track.startTime.isAfter(startOfDay) && 
                   track.startTime.isBefore(startOfDay.add(const Duration(days: 1)));
          }).toList();
        },
      );

      // Ищем активный трек для продолжения
      final activeTrack = todayTracks.where((t) => t.status.isActive).firstOrNull;
      if (activeTrack != null) {
        await _trackManager.continueTracking(activeTrack);
      } else {
        await _trackManager.startTracking(user: currentUser);
      }

      // Запускаем GPS поток
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Получаем все обновления, фильтрация в _processGpsPoint
      );

      _positionSubscription = _gpsManager.getPositionStream(settings: locationSettings)
          .listen(_processGpsPoint, onError: _handleGpsError);

      _isActive = true;
      _trackingStateController.add(true);
      _pauseStateController.add(false);

      debugPrint('$_tag: ✅ Трекинг запущен успешно');
      return true;

    } catch (e) {
      debugPrint('$_tag: ❌ Ошибка запуска трекинга: $e');
      return false;
    }
  }

  /// Остановка GPS трекинга
  Future<void> stopTracking() async {
    debugPrint('$_tag: Остановка трекинга');

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isActive = false;

    // Финализируем трек
    await _trackManager.stopTracking();

    _trackingStateController.add(false);
    _pauseStateController.add(false);

    debugPrint('$_tag: ✅ Трекинг остановлен');
  }

  /// Пауза трекинга (GPS продолжает работать, но точки не записываются)
  void pauseTracking() {
    if (!isTracking) return;
    
    _isActive = false;
    _pauseStateController.add(true);
    debugPrint('$_tag: Трекинг приостановлен');
  }

  /// Возобновление трекинга
  void resumeTracking() {
    if (!isTracking) return;
    
    _isActive = true;
    _pauseStateController.add(false);
    debugPrint('$_tag: Трекинг возобновлен');
  }

  /// Обработка новой GPS точки
  void _processGpsPoint(Position position) {
    if (!_isActive) return; // Если на паузе, пропускаем

    // Фильтрация по точности
    if (position.accuracy > _minAccuracy) {
      debugPrint('$_tag: Точка отфильтрована по точности: ${position.accuracy}m');
      return;
    }

    // Фильтрация по скорости (если доступна)
    if (position.speed > _maxSpeed / 3.6) { // км/ч в м/с
      debugPrint('$_tag: Точка отфильтрована по скорости: ${position.speed * 3.6}км/ч');
      return;
    }

    // Отправляем в буфер через TrackManager
    _trackManager.addGpsPoint(position);
    
    // Отправляем в position stream для UI
    _positionController.add(position);
  }

  /// Обработка ошибок GPS
  void _handleGpsError(dynamic error) {
    debugPrint('$_tag: ❌ Ошибка GPS: $error');
  }

  /// Освобождение ресурсов
  void dispose() {
    _positionSubscription?.cancel();
    _positionController.close();
    _trackingStateController.close();
    _pauseStateController.close();
    _trackManager.dispose();
    debugPrint('$_tag: Ресурсы освобождены');
  }

  // === Методы совместимости с TrackFixtures ===
  
  /// Включает тестовый режим с мок данными
  Future<void> enableTestMode({Map<String, dynamic>? config}) async {
    debugPrint('$_tag: Включение тестового режима');
    // Мок GPS уже используется по умолчанию
    if (config != null) {
      final startProgress = config['startProgress'] as double? ?? 0.0;
      _gpsManager.setProgress(startProgress);
    }
  }

  /// Включает демо режим (быстрое воспроизведение)
  Future<void> enableDemoMode() async {
    debugPrint('$_tag: Включение демо режима');
    // Можно увеличить скорость воспроизведения
  }

  /// Включает реальный GPS
  Future<void> enableRealGps() async {
    debugPrint('$_tag: Переключение на реальный GPS');
    // В будущем можно переключиться на RealGpsDataSource
  }

  /// Автоматический запуск трекинга (совместимость)
  Future<bool> autoStartTracking({String? routeId}) async {
    return await startTracking();
  }

  /// Получает информацию о GPS
  String getGpsInfo() {
    return 'Mock GPS (${_gpsManager.runtimeType})';
  }

  /// Получает информацию о воспроизведении мок данных
  Map<String, dynamic> getMockPlaybackInfo() {
    return {
      'isActive': isTracking,
      'isPaused': isPaused,
      'source': 'MockGpsDataSource',
    };
  }
}
