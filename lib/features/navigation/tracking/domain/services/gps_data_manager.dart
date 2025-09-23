import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
// Use Geolocator for permission handling to avoid additional Android plugins
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'gps_data_source.dart';
import 'mock_gps_data_source.dart';

/// Режимы GPS трекинга
enum GpsMode {
  real,
  mock
}

/// Конфигурация для режима тестирования GPS
class GpsTestConfig {
  final String? mockDataPath;
  final double speedMultiplier;
  final bool addGpsNoise;
  final double baseAccuracy;
  final double? startProgress; // 0.0 - 1.0, с какого момента начать
  
  const GpsTestConfig({
    this.mockDataPath,
    this.speedMultiplier = 1.0,
    this.addGpsNoise = true,
    this.baseAccuracy = 5.0,
    this.startProgress,
  });
  
  static const GpsTestConfig defaultTest = GpsTestConfig(
    mockDataPath: 'assets/data/tracks/continuation_scenario.json',
    speedMultiplier: 1.5, // Немного ускорено для лучшего восприятия
    addGpsNoise: true,
    baseAccuracy: 4.0,
  );
  
  static const GpsTestConfig fastTest = GpsTestConfig(
    mockDataPath: 'assets/data/tracks/current_day_track.json',
    speedMultiplier: 10.0, // Очень быстро для быстрой проверки
    addGpsNoise: false,
    baseAccuracy: 3.0,
    startProgress: 0.8, // Начать с 80% маршрута
  );
}

/// Менеджер GPS источников данных
/// 
/// Обеспечивает переключение между реальным GPS и мок-данными
/// для тестирования трекинга в контролируемой среде
class GpsDataManager {
  static final Logger _logger = Logger('GpsDataManager');
  
  GpsDataSource? _currentSource;
  GpsMode _currentMode = GpsMode.real;
  GpsTestConfig? _testConfig;
  // Channel for native background service -> Flutter
  static const MethodChannel _platformChannel = MethodChannel('fieldforce/background_location');
  final StreamController<Position> _nativePositionController = StreamController<Position>.broadcast();

  static final GpsDataManager _instance = GpsDataManager._internal();
  factory GpsDataManager() => _instance;
  // Guard to avoid requesting permissions repeatedly in a tight loop.
  bool _permissionRequestInProgress = false;
  DateTime? _lastPermissionRequestAt;
  // Track whether the native foreground service has been requested/started
  // so we don't re-invoke MethodChannel.startService repeatedly.
  bool _nativeServiceStarted = false;
  // Cache whether we observed background (always) permission. If true,
  // future startGps() calls can be fast-path without re-requesting permission.
  bool _hasBackgroundPermission = false;
  GpsDataManager._internal() {
    // Handle incoming method calls from native background service
    _platformChannel.setMethodCallHandler((call) async {
      try {
        if (call.method == 'onLocation') {
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final double lat = (args['latitude'] as num).toDouble();
          final double lon = (args['longitude'] as num).toDouble();
          final double accuracy = args.containsKey('accuracy') ? (args['accuracy'] as num).toDouble() : 0.0;
          final int timestamp = args.containsKey('timestamp') ? (args['timestamp'] as int) : DateTime.now().millisecondsSinceEpoch;

          final pos = Position(
            latitude: lat,
            longitude: lon,
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            accuracy: accuracy,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );

          _logger.fine('GpsDataManager: received native onLocation: $lat,$lon acc=$accuracy');
          _nativePositionController.add(pos);
        } else if (call.method == 'onStatus') {
          _logger.info('GpsDataManager: native status=${call.arguments}');
        }
      } catch (e, st) {
        _logger.warning('Error handling platform channel call', e, st);
      }
    });
  }

  GpsMode get currentMode => _currentMode;
  GpsDataSource? get currentSource => _currentSource;
  
