import 'dart:async';
import 'dart:math' as math;
import 'package:fieldforce/app/services/test_coordinates_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'gps_data_source.dart';

/// Мок источник GPS данных для тестирования
///
/// Эмулирует движение по заранее заданному маршруту из JSON файла.
/// Поддерживает:
/// - Воспроизведение исторических данных
/// - Продолжение движения по сценарию
/// - Реалистичное время между точками
/// - Настраиваемую скорость воспроизведения
class MockGpsDataSource implements GpsDataSource {
  static final Logger _logger = Logger('MockGpsDataSource');
  static const String _tag = 'MockGPS';

  // Текущее состояние
  List<Map<String, dynamic>> _routePoints = [];
  int _currentPointIndex = 0;
  bool _isActive = false;
  bool _isPaused = false;
  Timer? _playbackTimer;

  // Настройки воспроизведения
  final Duration _defaultInterval = const Duration(seconds: 2);
  final double _speedMultiplier;
  final bool _addGpsNoise;
  final double _baseAccuracy;

  // Стрим контроллеры
  late final StreamController<Position> _positionController;

  MockGpsDataSource({
    double speedMultiplier = 1.0,
    bool addGpsNoise = true,
    double baseAccuracy = 5.0,
  }) : _speedMultiplier = speedMultiplier,
       _addGpsNoise = addGpsNoise,
       _baseAccuracy = baseAccuracy {
    _positionController = StreamController<Position>.broadcast(
      onListen: () => debugPrint('🎧 $_tag: GPS stream - слушатель подключился (listeners=${_positionController.hasListener})'),
      onCancel: () => debugPrint('🛑 $_tag: GPS stream - слушатель отключился (listeners=${_positionController.hasListener})'),
    );
  }

  bool get hasPositionListeners => _positionController.hasListener;

