import 'dart:async';
import 'package:geolocator/geolocator.dart';
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
  static const String _tag = 'GpsDataManager';
  
  GpsDataSource? _currentSource;
  GpsMode _currentMode = GpsMode.real;
  GpsTestConfig? _testConfig;

  static final GpsDataManager _instance = GpsDataManager._internal();
  factory GpsDataManager() => _instance;
  GpsDataManager._internal();

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
        print('🌍 $_tag: Инициализирован реальный GPS');
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
        print('🎭 $_tag: Инициализирован мок GPS с конфигурацией: ${testConfig.mockDataPath}');
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
    if (_currentSource == null) {
      throw StateError('GPS источник не инициализирован. Вызовите initialize() сначала.');
    }
    print('🌍 GpsDataManager: getPositionStream() вызван, _currentSource: ${_currentSource.runtimeType}');
    return _currentSource!.getPositionStream(settings: settings).map((position) {
      print('🌍 GpsDataManager: Передаем позицию ${position.latitude}, ${position.longitude}');
      return position;
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
      print('⏸️ $_tag: Мок GPS приостановлен');
    }
  }

  void resumeMockGps() {
    if (_currentMode == GpsMode.mock && _currentSource is MockGpsDataSource) {
      final mockSource = _currentSource as MockGpsDataSource;
      mockSource.resume();
      print('▶️ $_tag: Мок GPS возобновлен');
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
        print('▶️ $_tag: Используется Mock GPS, возобновление потока...');
        await Future.delayed(const Duration(seconds: 1));
        (_currentSource as MockGpsDataSource).resumeStream();
        return true;
      }

      // Для реального GPS: проверяем разрешения и подписываемся на поток
      print('🌍 $_tag: Используется реальный GPS, проверка разрешений...');
      print(_currentSource);
      // Defensive timeout already implemented in underlying checkPermissions if desired
      final hasPermission = await checkPermissions().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏱️ $_tag: checkPermissions() timed out');
          return false;
        },
      );

      print('🌍 $_tag: checkPermissions() returned: $hasPermission');
      if (hasPermission) {
        print('✅ $_tag: Location permission granted — GPS started');
        // Subscribe to stream or other start logic here
        return true;
      } else {
        print('❌ $_tag: Location permission denied - cannot start real GPS');
        return false;
      }
    } catch (e, st) {
      print('❗ $_tag: Exception while starting GPS: $e\n$st');
      return false;
    }
  }

  /// Отключить GPS (stop)
  void stopGps() {
    if (_currentSource == null) return;
    if (_currentSource is MockGpsDataSource) {
      (_currentSource as MockGpsDataSource).pauseStream();
    }
    //gpsState.value = GpsToggleState.off;
  }
}