  /// Инициализирует GPS с указанным режимом
  Future<void> initialize({
    required GpsMode mode,
    GpsTestConfig testConfig = GpsTestConfig.defaultTest,
  }) async {
    await _disposeCurrentSource();
    _currentMode = mode;
    _testConfig = testConfig;
    
    switch (mode) {
      case GpsMode.real:
        _currentSource = RealGpsDataSource();
        _logger.info('Инициализирован реальный GPS');
        break;
        
      case GpsMode.mock:
        final mockSource = MockGpsDataSource(
          speedMultiplier: testConfig.speedMultiplier,
          addGpsNoise: testConfig.addGpsNoise,
          baseAccuracy: testConfig.baseAccuracy,
        );

        await mockSource.loadRoute(testConfig.mockDataPath!);

        if (testConfig.startProgress != null) {
          mockSource.setProgress(testConfig.startProgress!);
        }

        _currentSource = mockSource;
        _logger.info('Инициализирован мок GPS с конфигурацией: ${testConfig.mockDataPath}');
        // mockSource.resume();
        break;
    }
  }

  Future<void> initializeForDevelopment({
    GpsTestConfig? config,
  }) async {
    final testConfig = config ?? GpsTestConfig.defaultTest;
    await initialize(mode: GpsMode.mock, testConfig: testConfig);
  }

  Future<void> initializeForDemo() async {
    await initialize(mode: GpsMode.mock, testConfig: GpsTestConfig.fastTest);
  }

  Future<void> switchToRealGps() async {
    await initialize(mode: GpsMode.real);
  }

  Future<void> switchToMockGps(GpsTestConfig config) async {
    await initialize(mode: GpsMode.mock, testConfig: config);
  }

  Stream<Position> getPositionStream({required LocationSettings settings}) {
    // If we don't have a configured source but native background updates are
    // available (Android), expose those so the app can still receive positions.
    if (_currentSource == null) {
      if (Platform.isAndroid) {
        return _nativePositionController.stream;
      }
      throw StateError('GPS источник не инициализирован. Вызовите initialize() сначала.');
    }

    // Merge the underlying source stream with native background-location stream (if any)
    return Stream<Position>.multi((controller) {
      final subs = <StreamSubscription<Position>>[];

      final s1 = _currentSource!.getPositionStream(settings: settings).listen((p) => controller.add(p), onError: controller.addError, onDone: () {});
      subs.add(s1);

      if (Platform.isAndroid) {
        final s2 = _nativePositionController.stream.listen((p) => controller.add(p), onError: controller.addError, onDone: () {});
        subs.add(s2);
      }

      controller.onCancel = () {
        for (final s in subs) {
          s.cancel();
        }
      };
    });
  }

  Future<bool> checkPermissions() async {
    if (_currentSource == null) {
      throw StateError('GPS источник не инициализирован');
    }
    
    return _currentSource!.checkPermissions();
  }

  Future<Position> getCurrentPosition({required LocationSettings settings}) async {
    if (_currentSource == null) {
      throw StateError('GPS источник не инициализирован');
    }
    
    return _currentSource!.getCurrentPosition(settings: settings);
  }
  
  /// Получить информацию о воспроизведении (только для мок режима)
  Map<String, dynamic>? getPlaybackInfo() {
    if (_currentSource is MockGpsDataSource) {
      return (_currentSource as MockGpsDataSource).getPlaybackInfo();
    }
    return null;
  }

  Future<void> dispose() async {
    await _disposeCurrentSource();
  }
  
  /// Освобождает текущий источник данных
  Future<void> _disposeCurrentSource() async {
    if (_currentSource != null) {
      await _currentSource!.dispose();
      _currentSource = null;
    }
    // keep native controller open; do not close it so background service
    // can still push events while app is alive. If you want to close it,
    // call dispose() on the manager.
  }