  Future<void> loadRoute(String jsonAssetPath) async {
    try {
      debugPrint('🎭 $_tag: Загружаем маршрут из $jsonAssetPath');

      final loader = TestCoordinatesLoader(
        nominalSpeedMps: 5.0,
        speedMultiplier: _speedMultiplier,
      );

      final loaded = await loader.loadFromAsset(jsonAssetPath);

      if (loaded.isEmpty) {
        _logger.warning('🎭 $_tag: Loader returned empty route, creating test route');
        return;
      }

      _routePoints = loaded.map((p) {
        return {
          'lat': (p['lat'] as num).toDouble(),
          'lng': (p['lng'] as num).toDouble(),
          'timestamp': p['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
          'elevation': (p['elevation'] as num?)?.toDouble() ?? 0.0,
          'bearing': (p['bearing'] as num?)?.toDouble() ?? 0.0,
          'speed': (p['speed'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();

      _currentPointIndex = 0;
      debugPrint('🎭 $_tag: Маршрут загружен (${_routePoints.length} точек)');

    } catch (e, st) {
      _logger.severe('❌ $_tag: Ошибка загрузки маршрута: $e', e, st);
      // _createTestRoute();
    }
  }


  void setStartPosition(int pointIndex) {
    if (pointIndex >= 0 && pointIndex < _routePoints.length) {
      _currentPointIndex = pointIndex;
      debugPrint('🎭 $_tag: Установлен индекс точки: $_currentPointIndex');
    }
  }

  void setProgress(double progress) {
    final targetIndex = ((_routePoints.length - 1) * progress.clamp(0.0, 1.0)).round();
    setStartPosition(targetIndex);
  }

  @override
  Stream<Position> getPositionStream({required LocationSettings settings}) {
    debugPrint('🎭 $_tag: getPositionStream() вызван');
    return _positionController.stream;
  }

  @override
  Future<bool> checkPermissions() async {
    // Мок всегда имеет "разрешения"
    debugPrint('🎭 $_tag: checkPermissions() - разрешения предоставлены (mock)');
    return true;
  }

  @override
  Future<Position> getCurrentPosition({required LocationSettings settings}) async {
    if (_routePoints.isEmpty) {
      throw Exception('Маршрут не загружен');
    }

    final currentPoint = _routePoints[_currentPointIndex];
    return _createPositionFromPoint(currentPoint);
  }

  /// Возобновляет эмиссию позиций (вызывается из GpsDataManager.startGps())
  void resumeStream() {
    debugPrint('▶️ $_tag: resumeStream() вызван - начинаем эмиссию позиций');

    if (_routePoints.isEmpty) {
      debugPrint('❌ $_tag: Нет точек для воспроизведения, создаем тестовый маршрут');
    }

    if (_isActive && !_isPaused) {
      debugPrint('🎭 $_tag: Уже активен и не на паузе');
      return;
    }

    _isActive = true;
    _isPaused = false;
    _startPlayback();
  }

  /// Приостанавливает эмиссию позиций
  void pauseStream() {
    debugPrint('⏸️ $_tag: pauseStream() вызван');
    _isPaused = true;
  }

  /// Останавливает и сбрасывает воспроизведение
  void stopStream() {
    debugPrint('⏹️ $_tag: stopStream() вызван');
    _isActive = false;
    _isPaused = false;
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _currentPointIndex = 0;
  }

  void throwError([dynamic error]) {
    if (!_positionController.isClosed) {
      _positionController.addError(error ?? Exception('Mock GPS error'));
    }
  }

  void _startPlayback() {
    debugPrint('🎬 $_tag: _startPlayback() - запускаем воспроизведение');

    if (_playbackTimer?.isActive == true) {
      debugPrint('🎭 $_tag: Таймер уже активен');
      return;
    }

    if (_routePoints.isEmpty) {
      debugPrint('❌ $_tag: Нет точек для воспроизведения');
      return;
    }

    _startPlaybackTimer();
  }

  /// Создает периодический таймер для эмиссии позиций
  void _startPlaybackTimer() {
    _playbackTimer?.cancel();

    final intervalMs = (_defaultInterval.inMilliseconds / _speedMultiplier).round();
    final interval = Duration(milliseconds: intervalMs);

    debugPrint('🎬 $_tag: Создаем таймер с интервалом ${interval.inMilliseconds}мс');

    _playbackTimer = Timer.periodic(interval, (timer) {
      if (!_isActive || _isPaused || _routePoints.isEmpty) {
        debugPrint('🎭 $_tag: Пропускаем эмиссию - active:$_isActive, paused:$_isPaused, points:${_routePoints.length}');
        return;
      }

      if (_currentPointIndex >= _routePoints.length) {
        debugPrint('🏁 $_tag: Достигнут конец маршрута, останавливаемся');
        stopStream();
        return;
      }

      try {
        // final currentPoint = _routePoints[_currentPointIndex];
        // final position = _createPositionFromPoint(currentPoint);

        // if (!_positionController.isClosed) {
        //   _positionController.add(position);
        //   debugPrint('📍 $_tag: Эмитируем позицию ${_currentPointIndex + 1}/${_routePoints.length}: ${position.latitude}, ${position.longitude}');
        // }

        _currentPointIndex++;
      } catch (e, st) {
        debugPrint('❌ $_tag: Ошибка при эмиссии позиции: $e\n$st');
      }
    });
  }

  /// Создает Position из точки маршрута
  Position _createPositionFromPoint(Map<String, dynamic> point) {
    double lat = (point['lat'] ?? point['latitude'] ?? 0.0).toDouble();
    double lng = (point['lng'] ?? point['lon'] ?? point['longitude'] ?? 0.0).toDouble();

    // Добавляем GPS шум если включен
    if (_addGpsNoise) {
      final random = math.Random();
      lat += (random.nextDouble() - 0.5) * 0.0001; // ~11м
      lng += (random.nextDouble() - 0.5) * 0.0001;
    }

    // Извлекаем временную метку
    int? timestampMs = point['timestamp'] as int?;
    DateTime timestamp = timestampMs != null
        ? DateTime.fromMillisecondsSinceEpoch(timestampMs)
        : DateTime.now();

    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: timestamp,
      accuracy: _baseAccuracy + (math.Random().nextDouble() * 5),
      altitude: (point['elevation'] as num?)?.toDouble() ?? 100.0,
      altitudeAccuracy: 10.0,
      heading: (point['bearing'] as num?)?.toDouble() ?? 0.0,
      headingAccuracy: 15.0,
      speed: ((point['speed'] as num?)?.toDouble() ?? 30.0) / 3.6, // км/ч -> м/с
      speedAccuracy: 2.0,
    );
  }

  /// Получает информацию о воспроизведении
  Map<String, dynamic> getPlaybackInfo() {
    return {
      'isActive': _isActive,
      'isPaused': _isPaused,
      'currentIndex': _currentPointIndex,
      'totalPoints': _routePoints.length,
      'progress': _routePoints.isEmpty ? 0.0 : _currentPointIndex / _routePoints.length,
      'speedMultiplier': _speedMultiplier,
      'hasTimer': _playbackTimer?.isActive ?? false,
    };
  }

  // Методы совместимости с существующим кодом
  void pause() => pauseStream();
  void resume() => resumeStream();

  @override
  Future<void> dispose() async {
    debugPrint('🧹 $_tag: Освобождаем ресурсы');
    _playbackTimer?.cancel();
    await _positionController.close();
  }
}
