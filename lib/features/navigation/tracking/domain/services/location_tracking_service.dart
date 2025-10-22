import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/services/device_orientation_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'gps_data_manager.dart';
import 'track_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/track_snapshot.dart';
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
  final DeviceOrientationService _orientationService;
  // Optional injection point for tests: custom position stream provider
  final Stream<Position> Function(LocationSettings settings)? _positionStreamProvider;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<UserTrack>? _trackUpdateSubscription; // Добавлено для подписки на TrackManager
  StreamSubscription<double>? _orientationSubscription;
  
  final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
      
  final StreamController<bool> _trackingStateController = 
      StreamController<bool>.broadcast();
      
  final StreamController<bool> _pauseStateController = 
      StreamController<bool>.broadcast();
      
  // Стрим для частых обновлений UI с полным состоянием трека (включая буфер)
  final StreamController<UserTrack> _liveTrackUpdateController = 
      StreamController<UserTrack>.broadcast();
  UserTrack? _lastEmittedTrack;
  CompactTrack? _lastLiveBuffer;
  
  Position? _lastPosition;
  Position? _lastBroadcastPosition;
  bool _isActive = false;
  int _stationaryCount = 0;
  double? _lastComputedHeading;
  double? _lastCompassHeading;
  DateTime? _lastCompassUiEmission;

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
  static const double _gpsHeadingSpeedThreshold = 1.5; // м/с (~5.4 км/ч)
  static const Duration _compassThrottle = Duration(milliseconds: 120);
  static const double _compassJitterThreshold = 0.3; // градусы
  static const Duration _segmentGapDuration = Duration(seconds: 75);
  static const double _segmentGapDistanceMeters = 500.0;
  static const double _segmentGapDistanceForLongGap = 120.0;
  static const double _segmentBreakMinDistance = 30.0;
  static const double _maxTeleportSpeedMps = 65.0; // ≈234 км/ч

  LocationTrackingService(
    this._gpsDataManager,
    this._trackManager,
    this._orientationService, {
    Stream<Position> Function(LocationSettings settings)? positionStreamProvider,
  }) : _positionStreamProvider = positionStreamProvider {
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
          _lastEmittedTrack = track;
          _logger.fine('✅ LocationTrackingService: трек переслан в UI стримы');
        } else {
        _logger.warning('❌ LocationTrackingService: _liveTrackUpdateController закрыт!');
      }
    }, onError: (error) {
      _logger.severe('❌ LocationTrackingService: ошибка в trackUpdateStream от TrackManager: $error');
    });

    // Подписываемся на live buffer от TrackManager чтобы кешировать последний
    // сегмент буфера — это обеспечивает немедленную реплей-эмиссию для новых
    // подписчиков liveBufferStream.
    _trackManager.liveBufferStream.listen((buffer) {
      try {
        _lastLiveBuffer = buffer;
      } catch (e, st) {
        _logger.warning('Ошибка при кешировании live buffer', e, st);
      }
    }, onError: (error) {
      _logger.warning('Ошибка в liveBufferStream от TrackManager: $error');
    });
  }

  /// Стримы для подписки на обновления
  Stream<Position> get positionStream => Stream<Position>.multi((controller) {
        // replay last known position to late subscribers
        final Position? lastForReplay = _lastBroadcastPosition ?? _lastPosition;
        if (lastForReplay != null) controller.add(lastForReplay);
        final sub = _positionController.stream.listen((p) {
          controller.add(p);
        }, onError: controller.addError, onDone: controller.close);
        controller.onCancel = () {
          sub.cancel();
        };
      });

  @override
  TrackSnapshot getCurrentSnapshot() {
    final persisted = _trackManager.currentTrackForUI;
    final live = _lastLiveBuffer;
    final pos = _lastBroadcastPosition ?? _lastPosition;
    return TrackSnapshot(persistedTrack: persisted, liveBuffer: live, lastPosition: pos);
  }

  @override
  Stream<UserTrack> get trackUpdateStream => Stream<UserTrack>.multi((controller) {
        // replay last emitted track to late subscribers
        if (_lastEmittedTrack != null) {
          controller.add(_lastEmittedTrack!);
        }
        final sub = _liveTrackUpdateController.stream.listen((t) {
          controller.add(t);
        }, onError: controller.addError, onDone: controller.close);
        controller.onCancel = () {
          sub.cancel();
        };
      });
  
  Stream<CompactTrack> get liveBufferStream => Stream<CompactTrack>.multi((controller) {
        // replay last live buffer to late subscribers
        if (_lastLiveBuffer != null) controller.add(_lastLiveBuffer!);
        final sub = _trackManager.liveBufferStream.listen((buffer) {
          // cache latest live buffer for future subscribers
          _lastLiveBuffer = buffer;
          controller.add(buffer);
        }, onError: controller.addError, onDone: controller.close);
        controller.onCancel = () {
          sub.cancel();
        };
      });
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

      await _startOrientationUpdates();

      _logger.info('🔄 Подписываемся на поток GPS позиций...');
      final Stream<Position> posStream = _positionStreamProvider != null
          ? _positionStreamProvider(_locationSettings)
          : _gpsDataManager.getPositionStream(settings: _locationSettings);

      _positionSubscription = posStream.listen((pos) {
        unawaited(_onPositionUpdate(pos));
      }, onError: (error) async {
        _logger.warning('⚠️ LocationTrackingService: позиционный стрим выдал ошибку, пытаемся сохранить буфер: $error');
        try {
          await _trackManager.flushBufferToCurrentTrack();
          _logger.info('✅ Буфер успешно сохранён после ошибки стрима');
        } catch (e, st) {
          _logger.warning('❌ Ошибка при сохранении буфера после ошибки стрима', e, st);
        }
        _onPositionError(error);
      }, onDone: () async {
        _logger.info('ℹ️ LocationTrackingService: позиционный стрим завершился (onDone), сохраняем буфер');
        try {
          await _trackManager.flushBufferToCurrentTrack();
          _logger.info('✅ Буфер успешно сохранён после завершения стрима');
        } catch (e, st) {
          _logger.warning('❌ Ошибка при сохранении буфера после завершения стрима', e, st);
        }
      });

      final trackId = _trackManager.currentTrackForUI?.id;
      if (trackId != null) {
        _logger.info('🔄 Продолжение трекинга для трека ID: $trackId');
        // КРИТИЧНО: Эмитируем текущий трек сразу при старте трекинга
        final currentTrack = _trackManager.currentTrackForUI;
        if (currentTrack != null && !_liveTrackUpdateController.isClosed) {
          _liveTrackUpdateController.add(currentTrack);
          _lastEmittedTrack = currentTrack;
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
      // перед отменой подписки пытаемся сохранить буфер, чтобы не потерять последние точки
      try {
        await _trackManager.flushBufferToCurrentTrack();
      } catch (e, st) {
        _logger.warning('Ошибка при флеше буфера перед stopTracking', e, st);
      }

      await _positionSubscription?.cancel();

      if (_trackManager.currentTrackForUI != null) {
        await _trackManager.stopTracking();
      }

      await _stopOrientationUpdates();
      _resetHeadingState();
      
      _isActive = false;
      _trackingStateController.add(false);
      _pauseStateController.add(false);
      return true;
      
    } catch (e, st) {
      _logger.severe('Ошибка при остановке трекинга', e, st);
      return false;
    }
  }

  @override
  Future<bool> pauseTracking() async {
    try {
      if (!isActive) {
        return false;
      }
      // перед паузой — попытка сохранить текущий буфер чтобы голубой сегмент остался видимым
      try {
        await _trackManager.flushBufferToCurrentTrack();
      } catch (e, st) {
        _logger.warning('Ошибка при флеше буфера перед pauseTracking', e, st);
      }

      await _trackManager.pauseTracking();

  await _stopOrientationUpdates();

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
  await _startOrientationUpdates();
      
      _isActive = true;
      _pauseStateController.add(false);
      
      return true;
    } catch (e) {
      _logger.warning('Ошибка возобновления трекинга: $e');
      return false;
    }
  }

  /// Обработчик новой позиции GPS
  Future<void> _onPositionUpdate(Position position) async {
    final sub = _positionSubscription;
    sub?.pause();

    try {
      _logger.info('📍 LocationTrackingService.onPositionUpdate: ${position.latitude}, ${position.longitude} (точность: ${position.accuracy}m)');

      if (!_isValidPosition(position)) {
        _logger.warning('⚠️ Позиция отфильтрована как невалидная (точность: ${position.accuracy})');
        return;
      }

  double fusedHeading = _fuseHeading(position);
  Position corrected = _copyPositionWithHeading(position, fusedHeading);

      final _SegmentBreakDecision? gapDecision = _detectSegmentBreak(corrected);
      if (gapDecision != null) {
        await _handleSegmentBreak(gapDecision);
        fusedHeading = _fuseHeading(position);
        corrected = _copyPositionWithHeading(position, fusedHeading);
      }

      if (!_shouldRecordPosition(corrected)) {
        double distance = 0.0;
        if (_lastPosition != null) {
          distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            corrected.latitude,
            corrected.longitude,
          );
        }
        _logger.fine('📏 Позиция пропущена по дистанции: ${distance.toStringAsFixed(1)}м < $_minDistanceMeters');

        final Position uiPosition = _copyPositionWithHeading(
          _lastBroadcastPosition ?? corrected,
          fusedHeading,
          timestamp: DateTime.now(),
        );
        _broadcastPosition(uiPosition);
        return;
      }

      if (_isActive) {
        _logger.info('📍 LocationTrackingService: передаем точку в TrackManager (_isActive=true)');
        _trackManager.addGpsPoint(corrected);
        _logger.info('✅ Точка передана в TrackManager');

        final currentTrack = _trackManager.currentTrackForUI;
        if (currentTrack != null && !_liveTrackUpdateController.isClosed) {
          _liveTrackUpdateController.add(currentTrack);
        }
      } else {
        _logger.fine('⚠️ LocationTrackingService: трекинг неактивен (_isActive=false) - точка не сохранена');
      }

      _checkStationaryState(corrected);
      _lastPosition = corrected;
      _broadcastPosition(corrected);
    } catch (e, st) {
      _logger.severe('💥 Ошибка обработки позиции', e, st);
    } finally {
      sub?.resume();
    }
  }

  /// Обработчик ошибок GPS
  void _onPositionError(dynamic error) {
    _logger.severe('Ошибка GPS: $error');

    // При ошибке GPS пробуем сохранить буфер, чтобы не потерять последние точки
    try {
      _trackManager.flushBufferToCurrentTrack();
    } catch (e, st) {
      _logger.warning('Ошибка при флеше буфера в _onPositionError', e, st);
    }
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

  Future<void> _startOrientationUpdates() async {
    await _orientationSubscription?.cancel();
    _orientationSubscription = null;

    try {
      await _orientationService.start();
    } catch (e, st) {
      _logger.warning('Не удалось запустить сервис ориентации', e, st);
    }

    try {
      _orientationSubscription = _orientationService.headingStream.listen(
        _onCompassHeading,
        onError: (error, stackTrace) {
          _logger.warning('Ошибка compass stream', error, stackTrace);
        },
      );
    } catch (e, st) {
      _logger.warning('Не удалось подписаться на compass stream', e, st);
    }
  }

  Future<void> _stopOrientationUpdates() async {
    await _orientationSubscription?.cancel();
    _orientationSubscription = null;
    try {
      await _orientationService.stop();
    } catch (e, st) {
      _logger.warning('Не удалось остановить сервис ориентации', e, st);
    }
  }

  void _onCompassHeading(double heading) {
    final normalized = normalizeHeading(heading);
    _lastCompassHeading = normalized;

    final Position? base = _lastBroadcastPosition ?? _lastPosition;
    if (base == null) {
      return;
    }

    if (_isHeadingUsable(base.heading) && base.speed >= _gpsHeadingSpeedThreshold) {
      return;
    }

    final now = DateTime.now();
    if (_lastCompassUiEmission != null && now.difference(_lastCompassUiEmission!) < _compassThrottle) {
      return;
    }

    final double blended = _applyHeadingSmoothing(normalized, 0.25, enforceJitter: true);
    final Position updated = _copyPositionWithHeading(base, blended, timestamp: now);
    _broadcastPosition(updated);
    _lastCompassUiEmission = now;
  }

  void _broadcastPosition(Position position) {
    _lastBroadcastPosition = position;
    if (!_positionController.isClosed) {
      _positionController.add(position);
    }
  }

  Position _copyPositionWithHeading(Position position, double heading, {DateTime? timestamp}) {
    return Position(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: timestamp ?? position.timestamp,
      accuracy: position.accuracy,
      altitude: position.altitude,
      altitudeAccuracy: position.altitudeAccuracy,
      heading: normalizeHeading(heading),
      headingAccuracy: position.headingAccuracy,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
    );
  }

  double _fuseHeading(Position position) {
    final bool gpsUsable = _isHeadingUsable(position.heading);
    final bool gpsReliable = _isGpsHeadingReliable(position);
    final double? compassHeading = _orientationService.lastHeading ?? _lastCompassHeading;
    final bool compassUsable = _isHeadingUsable(compassHeading);

    double candidate;
    if (gpsReliable && gpsUsable) {
      candidate = position.heading;
    } else if (compassUsable) {
      candidate = compassHeading!;
    } else if (gpsUsable) {
      candidate = position.heading;
    } else if (_lastComputedHeading != null) {
      candidate = _lastComputedHeading!;
    } else {
      candidate = 0.0;
    }

    return _applyHeadingSmoothing(candidate, gpsReliable ? 0.35 : 0.2);
  }

  double _applyHeadingSmoothing(double candidate, double alpha, {bool enforceJitter = false}) {
    final double normalizedCandidate = normalizeHeading(candidate);
    if (_lastComputedHeading == null) {
      _lastComputedHeading = normalizedCandidate;
      return _lastComputedHeading!;
    }

    final double delta = shortestHeadingDelta(normalizedCandidate, _lastComputedHeading!);
    if (enforceJitter && delta.abs() < _compassJitterThreshold) {
      return _lastComputedHeading!;
    }

    _lastComputedHeading = normalizeHeading(_lastComputedHeading! + delta * alpha);
    return _lastComputedHeading!;
  }

  bool _isHeadingUsable(double? heading) {
    if (heading == null) return false;
    if (heading.isNaN || !heading.isFinite) return false;
    if (heading == -1) return false;
    return true;
  }

  bool _isGpsHeadingReliable(Position position) {
    final double speed = position.speed;
    if (speed >= _gpsHeadingSpeedThreshold) {
      return true;
    }

    final double accuracy = position.headingAccuracy;
    return accuracy >= 0 && accuracy <= 25;
  }

  void _resetHeadingState() {
    _lastComputedHeading = null;
    _lastCompassHeading = null;
    _lastCompassUiEmission = null;
  }

  _SegmentBreakDecision? _detectSegmentBreak(Position nextPosition) {
    final Position? previous = _lastBroadcastPosition ?? _lastPosition;
    if (previous == null) return null;

  final DateTime previousTs = previous.timestamp;
  final DateTime nextTs = nextPosition.timestamp;

    Duration rawGap = nextTs.difference(previousTs);
    final bool gapNegative = rawGap.isNegative;
    if (gapNegative) {
      rawGap = Duration(milliseconds: rawGap.inMilliseconds.abs());
    }

    final double distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      nextPosition.latitude,
      nextPosition.longitude,
    );

    final double seconds = rawGap.inMilliseconds > 0 ? rawGap.inMilliseconds / 1000.0 : 0.0;
    final double speed = seconds > 0 ? distance / seconds : double.infinity;

    final bool largeJump = distance >= _segmentGapDistanceMeters;
    final bool longGap = rawGap >= _segmentGapDuration && distance >= _segmentGapDistanceForLongGap;
    final bool teleportSpeed = speed > _maxTeleportSpeedMps && distance >= _segmentBreakMinDistance;
    final bool timestampRegression = gapNegative && distance >= _segmentBreakMinDistance;

    if (!largeJump && !longGap && !teleportSpeed && !timestampRegression) {
      return null;
    }

    final String reason;
    if (largeJump) {
      reason = 'large_distance_jump';
    } else if (teleportSpeed) {
      reason = 'speed_spike';
    } else if (longGap) {
      reason = 'long_gap';
    } else {
      reason = 'timestamp_regressed';
    }

    return _SegmentBreakDecision(
      reason: reason,
      distanceMeters: distance,
      timeGap: rawGap,
      speedMps: speed,
    );
  }

  Future<void> _handleSegmentBreak(_SegmentBreakDecision decision) async {
    final double speedKmh = decision.speedMps.isFinite ? decision.speedMps * 3.6 : double.infinity;
    _logger.warning(
      '🧭 Segment break (${decision.reason}): gap=${decision.timeGap.inSeconds}s, '
      'distance=${decision.distanceMeters.toStringAsFixed(1)}м, '
      'speed=${speedKmh.isFinite ? speedKmh.toStringAsFixed(1) : 'inf'} км/ч',
    );

    try {
      await _trackManager.breakCurrentSegment(reason: decision.reason);
    } catch (e, st) {
      _logger.severe('Не удалось принудительно завершить сегмент в TrackManager', e, st);
      try {
        _trackManager.clearLiveBuffer();
      } catch (inner, innerSt) {
        _logger.warning('Не удалось очистить live buffer после ошибки breakCurrentSegment', inner, innerSt);
      }
    } finally {
      _lastPosition = null;
      _lastBroadcastPosition = null;
      _resetHeadingState();
      _stationaryCount = 0;
    }
  }


  void _setLastPositionFromTrack(UserTrack track) {
    if (track.segments.isEmpty) return;

    final lastSegment = track.segments.last;
    if (lastSegment.pointCount == 0) return;

    final lastIndex = lastSegment.pointCount - 1;
    final (lat, lng) = lastSegment.getCoordinates(lastIndex);
    final timestamp = lastSegment.getTimestamp(lastIndex);

    final heading = normalizeHeading(lastSegment.getBearing(lastIndex) ?? 0.0);
    final restoredPosition = Position(
      latitude: lat,
      longitude: lng,
      timestamp: timestamp,
      accuracy: lastSegment.getAccuracy(lastIndex) ?? 5.0,
      altitude: 0.0,
      altitudeAccuracy: 10.0,
      heading: heading,
      headingAccuracy: 15.0,
      speed: (lastSegment.getSpeed(lastIndex) ?? 30.0) / 3.6, // км/ч -> м/с
      speedAccuracy: 2.0,
    );

    _lastPosition = restoredPosition;
    _lastBroadcastPosition = restoredPosition;
    _lastComputedHeading = heading;

    _logger.info("Последняя позиция установлена: $lat, $lng");
  }

  void dispose() {
    _positionSubscription?.cancel();
    _orientationSubscription?.cancel();
    unawaited(_orientationService.stop());
    _trackUpdateSubscription?.cancel(); // Добавлено
    _trackManager.dispose();
    _positionController.close();
    _trackingStateController.close();
    _pauseStateController.close();
    _liveTrackUpdateController.close();
    _resetHeadingState();
  }
}

class _SegmentBreakDecision {
  final String reason;
  final double distanceMeters;
  final Duration timeGap;
  final double speedMps;

  const _SegmentBreakDecision({
    required this.reason,
    required this.distanceMeters,
    required this.timeGap,
    required this.speedMps,
  });
}
