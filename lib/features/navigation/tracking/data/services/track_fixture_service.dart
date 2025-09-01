import 'dart:convert';
import 'dart:math' as math;
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';

import '../../domain/entities/compact_track.dart';
import '../../domain/entities/compact_track_builder.dart';
import '../../domain/entities/user_track.dart';
import '../../../../shop/domain/entities/route.dart';

/// Сервис для создания GPS треков из различных форматов данных
/// 
/// Поддерживает:
/// - OSRM responses (JSON)
/// - GPS track arrays
/// - Realistic GPS simulation with noise and timing
class TrackFixtureService {

  /// Создает UserTrack из OSRM JSON response
  static UserTrack createFromOSRMJson({
    required String jsonData,
    required NavigationUser user,
    required int trackId,
    Route? route,
    DateTime? startTime,
    Duration? totalDuration,
    double baseSpeedKmh = 30.0,
    bool addRealisticNoise = true,
  }) {
    final data = json.decode(jsonData);
    
    if (data['code'] != 'Ok' || data['routes'] == null || data['routes'].isEmpty) {
      throw Exception('Invalid OSRM response format');
    }

    final osrmRoute = data['routes'][0];
    final geometry = osrmRoute['geometry'];
    final coordinates = List<List<double>>.from(
      geometry['coordinates'].map((coord) => List<double>.from(coord))
    );

    final compactTrack = _createCompactTrackFromCoordinates(
      coordinates: coordinates,
      startTime: startTime ?? DateTime.now(),
      totalDuration: totalDuration ?? Duration(minutes: coordinates.length ~/ 2),
      baseSpeedKmh: baseSpeedKmh,
      addRealisticNoise: addRealisticNoise,
    );

    return UserTrack.fromSingleTrack(
      id: trackId,
      user: user,
      track: compactTrack,
      metadata: {
        'source': 'osrm_json',
        'original_distance': osrmRoute['distance'],
        'original_duration': osrmRoute['duration'],
        'waypoints_count': data['waypoints']?.length ?? 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Создает UserTrack из массива координат
  static UserTrack createFromCoordinates({
    required List<List<double>> coordinates,
    required NavigationUser user,
    required int trackId,
    Route? route,
    DateTime? startTime,
    Duration? totalDuration,
    double baseSpeedKmh = 30.0,
    bool addRealisticNoise = true,
  }) {
    final compactTrack = _createCompactTrackFromCoordinates(
      coordinates: coordinates,
      startTime: startTime ?? DateTime.now(),
      totalDuration: totalDuration ?? Duration(minutes: coordinates.length ~/ 2),
      baseSpeedKmh: baseSpeedKmh,
      addRealisticNoise: addRealisticNoise,
    );

    return UserTrack.fromSingleTrack(
      id: trackId,
      user: user,
      track: compactTrack,
      metadata: {
        'source': 'coordinates_array',
        'points_count': coordinates.length,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Создает сегментированный UserTrack с остановками
  static UserTrack createWithStops({
    required List<List<double>> coordinates,
    required NavigationUser user,
    required int trackId,
    Route? route,
    DateTime? startTime,
    List<int>? stopIndices, // Индексы точек где были остановки
    List<Duration>? stopDurations, // Длительность каждой остановки
    double baseSpeedKmh = 30.0,
    bool addRealisticNoise = true,
  }) {
    final startDateTime = startTime ?? DateTime.now();
    final segments = <CompactTrack>[];
    
    // Разбиваем координаты на сегменты по остановкам
    int lastIndex = 0;
    final actualStopIndices = stopIndices ?? [];
    final actualStopDurations = stopDurations ?? [];

    for (int i = 0; i < actualStopIndices.length; i++) {
      final stopIndex = actualStopIndices[i];
      if (stopIndex > lastIndex && stopIndex < coordinates.length) {
        // Создаем сегмент до остановки
        final segmentCoords = coordinates.sublist(lastIndex, stopIndex + 1);
        final segmentDuration = Duration(
          minutes: (segmentCoords.length * 60 / baseSpeedKmh * 0.6).round(),
        );
        
        final segmentStartTime = startDateTime.add(
          Duration(seconds: segments.fold(0, (sum, seg) => sum + seg.getDuration().inSeconds))
        );

        final segment = _createCompactTrackFromCoordinates(
          coordinates: segmentCoords,
          startTime: segmentStartTime,
          totalDuration: segmentDuration,
          baseSpeedKmh: baseSpeedKmh,
          addRealisticNoise: addRealisticNoise,
        );

        segments.add(segment);
        lastIndex = stopIndex;

        // Добавляем время остановки к следующему сегменту
        if (i < actualStopDurations.length) {
          // Остановка может быть представлена как сегмент из одной точки
          final stopSegment = _createStopSegment(
            coordinate: coordinates[stopIndex],
            startTime: segmentStartTime.add(segmentDuration),
            duration: actualStopDurations[i],
          );
          segments.add(stopSegment);
        }
      }
    }

    // Добавляем последний сегмент
    if (lastIndex < coordinates.length - 1) {
      final finalCoords = coordinates.sublist(lastIndex);
      final finalDuration = Duration(
        minutes: (finalCoords.length * 60 / baseSpeedKmh * 0.6).round(),
      );
      
      final finalStartTime = startDateTime.add(
        Duration(seconds: segments.fold(0, (sum, seg) => sum + seg.getDuration().inSeconds))
      );

      final finalSegment = _createCompactTrackFromCoordinates(
        coordinates: finalCoords,
        startTime: finalStartTime,
        totalDuration: finalDuration,
        baseSpeedKmh: baseSpeedKmh,
        addRealisticNoise: addRealisticNoise,
      );

      segments.add(finalSegment);
    }

    return UserTrack.fromSegments(
      id: trackId,
      user: user,
      route: route,
      segments: segments,
      metadata: {
        'source': 'coordinates_with_stops',
        'segments_count': segments.length,
        'stops_count': actualStopIndices.length,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Создает CompactTrack из координат с реалистичным GPS шумом
  static CompactTrack _createCompactTrackFromCoordinates({
    required List<List<double>> coordinates,
    required DateTime startTime,
    required Duration totalDuration,
    double baseSpeedKmh = 30.0,
    bool addRealisticNoise = true,
  }) {
    if (coordinates.isEmpty) {
      return CompactTrack.empty();
    }

    final builder = CompactTrackBuilder();
    final random = math.Random();
    final totalSeconds = totalDuration.inSeconds;
    final timePerPoint = totalSeconds / coordinates.length;

    for (int i = 0; i < coordinates.length; i++) {
      final coord = coordinates[i];
      double lat = coord[1]; // OSRM format: [lon, lat]
      double lon = coord[0];

      // Добавляем реалистичный GPS шум
      if (addRealisticNoise) {
        // GPS точность: ±3-5 метров (примерно ±0.00003-0.00005 градусов)
        final latNoise = (random.nextDouble() - 0.5) * 0.0001;
        final lonNoise = (random.nextDouble() - 0.5) * 0.0001;
        lat += latNoise;
        lon += lonNoise;
      }

      // Рассчитываем время для этой точки
      final pointTime = startTime.add(Duration(seconds: (i * timePerPoint).round()));

      // Рассчитываем скорость с вариацией
      double speed = baseSpeedKmh;
      if (addRealisticNoise && i > 0) {
        // Вариация скорости ±30%
        final speedVariation = 1.0 + (random.nextDouble() - 0.5) * 0.6;
        speed *= speedVariation;
        speed = speed.clamp(5.0, baseSpeedKmh * 1.5); // Ограничиваем разумными пределами
      }

      // Рассчитываем точность GPS (реалистичное значение)
      final accuracy = addRealisticNoise 
          ? 3.0 + random.nextDouble() * 7.0  // 3-10 метров
          : 5.0;

      // Рассчитываем направление (bearing)
      double? bearing;
      if (i > 0) {
        final prevCoord = coordinates[i - 1];
        bearing = _calculateBearing(
          prevCoord[1], prevCoord[0], // предыдущая точка
          lat, lon, // текущая точка
        );
      }

      builder.addPoint(
        latitude: lat,
        longitude: lon,
        timestamp: pointTime,
        accuracy: accuracy,
        speedKmh: speed,
        bearing: bearing,
      );
    }

    return builder.build();
  }

  /// Создает сегмент остановки (одна точка на определенное время)
  static CompactTrack _createStopSegment({
    required List<double> coordinate,
    required DateTime startTime,
    required Duration duration,
  }) {
    final builder = CompactTrackBuilder();
    final random = math.Random();
    
    // Создаем несколько точек для остановки (каждые 30 секунд)
    final pointInterval = Duration(seconds: 30);
    final pointCount = (duration.inSeconds / pointInterval.inSeconds).ceil();
    
    for (int i = 0; i < pointCount; i++) {
      final pointTime = startTime.add(Duration(seconds: i * pointInterval.inSeconds));
      
      // Небольшой шум для реалистичности (человек не стоит абсолютно неподвижно)
      final lat = coordinate[1] + (random.nextDouble() - 0.5) * 0.00002; // ±2 метра
      final lon = coordinate[0] + (random.nextDouble() - 0.5) * 0.00002;
      
      builder.addPoint(
        latitude: lat,
        longitude: lon,
        timestamp: pointTime,
        accuracy: 3.0 + random.nextDouble() * 2.0, // хорошая точность в покое
        speedKmh: 0.0, // стоим
        bearing: null,
      );
    }

    return builder.build();
  }

  /// Рассчитывает направление (bearing) между двумя точками
  static double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = lat1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;
    final deltaLonRad = (lon2 - lon1) * math.pi / 180;

    final x = math.sin(deltaLonRad) * math.cos(lat2Rad);
    final y = math.cos(lat1Rad) * math.sin(lat2Rad) - 
              math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);

    final bearingRad = math.atan2(x, y);
    final bearingDeg = bearingRad * 180 / math.pi;

    return (bearingDeg + 360) % 360; // Нормализуем к 0-360 градусов
  }

  /// Читает OSRM JSON из файла и создает UserTrack
  static Future<UserTrack> createFromJsonFile({
    required String filePath,
    required NavigationUser user,
    required int trackId,
    Route? route,
    DateTime? startTime,
    Duration? totalDuration,
    double baseSpeedKmh = 30.0,
    bool addRealisticNoise = true,
  }) async {
    // Эта функция может быть реализована для чтения файлов
    // Пока возвращаем заглушку
    throw UnimplementedError('File reading not implemented in this context');
  }
}
