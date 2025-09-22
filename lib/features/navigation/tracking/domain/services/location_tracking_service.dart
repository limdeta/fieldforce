import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
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
  StreamSubscription<UserTrack>? _trackUpdateSubscription; // Добавлено для подписки на TrackManager
  
  final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
      
  final StreamController<bool> _trackingStateController = 
      StreamController<bool>.broadcast();
      
  final StreamController<bool> _pauseStateController = 
      StreamController<bool>.broadcast();
      
  // Стрим для частых обновлений UI с полным состоянием трека (включая буфер)
  final StreamController<UserTrack> _liveTrackUpdateController = 
      StreamController<UserTrack>.broadcast();
  
  Position? _lastPosition;
  bool _isActive = false;
  int _stationaryCount = 0;

  // Настройки трекинга
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // минимальное расстояние между точками в метрах
  );
  
  // Настройки фильтрации
  static const double _minAccuracy = 20.0;
  static const double _maxSpeed = 150.0; // км/ч - максимальная разумная скорость
  static const int _stationaryThreshold = 50; // количество статичных точек для паузы (увеличено чтобы не прерывать трекинг)
  static const double _minDistanceMeters = 5.0; // минимальное расстояние между точками

  LocationTrackingService(this._gpsDataManager, this._trackManager) {
    _logger.fine('🏗️ LocationTrackingService: получили TrackManager из DI');
    _trackingStateController.add(false);
    _pauseStateController.add(false);
    
    // КРИТИЧНО: Подписываемся на обновления от TrackManager и пересылаем их в UI
    _trackUpdateSubscription = _trackManager.trackUpdateStream.listen((track) {
      _logger.fine('🔄 LocationTrackingService: получено обновление от TrackManager');
      _logger.fine('   📊 Трек ID: ${track.id}, сегментов: ${track.segments.length}, точек: ${track.totalPoints}');
      _logger.fine('    Детали сегментов:');
      for (int i = 0; i < track.segments.length; i++) {
        final segment = track.segments[i];
        _logger.fine('      segment[$i]: ${segment.pointCount} точек');
      }
      
      if (!_liveTrackUpdateController.isClosed) {
        _liveTrackUpdateController.add(track);
        _logger.fine('✅ LocationTrackingService: трек переслан в UI стримы');
      } else {
        _logger.warning('❌ LocationTrackingService: _liveTrackUpdateController закрыт!');
      }
    }, onError: (error) {
      _logger.severe('❌ LocationTrackingService: ошибка в trackUpdateStream от TrackManager: $error');
    });
  }

  /// Стримы для подписки на обновлени��
  Stream<Position> get positionStream => _positionController.stream;
  @override
  Stream<UserTrack> get trackUpdateStream => _liveTrackUpdateController.stream;
  
  Stream<CompactTrack> get liveBufferStream => _trackManager.liveBufferStream;
  Stream<bool> get trackingStateStream => _trackingStateController.stream;
  Stream<bool> get pauseStateStream => _pauseStateController.stream;
  
  /// Текущее состояние
  Stream<UserTrack?> get currentTrackStream => _trackManager.trackUpdateStream;
  UserTrack? get currentTrack => _trackManager.currentTrackForUI;
  @override
  bool get isTracking => _positionSubscription != null && _isActive;
  bool get isActive => _isActive;
  bool get isPaused => _positionSubscription != null && !_isActive;
  
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
      _logger.info('🎯 Запуск трекинга для пользователя: ${user.fullName} (ID: ${user.id})');
      
      if (isTracking) {
        _logger.warning('⚠️ Трекинг уже запущен, возвращаем false');
        return false;
      }

      _logger.info('🔐 Проверяем разрешения GPS...');
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        _logger.severe('❌ Нет разрешений на геолокацию');
        return false;
      }
      _logger.info('✅ Разрешения GPS получены');

      _logger.info('🏃 Запускаем TrackManager...');
      final success = await _trackManager.startTracking(user: user);

      if (!success) {
        _logger.severe('❌ Не удалось запустить TrackManager');
        return false;
      }
      _logger.info('✅ TrackManager успешно запущен');
      
      _isActive = true;
      _trackingStateController.add(true);
      
      _lastPosition = null;
      _stationaryCount = 0;
      
      // Устанавливаем последнюю позицию из трека если он существует
      final currentTrack = _trackManager.currentTrackForUI;
      if (currentTrack != null && currentTrack.isNotEmpty) {
        _setLastPositionFromTrack(currentTrack);
        _logger.info('📍 Восстановлена последняя позиция из существующего трека');
      }

      _logger.info('🛰️ Запускаем GPS источник данных...');
      final gpsStarted = await _gpsDataManager.startGps();
      if (!gpsStarted) {
        _logger.severe('❌ Не удалось запустить GPS источник данных');
        return false;
      }
      _logger.info('✅ GPS источник данных запущен');

      _logger.info('🔄 Подписываемся на поток GPS позиций...');
      _positionSubscription = _gpsDataManager.getPositionStream(
        settings: _locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);

      final trackId = _trackManager.currentTrackForUI?.id;
      if (trackId != null) {
        _logger.info('🔄 Продолжение трекинга для трека ID: $trackId');
        // КРИТИЧНО: Эмитируем текущий трек сразу при старте трекинга
        final currentTrack = _trackManager.currentTrackForUI;
        if (currentTrack != null && !_liveTrackUpdateController.isClosed) {
          _liveTrackUpdateController.add(currentTrack);
          _logger.info('📡 Инициальная эмиссия трека ID: $trackId для UI');
        }
      } else {
        _logger.info('🆕 Трекинг запущен для нового пользователя');
      }
      
      _logger.info('🎉 Трекинг успешно запущен!');
      return true;
      
    } catch (e, st) {
      _logger.severe('💥 Ошибка запуска трекинга', e, st);
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
      _logger.info('📍 LocationTrackingService.onPositionUpdate: ${position.latitude}, ${position.longitude} (точность: ${position.accuracy}m)');
      
      if (!_isValidPosition(position)) {
        _logger.warning('⚠️ Позиция отфильтрована как невалидная (точность: ${position.accuracy})');
        return;
      }
      
      // Проверяем минимальное расстояние
      if (!_shouldRecordPosition(position)) {
        double distance = 0.0;
        if (_lastPosition != null) {
          distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
        }
        _logger.info('📏 Позиция отфильтрована по минимальному расстоянию: ${distance.toStringAsFixed(1)}m < $_minDistanceMeters');
        return;
      }

      // Добавляем точку в track manager (он использует буферизацию)
      if (_isActive) {
        _logger.info('📍 LocationTrackingService: передаем точку в TrackManager (_isActive=true)');
        _trackManager.addGpsPoint(position);
        _logger.info('✅ Точка передана в TrackManager');
        
        // КРИТИЧНО: Эмитируем полное состояние трека (включая буфер) в UI
        final currentTrack = _trackManager.currentTrackForUI;
        if (currentTrack != null) {
          _logger.fine('📡 Эмитируем полное состояние трека с буфером в liveTrackUpdateController');
          if (!_liveTrackUpdateController.isClosed) {
            _liveTrackUpdateController.add(currentTrack);
          }
        }
      } else {
        _logger.warning('⚠️ LocationTrackingService: трекинг неактивен (_isActive=false) - НЕ добавляем точку в TrackManager');
      }

      _lastPosition = position;

      // Проверяем стационарность
      _checkStationaryState(position);
      
      // Отправляем позицию в стрим для UI
      _positionController.add(position);
      _logger.fine('📡 Позиция отправлена в UI стрим');
      
    } catch (e, st) {
      _logger.severe('💥 Ошибка обработки позиции', e, st);
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
    _trackUpdateSubscription?.cancel(); // Добавлено
    _trackManager.dispose();
    _positionController.close();
    _trackingStateController.close();
    _pauseStateController.close();
    _liveTrackUpdateController.close();
  }
}