  Map<String, dynamic> getConfigInfo() {
    return {
      'mode': _currentMode.toString(),
      'isInitialized': _currentSource != null,
      'testConfig': _testConfig != null ? {
        'mockDataPath': _testConfig!.mockDataPath,
        'speedMultiplier': _testConfig!.speedMultiplier,
        'addGpsNoise': _testConfig!.addGpsNoise,
        'baseAccuracy': _testConfig!.baseAccuracy,
        'startProgress': _testConfig!.startProgress,
      } : null,
      'playbackInfo': getPlaybackInfo(),
    };
  }

  void pauseMockGps() {
    if (_currentMode == GpsMode.mock && _currentSource is MockGpsDataSource) {
      final mockSource = _currentSource as MockGpsDataSource;
      mockSource.pause();
      _logger.info('Мок GPS приостановлен');
    }
  }

  void resumeMockGps() {
    if (_currentMode == GpsMode.mock && _currentSource is MockGpsDataSource) {
      final mockSource = _currentSource as MockGpsDataSource;
      mockSource.resume();
      _logger.info('Мок GPS возобновлен');
    }
  }

  /// Управление mock GPS ��отоком (если источник поддерживает)
  void pauseMockStream() {
    if (_currentSource is MockGpsDataSource) {
      (_currentSource as MockGpsDataSource).pauseStream();
    }
  }

  void resumeMockStream() {
    if (_currentSource is MockGpsDataSource) {
      (_currentSource as MockGpsDataSource).resumeStream();
    }
  }

  void stopMockStream() {
    if (_currentSource is MockGpsDataSource) {
      (_currentSource as MockGpsDataSource).stopStream();
    }
  }

  void throwMockError([dynamic error]) {
    if (_currentSource is MockGpsDataSource) {
      (_currentSource as MockGpsDataSource).throwError(error);
    }
  }

  /// Включить GPS (start)
  Future<bool> startGps() async {
    try {
      // Для mock: resume поток
      if (_currentSource is MockGpsDataSource) {
        _logger.info('Используется Mock GPS, возобновление потока...');
        await Future.delayed(const Duration(seconds: 1));
        (_currentSource as MockGpsDataSource).resumeStream();
        return true;
      }

      // Для реального GPS: проверяем разрешения и подписываемся на поток
      _logger.info('Используется реальный GPS, проверка разрешений...');
      _logger.fine('Текущий источник: $_currentSource');
      // Defensive timeout already implemented in underlying checkPermissions if desired
      final hasPermission = await checkPermissions().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          _logger.warning('checkPermissions() timed out');
          return false;
        },
      );

