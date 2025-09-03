import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
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
  static const String _tag = 'MockGPS';
  
  // Текущее состояние
  List<Map<String, dynamic>> _routePoints = [];
  int _currentPointIndex = 0;
  bool _isActive = false;
  bool _isPaused = false;
  DateTime? _startTime;
  Timer? _playbackTimer;
  
  // Настройки воспроизведения
  final Duration _defaultInterval = const Duration(seconds: 2);
  final double _speedMultiplier;
  final bool _addGpsNoise;
  final double _baseAccuracy;
  
  // Стрим контроллеры
  final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
  
  MockGpsDataSource({
    double speedMultiplier = 1.0,
    bool addGpsNoise = true,
    double baseAccuracy = 5.0,
  }) : _speedMultiplier = speedMultiplier,
       _addGpsNoise = addGpsNoise,
       _baseAccuracy = baseAccuracy;

  /// Загружает маршрут из JSON файла
  Future<void> loadRoute(String jsonAssetPath) async {
    try {
      final jsonString = await rootBundle.loadString(jsonAssetPath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Обрабатываем OSRM формат или простой массив координат
      if (data.containsKey('routes')) {
        _loadFromOSRMResponse(data);
      } else if (data.containsKey('coordinates')) {
        _loadFromCoordinatesArray(data['coordinates']);
      } else {
        throw Exception('Неподдерживаемый формат JSON файла');
      }
      
    } catch (e) {
      debugPrint('$_tag: Ошибка загрузки маршрута: $e');
      rethrow;
    }
  }
  
  /// Устанавливает начальную позицию для продолжения с определенной точки
  void setStartPosition(int pointIndex) {
    if (pointIndex >= 0 && pointIndex < _routePoints.length) {
      _currentPointIndex = pointIndex;
    }
  }
  
  /// Устанавливает прогресс в процентах (0.0 - 1.0)
  void setProgress(double progress) {
    final targetIndex = ((_routePoints.length - 1) * progress.clamp(0.0, 1.0)).round();
    setStartPosition(targetIndex);
  }

  @override
  Stream<Position> getPositionStream({required LocationSettings settings}) {
    if (!_isActive) {
      _startPlayback();
    }
    return _positionController.stream;
  }
  
  @override
  Future<bool> checkPermissions() async {
    // Мок всегда имеет "разрешения"
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
  
  /// Запускает воспроизведение маршрута
  void _startPlayback() {
    if (_isActive || _routePoints.isEmpty) return;
    
    _isActive = true;
    _startTime = DateTime.now();
    
    debugPrint('$_tag: 🎬 Начинаем имитацию GPS трекинга');
    
    // Рассчитываем интервал с учетом скорости
    final adjustedInterval = Duration(
      milliseconds: (_defaultInterval.inMilliseconds / _speedMultiplier).round(),
    );
    
    _playbackTimer = Timer.periodic(adjustedInterval, (timer) {
      // Если на паузе, пропускаем итерацию
      if (_isPaused) return;
      
      if (_currentPointIndex >= _routePoints.length) {
        // Достигли конца маршрута - можем зациклить или остановить
        debugPrint('$_tag: 🏁 GPS трекинг завершён');
        _stopPlayback();
        return;
      }
      
      final currentPoint = _routePoints[_currentPointIndex];
      final position = _createPositionFromPoint(currentPoint);
      
      _positionController.add(position);
      _currentPointIndex++;
    });
  }
  
  /// Останавливает воспроизведение
  void _stopPlayback() {
    _isActive = false;
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }
  
  /// Ставит воспроизведение на паузу
  void pause() {
    if (!_isActive || _isPaused) return;
    
    _isPaused = true;
    debugPrint('$_tag: ⏸️ GPS трекинг поставлен на паузу');
  }
  
  /// Возобновляет воспроизведение с паузы
  void resume() {
    if (!_isActive || !_isPaused) return;
    
    _isPaused = false;
    debugPrint('$_tag: ▶️ GPS трекинг возобновлён');
  }
  
  /// Создает Position из точки маршрута
  Position _createPositionFromPoint(Map<String, dynamic> point) {
    final random = math.Random();
    
    // Базовые координаты
    double lat = point['lat']?.toDouble() ?? point['latitude']?.toDouble() ?? 0.0;
    double lng = point['lng']?.toDouble() ?? point['longitude']?.toDouble() ?? 0.0;
    
    // Добавляем GPS шум для реалистичности
    if (_addGpsNoise) {
      // GPS точность: ±3-8 метров (примерно ±0.00003-0.00008 градусов)
      final latNoise = (random.nextDouble() - 0.5) * 0.00016;
      final lonNoise = (random.nextDouble() - 0.5) * 0.00016;
      lat += latNoise;
      lng += lonNoise;
    }
    
    // Рассчитываем параметры
    final timestamp = DateTime.now();
    final accuracy = _addGpsNoise 
        ? _baseAccuracy + random.nextDouble() * 5.0  // 5-10 метров
        : _baseAccuracy;
    
    // Скорость и направление (если есть)
    final speed = point['speed']?.toDouble() ?? _calculateSpeed();
    final heading = point['bearing']?.toDouble() ?? _calculateHeading();
    
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: timestamp,
      accuracy: accuracy,
      altitude: point['altitude']?.toDouble() ?? 0.0,
      altitudeAccuracy: 10.0,
      heading: heading,
      headingAccuracy: 15.0,
      speed: speed / 3.6, // км/ч -> м/с
      speedAccuracy: 2.0,
    );
  }
  
  /// Загружает маршрут из OSRM ответа
  void _loadFromOSRMResponse(Map<String, dynamic> data) {
    final routes = data['routes'] as List;
    if (routes.isEmpty) throw Exception('OSRM ответ не содержит маршрутов');
    
    final geometry = routes[0]['geometry'];
    final coordinates = geometry['coordinates'] as List;
    
    _routePoints = coordinates.map<Map<String, dynamic>>((coord) {
      return {
        'lng': coord[0],
        'lat': coord[1],
        'timestamp': DateTime.now().toIso8601String(),
      };
    }).toList();
  }
  
  /// Загружает маршрут из массива координат
  void _loadFromCoordinatesArray(List<dynamic> coordinates) {
    _routePoints = coordinates.map<Map<String, dynamic>>((coord) {
      if (coord is List && coord.length >= 2) {
        return {
          'lng': coord[0],
          'lat': coord[1],
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else if (coord is Map) {
        return Map<String, dynamic>.from(coord);
      } else {
        throw Exception('Неподдерживаемый формат координат');
      }
    }).toList();
  }
  
  /// Рассчитывает примерную скорость движения
  double _calculateSpeed() {
    // Базовая скорость: 30-50 км/ч с вариацией
    final random = math.Random();
    return 30.0 + random.nextDouble() * 20.0;
  }
  
  /// Рассчитывает направление движения
  double _calculateHeading() {
    if (_currentPointIndex == 0 || _currentPointIndex >= _routePoints.length - 1) {
      return 0.0;
    }
    
    final current = _routePoints[_currentPointIndex];
    final next = _routePoints[_currentPointIndex + 1];
    
    final currentLat = current['lat']?.toDouble() ?? 0.0;
    final currentLng = current['lng']?.toDouble() ?? 0.0;
    final nextLat = next['lat']?.toDouble() ?? 0.0;
    final nextLng = next['lng']?.toDouble() ?? 0.0;
    
    return _calculateBearing(currentLat, currentLng, nextLat, nextLng);
  }
  
  /// Вычисляет направление между двумя точками
  double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    const double toRadians = math.pi / 180;
    const double toDegrees = 180 / math.pi;
    
    final dLng = (lng2 - lng1) * toRadians;
    final lat1Rad = lat1 * toRadians;
    final lat2Rad = lat2 * toRadians;
    
    final y = math.sin(dLng) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) - 
              math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLng);
    
    final bearing = math.atan2(y, x) * toDegrees;
    return (bearing + 360) % 360; // Нормализуем к 0-360°
  }
  
  @override
  Future<void> dispose() async {
    _stopPlayback();
    await _positionController.close();
  }
  
  /// Получить информацию о текущем состоянии
  Map<String, dynamic> getPlaybackInfo() {
    return {
      'isActive': _isActive,
      'isPaused': _isPaused,
      'totalPoints': _routePoints.length,
      'currentIndex': _currentPointIndex,
      'progress': _routePoints.isEmpty ? 0.0 : _currentPointIndex / _routePoints.length,
      'speedMultiplier': _speedMultiplier,
      'startTime': _startTime?.toIso8601String(),
    };
  }
}
