import 'dart:typed_data';
import 'dart:math' as math;

/// Компактное хранение GPS треков для высокой производительности
/// Использует плоские массивы вместо объектов для минимизации memory overhead
class CompactTrack {
  /// Координаты в формате [lat1, lng1, lat2, lng2, ...]
  final Float64List coordinates;
  
  final Int64List timestamps;
  
  final Float32List speeds;
  
  final Float32List accuracies;
  
  final Float32List bearings;

  CompactTrack({
    required this.coordinates,
    required this.timestamps,
    required this.speeds,
    required this.accuracies,
    required this.bearings,
  }) {
    // Проверяем консистентность данных
    final expectedLength = coordinates.length ~/ 2;
    assert(timestamps.length == expectedLength, 'Timestamps length mismatch');
    assert(speeds.length == expectedLength, 'Speeds length mismatch');
    assert(accuracies.length == expectedLength, 'Accuracies length mismatch');
    assert(bearings.length == expectedLength, 'Bearings length mismatch');
  }

  int get pointCount => timestamps.length;

  bool get isEmpty => pointCount == 0;

  bool get isNotEmpty => pointCount > 0;

  /// Получает координаты точки по индексу
  (double lat, double lng) getCoordinates(int index) {
    assert(index >= 0 && index < pointCount, 'Index out of bounds');
    final coordIndex = index * 2;
    return (coordinates[coordIndex], coordinates[coordIndex + 1]);
  }

  /// Получает временную метку по индексу
  DateTime getTimestamp(int index) {
    assert(index >= 0 && index < pointCount, 'Index out of bounds');
    return DateTime.fromMillisecondsSinceEpoch(timestamps[index]);
  }

  /// Получает скорость по индексу (может быть null)
  double? getSpeed(int index) {
    assert(index >= 0 && index < pointCount, 'Index out of bounds');
    final speed = speeds[index];
    return speed == -1 ? null : speed.toDouble();
  }

  /// Получает точность GPS по индексу (может быть null)
  double? getAccuracy(int index) {
    assert(index >= 0 && index < pointCount, 'Index out of bounds');
    final accuracy = accuracies[index];
    return accuracy == -1 ? null : accuracy.toDouble();
  }

  /// Получает направление движения по индексу (может быть null)
  double? getBearing(int index) {
    assert(index >= 0 && index < pointCount, 'Index out of bounds');
    final bearing = bearings[index];
    return bearing == -1 ? null : bearing.toDouble();
  }


  /// Создает подтрек с указанного диапазона индексов
  CompactTrack subtrack(int startIndex, int endIndex) {
    assert(startIndex >= 0 && startIndex <= endIndex && endIndex <= pointCount, 
           'Invalid range');
    
    final coordStart = startIndex * 2;
    final coordEnd = endIndex * 2;
    
    return CompactTrack(
      coordinates: Float64List.sublistView(coordinates, coordStart, coordEnd),
      timestamps: Int64List.sublistView(timestamps, startIndex, endIndex),
      speeds: Float32List.sublistView(speeds, startIndex, endIndex),
      accuracies: Float32List.sublistView(accuracies, startIndex, endIndex),
      bearings: Float32List.sublistView(bearings, startIndex, endIndex),
    );
  }

  /// Вычисляет общую дистанцию трека в метрах (приблизительно)
  double getTotalDistance() {
    if (pointCount < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 1; i < pointCount; i++) {
      final (lat1, lng1) = getCoordinates(i - 1);
      final (lat2, lng2) = getCoordinates(i);
      totalDistance += _calculateDistance(lat1, lng1, lat2, lng2);
    }
    return totalDistance;
  }

  /// Получает продолжительность трека
  Duration getDuration() {
    if (pointCount < 2) return Duration.zero;
    return getTimestamp(pointCount - 1).difference(getTimestamp(0));
  }

  /// Объединяет множество CompactTrack в один трек
  static CompactTrack merge(List<CompactTrack> segments) {
    if (segments.isEmpty) {
      return CompactTrack.empty();
    }
    
    if (segments.length == 1) {
      return segments.first;
    }

    // Подсчитываем общее количество точек
    int totalPoints = 0;
    for (final segment in segments) {
      totalPoints += segment.pointCount;
    }

    // Создаем объединенные массивы
    final coordinates = Float64List(totalPoints * 2);
    final timestamps = Int64List(totalPoints);
    final speeds = Float32List(totalPoints);
    final accuracies = Float32List(totalPoints);
    final bearings = Float32List(totalPoints);

    int offset = 0;
    for (final segment in segments) {
      if (segment.isEmpty) continue;
      
      final count = segment.pointCount;
      
      // Копируем координаты
      for (int i = 0; i < count * 2; i++) {
        coordinates[offset * 2 + i] = segment.coordinates[i];
      }
      
      // Копируем остальные данные
      for (int i = 0; i < count; i++) {
        timestamps[offset + i] = segment.timestamps[i];
        speeds[offset + i] = segment.speeds[i];
        accuracies[offset + i] = segment.accuracies[i];
        bearings[offset + i] = segment.bearings[i];
      }
      
      offset += count;
    }

    return CompactTrack(
      coordinates: coordinates,
      timestamps: timestamps,
      speeds: speeds,
      accuracies: accuracies,
      bearings: bearings,
    );
  }

  /// Создает пустой трек
  static CompactTrack empty() {
    return CompactTrack(
      coordinates: Float64List(0),
      timestamps: Int64List(0),
      speeds: Float32List(0),
      accuracies: Float32List(0),
      bearings: Float32List(0),
    );
  }

  /// Вычисляет расстояние между двумя точками по формуле Haversine (в метрах)
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // метры
    
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLng = (lng2 - lng1) * (math.pi / 180);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1 * (math.pi / 180)) * 
              math.cos(lat2 * (math.pi / 180)) *
              math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  @override
  String toString() {
    return 'CompactTrack(points: $pointCount, '
           'duration: ${getDuration()}, '
           'distance: ${(getTotalDistance() / 1000).toStringAsFixed(2)}km)';
  }

  // =====================================================
  // DATABASE SERIALIZATION - Бинарная сериализация для БД
  // =====================================================
  
  /// Сериализует координаты в бинарный формат для хранения в БД
  Uint8List serializeCoordinates() {
    return coordinates.buffer.asUint8List();
  }
  
  /// Сериализует временные метки в бинарный формат для хранения в БД
  Uint8List serializeTimestamps() {
    return timestamps.buffer.asUint8List();
  }
  
  /// Сериализует скорости в бинарный формат для хранения в БД
  Uint8List serializeSpeeds() {
    return speeds.buffer.asUint8List();
  }
  
  /// Сериализует точности в бинарный формат для хранения в БД
  Uint8List serializeAccuracies() {
    return accuracies.buffer.asUint8List();
  }
  
  /// Сериализует направления в бинарный формат для хранения в БД
  Uint8List serializeBearings() {
    return bearings.buffer.asUint8List();
  }
  
  /// Создает CompactTrack из бинарных данных БД
  factory CompactTrack.fromDatabase({
    required Uint8List coordinatesBlob,
    required Uint8List timestampsBlob,
    required Uint8List speedsBlob,
    required Uint8List accuraciesBlob,
    required Uint8List bearingsBlob,
  }) {
    return CompactTrack(
      coordinates: coordinatesBlob.buffer.asFloat64List(),
      timestamps: timestampsBlob.buffer.asInt64List(),
      speeds: speedsBlob.buffer.asFloat32List(),
      accuracies: accuraciesBlob.buffer.asFloat32List(),
      bearings: bearingsBlob.buffer.asFloat32List(),
    );
  }
}
