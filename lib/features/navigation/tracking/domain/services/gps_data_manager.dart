import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'gps_data_source.dart';
import 'mock_gps_data_source.dart';

/// Режимы GPS трекинга
enum GpsMode {
  /// Реальный GPS
  real,
  /// Мок данные для тестирования
  mock,
  /// Гибридный режим (исторические данные + мок продолжение)
  hybrid
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
  
  // Singleton pattern
  static final GpsDataManager _instance = GpsDataManager._internal();
  factory GpsDataManager() => _instance;
  GpsDataManager._internal();
  
  /// Текущий режим GPS
  GpsMode get currentMode => _currentMode;
  
  /// Текущий источник данных
  GpsDataSource? get currentSource => _currentSource;
  
  /// Инициализирует GPS с указанным режимом
  Future<void> initialize({
    required GpsMode mode,
    GpsTestConfig? testConfig,
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
          speedMultiplier: testConfig?.speedMultiplier ?? 1.0,
          addGpsNoise: testConfig?.addGpsNoise ?? true,
          baseAccuracy: testConfig?.baseAccuracy ?? 5.0,
        );
        
        if (testConfig?.mockDataPath != null) {
          await mockSource.loadRoute(testConfig!.mockDataPath!);
          
          if (testConfig.startProgress != null) {
            mockSource.setProgress(testConfig.startProgress!);
          }
        }
        
        _currentSource = mockSource;
        print('🎭 $_tag: Инициализирован мок GPS с конфигурацией: ${testConfig?.mockDataPath}');
        break;
        
      case GpsMode.hybrid:
        // TODO: Реализовать гибридный режим (исторические + мок)
        throw UnimplementedError('Гибридный режим пока не реализован');
    }
  }
  
  /// Быстрая настройка для режима разработки/тестирования
  Future<void> initializeForDevelopment({
    GpsTestConfig? config,
  }) async {
    final testConfig = config ?? GpsTestConfig.defaultTest;
    await initialize(mode: GpsMode.mock, testConfig: testConfig);
  }
  
  /// Быстрая настройка для демонстрации
  Future<void> initializeForDemo() async {
    await initialize(mode: GpsMode.mock, testConfig: GpsTestConfig.fastTest);
  }
  
  /// Переключиться на реальный GPS
  Future<void> switchToRealGps() async {
    await initialize(mode: GpsMode.real);
  }
  
  /// Переключиться на мок GPS с заданной конфигурацией
  Future<void> switchToMockGps(GpsTestConfig config) async {
    await initialize(mode: GpsMode.mock, testConfig: config);
  }
  
  /// Получить стрим позиций
  Stream<Position> getPositionStream({required LocationSettings settings}) {
    if (_currentSource == null) {
      throw StateError('GPS источник не инициализирован. Вызовите initialize() сначала.');
    }
    
    return _currentSource!.getPositionStream(settings: settings);
  }
  
  /// Проверить разрешения
  Future<bool> checkPermissions() async {
    if (_currentSource == null) {
      throw StateError('GPS источник не инициализирован');
    }
    
    return _currentSource!.checkPermissions();
  }
  
  /// Получить текущую позицию
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
  
  /// Освободить ресурсы
  Future<void> dispose() async {
    await _disposeCurrentSource();
    print('🔄 $_tag: Менеджер GPS освобожден');
  }
  
  /// Освобождает текущий источник данных
  Future<void> _disposeCurrentSource() async {
    if (_currentSource != null) {
      await _currentSource!.dispose();
      _currentSource = null;
    }
  }
  
  /// Получить описание текущей конфигурации
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
  
  /// Приостанавливает мок GPS (если используется)
  void pauseMockGps() {
    if (_currentMode == GpsMode.mock && _currentSource is MockGpsDataSource) {
      final mockSource = _currentSource as MockGpsDataSource;
      mockSource.pause();
      print('⏸️ $_tag: Мок GPS приостановлен');
    }
  }
  
  /// Возобновляет мок GPS (если используется)
  void resumeMockGps() {
    if (_currentMode == GpsMode.mock && _currentSource is MockGpsDataSource) {
      final mockSource = _currentSource as MockGpsDataSource;
      mockSource.resume();
      print('▶️ $_tag: Мок GPS возобновлен');
    }
  }
}
