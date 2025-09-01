import 'dart:typed_data';
import 'dart:math' as math;
import 'compact_track.dart';

/// Билдер для создания CompactTrack из различных источников данных
class CompactTrackBuilder {
  final List<double> _coordinates = [];
  final List<int> _timestamps = [];
  final List<double> _speeds = [];
  final List<double> _accuracies = [];
  final List<double> _bearings = [];

  /// Добавляет точку в трек
  void addPoint({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    double? speedKmh,
    double? accuracy,
    double? bearing,
  }) {
    _coordinates.addAll([latitude, longitude]);
    _timestamps.add(timestamp.millisecondsSinceEpoch);
    _speeds.add(speedKmh ?? -1);
    _accuracies.add(accuracy ?? -1);
    _bearings.add(bearing ?? -1);
  }

  /// Количество точек в билдере
  int get pointCount => _timestamps.length;

  /// Проверяет пустой ли билдер
  bool get isEmpty => pointCount == 0;

  /// Очищает билдер
  void clear() {
    _coordinates.clear();
    _timestamps.clear();
    _speeds.clear();
    _accuracies.clear();
    _bearings.clear();
  }

  /// Строит CompactTrack из накопленных данных
  CompactTrack build() {
    if (isEmpty) {
      return CompactTrackFactory.empty();
    }

    return CompactTrack(
      coordinates: Float64List.fromList(_coordinates),
      timestamps: Int64List.fromList(_timestamps),
      speeds: Float32List.fromList(_speeds),
      accuracies: Float32List.fromList(_accuracies),
      bearings: Float32List.fromList(_bearings),
    );
  }

  /// Строит и очищает билдер
  CompactTrack buildAndClear() {
    final track = build();
    clear();
    return track;
  }
}

/// Фабричные методы для создания CompactTrack
class CompactTrackFactory {
  /// Создает пустой CompactTrack
  static CompactTrack empty() {
    return CompactTrack(
      coordinates: Float64List(0),
      timestamps: Int64List(0),
      speeds: Float32List(0),
      accuracies: Float32List(0),
      bearings: Float32List(0),
    );
  }

  /// Создает CompactTrack из OSRM ответа
  static CompactTrack fromOSRMResponse(
    Map<String, dynamic> osrmResponse, {
    DateTime? startTime,
    double baseSpeed = 25.0,
    double baseAccuracy = 5.0,
  }) {
    final coordinates = osrmResponse['routes']?[0]?['geometry']?['coordinates'] as List?;
    if (coordinates == null || coordinates.isEmpty) {
      return empty();
    }

    final builder = CompactTrackBuilder();
    final start = startTime ?? DateTime.now().subtract(const Duration(hours: 2));

    for (int i = 0; i < coordinates.length; i++) {
      final coord = coordinates[i] as List;
      final lng = coord[0].toDouble();
      final lat = coord[1].toDouble();
      
      // Симулируем реалистичное время между точками (2-5 секунд)
      final secondsOffset = i * (2 + (i % 4));
      final timestamp = start.add(Duration(seconds: secondsOffset));
      
      // Добавляем вариацию к скорости (±10 км/ч)
      final speedVariation = (i % 7 - 3) * 3.0;
      final speed = baseSpeed + speedVariation;
      
      // Симулируем GPS точность (3-8 метров)
      final accuracy = baseAccuracy + (i % 3);
      
      // Вычисляем приблизительное направление движения
      double? bearing;
      if (i > 0) {
        final prevCoord = coordinates[i - 1] as List;
        final prevLng = prevCoord[0].toDouble();
        final prevLat = prevCoord[1].toDouble();
        bearing = _calculateBearing(prevLat, prevLng, lat, lng);
      }

      builder.addPoint(
        latitude: lat,
        longitude: lng,
        timestamp: timestamp,
        speedKmh: speed > 0 ? speed : null,
        accuracy: accuracy,
        bearing: bearing,
      );
    }

    return builder.build();
  }

  /// Вычисляет направление движения между двумя точками
  static double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
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
}
