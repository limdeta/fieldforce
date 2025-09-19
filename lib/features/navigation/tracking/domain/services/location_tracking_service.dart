import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
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
  static final Logger _logger = Logger('LocationTrackingService');
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
  
  Stream<CompactTrack> get liveBufferStream => _trackManager.liveBufferStream;
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
      // Ошибка проверки разрешений
      return false;
    }
  }
  
  /// Единый метод запуска трекинга - TrackManager сам определит нужно ли создавать новый трек или продолжать существующий
  @override
  Future<bool> startTracking(NavigationUser user) async {
    try {
      if (isTracking) {
        // Трекинг уже запущен
        return false;
      }

      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        // Нет разрешений на геолокацию
        return false;
      }


      final success = await _trackManager.startTracking(user: user);

      if (!success) {
        // Не удалось запустить трек менеджер
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

      final gpsStarted = await _gpsDataManager.startGps();
      if (!gpsStarted) {
        // Не удалось запустить GPS источник данных
        return false;
      }

      _positionSubscription = _gpsDataManager.getPositionStream(
        settings: _locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);

      final trackId = _trackManager.currentTrackForUI?.id;
      if (trackId != null) {
        // Продолжение трекинга для трека
      } else {
        // Трекинг запущен для пользователя
      }
      return true;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Автоматический запуск трекинга - упрощенная версия, просто вызывает startTracking
  @override
  Future<bool> autoStartTracking({required NavigationUser user}) async {
    final currentSession = AppSessionService.currentSession;
    if (currentSession?.appUser.employee != null) {
      currentSession!.appUser.employee.id;
    }

    return await startTracking(user);
  }

  @override
  Future<bool> stopTracking() async {
    try {
      await _positionSubscription?.cancel();
        // Продолжение трекинга для трека

      if (_trackManager.currentTrackForUI != null) {
        await _trackManager.stopTracking();
      }
      
      _isActive = false;
      _trackingStateController.add(false);
      _pauseStateController.add(false);
      return true;
      
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> pauseTracking() async {
    try {
      if (!isActive) {
        return false;
      }
      
      await _trackManager.pauseTracking();
      
      _isActive = false;
      _pauseStateController.add(true);

      return true;
    } catch (e) {
      _logger.warning('Ошибка паузы трекинга: $e');
      return false;
    }
  }


  @override
  Future<bool> resumeTracking() async {
    try {
      if (!isPaused) {
        return false;
      }
      
      await _trackManager.resumeTracking();
      
      _isActive = true;
      _pauseStateController.add(false);
      
      return true;
    } catch (e) {
      _logger.warning('Ошибка возобновления трекинга: $e');
      return false;
    }
  }

  /// Обработчик новой позиции GPS
  void _onPositionUpdate(Position position) {
    try {
      if (!_isValidPosition(position)) {
        _logger.warning('Позиция отфильтрована как невалидная (точность: ${position.accuracy})');
        return;
      }
      
      // Проверяем минимальное расстояние
      if (!_shouldRecordPosition(position)) {
        _logger.info('Позиция отфильтрована по минимальному расстоянию');
        return;
      }

      // Добавляем точку в track manager (он использует буферизацию)
      if (_isActive) {
        _trackManager.addGpsPoint(position);
      } else {
        _logger.warning('Трекинг неактивен - НЕ добавляем точку в TrackManager');
      }

      _lastPosition = position;

      // Проверяем стационарность
      _checkStationaryState(position);
      
      // Отправляем позицию в стрим для UI
      _positionController.add(position);
      
    } catch (e) {
      _logger.severe('Ошибка обработки позиции: $e');
    }
  }

  /// Обработчик ошибок GPS
  void _onPositionError(dynamic error) {
    _logger.severe('Ошибка GPS: $error');
  }

  bool _isValidPosition(Position position) {
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

    _logger.info("Последняя позиция установлена: $lat, $lng");
  }

  void dispose() {
    _positionSubscription?.cancel();
    _trackManager.dispose();
    _positionController.close();
    _trackingStateController.close();
    _pauseStateController.close();
  }
}