      _logger.info('checkPermissions() returned: $hasPermission');
      if (hasPermission) {
        _logger.info('Location permission granted — GPS started');
        // If running on Android, attempt to start the native foreground service
        if (Platform.isAndroid) {
          // Fast-path: if we already observed background permission and
          // already started the native service, avoid repeated permission
          // checks and MethodChannel calls which can be noisy and lead to
          // UI contention. This makes startGps() idempotent and cheap.
          if (_hasBackgroundPermission && _nativeServiceStarted) {
            _logger.fine('GpsDataManager.startGps: native service already started and background permission cached — fast-path return');
            return true;
          }
          // Request background location permission explicitly before starting service.
          // Geolocator supports checking/requesting both whileInUse and always permissions.
          try {
            _logger.fine('GpsDataManager.startGps: checking current Geolocator permission');
            final current = await Geolocator.checkPermission();
            _logger.fine('GpsDataManager.startGps: current permission = $current');
            if (current == LocationPermission.denied) {
              _logger.info('GpsDataManager.startGps: Requesting location permission (whileInUse)');
              final req = await Geolocator.requestPermission();
              _logger.info('GpsDataManager.startGps: requestPermission() returned $req');
              if (req == LocationPermission.denied) {
                _logger.warning('GpsDataManager.startGps: Location permission denied by user');
              }
            }

            // For background updates we need LocationPermission.always
            final after = await Geolocator.checkPermission();
            _logger.fine('GpsDataManager.startGps: permission after request = $after');

            // Throttle repeated background permission requests to avoid a loop
            // where the app keeps asking while the user is trying to open
            // Settings. If a request is already in progress or was performed
            // recently, skip re-requesting and rely on a subsequent resume
            // to re-check.
            final now = DateTime.now();
            final recentlyRequested = _lastPermissionRequestAt != null && now.difference(_lastPermissionRequestAt!).inSeconds < 3;

            if (after != LocationPermission.always && !_permissionRequestInProgress && !recentlyRequested) {
              _logger.info('GpsDataManager.startGps: Requesting background (always) location permission');
              try {
                _permissionRequestInProgress = true;
                _lastPermissionRequestAt = DateTime.now();
                final reqAlways = await Geolocator.requestPermission();
                _logger.info('GpsDataManager.startGps: requestPermission() for always returned $reqAlways');
                if (reqAlways != LocationPermission.always) {
                  _logger.warning('GpsDataManager.startGps: Background location (always) not granted; background updates may be limited');
                }
              } finally {
                _permissionRequestInProgress = false;
              }
            } else if (after != LocationPermission.always) {
              _logger.fine('GpsDataManager.startGps: Skipping repeated background permission request (recent or in-progress)');
            }
          } catch (e, st) {
            _logger.warning('GpsDataManager.startGps: Error while requesting background permission', e, st);
          }
          try {
            // Only attempt to start the native foreground service if the app
            // has the 'always' background permission. Starting an FGS with
            // type=location without the proper permissions on newer SDKs
            // triggers a SecurityException (seen on targetSdk 36+).
            final finalPerm = await Geolocator.checkPermission();
            // Cache whether we have background permission so subsequent
            // invocations of startGps() can fast-path and avoid re-requests.
            _hasBackgroundPermission = finalPerm == LocationPermission.always;
            if (_hasBackgroundPermission && _nativeServiceStarted) {
              _logger.fine('GpsDataManager.startGps: finalPerm=always and nativeServiceStarted=true; skipping startService');
            }
            if (finalPerm == LocationPermission.always) {
              // Only call startService once until stopGps() clears the flag.
              if (!_nativeServiceStarted) {
                const channel = MethodChannel('fieldforce/background_location');
                _logger.fine('GpsDataManager.startGps: invoking MethodChannel startService');
                final startResult = await channel.invokeMethod('startService', <String, dynamic>{
                  'minDistance': 5.0,
                  'intervalMillis': 15000,
                });
                _logger.info('GpsDataManager.startGps: Requested native foreground service start via MethodChannel; result=$startResult');
                _nativeServiceStarted = true;
              } else {
                _logger.fine('GpsDataManager.startGps: native service previously started - skipping invoke');
              }
            } else {
              _logger.warning('GpsDataManager.startGps: Skipping native startService because background "always" permission is not granted (current=$finalPerm)');
            }
          } catch (e, st) {
            _logger.warning('GpsDataManager.startGps: Failed to request native foreground service start', e, st);
          }
        }
        // Subscribe to stream or other start logic here
        return true;
      } else {
        _logger.warning('Location permission denied - cannot start real GPS');
        return false;
      }
    } catch (e, st) {
      _logger.severe('Exception while starting GPS', e, st);
      return false;
    }
  }

  /// Отключить GPS (stop)
  void stopGps() {
    if (_currentSource == null) return;
    if (_currentSource is MockGpsDataSource) {
      (_currentSource as MockGpsDataSource).pauseStream();
    }
    // Reset native service flags so future startGps() will re-evaluate.
    _nativeServiceStarted = false;
    _hasBackgroundPermission = false;
    //gpsState.value = GpsToggleState.off;
    // If running on Android, stop the native foreground service
    try {
      if (Platform.isAndroid) {
        const channel = MethodChannel('fieldforce/background_location');
        channel.invokeMethod('stopService');
        _logger.info('Requested native foreground service stop');
      }
    } catch (e, st) {
      _logger.warning('Failed to request native foreground service stop', e, st);
    }
  }
}
