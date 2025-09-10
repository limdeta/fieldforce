import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../domain/entities/user_track.dart';
import '../../domain/entities/compact_track.dart';

/// Сервис для эффективного real-time отображения треков
/// Использует разделение на стабильные и изменяющиеся части
class RealtimeTrackRenderer {
  // Кэши для разных типов данных
  static final Map<String, List<Polyline>> _stableSegmentsCache = {};
  static final Map<String, List<LatLng>> _livePointsCache = {};
  
  // Throttling для уменьшения частоты обновлений
  static Timer? _renderTimer;
  static const Duration _renderThrottle = Duration(milliseconds: 300);
  
  /// Основной метод рендеринга трека с оптимизацией
  static List<Polyline> renderTrack(UserTrack track) {
    if (track.segments.isEmpty) return [];
    
    final polylines = <Polyline>[];
    
    // 1. Рендерим стабильные сегменты (кэшируются навсегда)
    polylines.addAll(_renderStableSegments(track));
    
    // 2. Рендерим live сегмент (обновляется часто)
    polylines.addAll(_renderLiveSegment(track));
    
    // 3. Соединительные линии между сегментами
    polylines.addAll(_renderSegmentConnections(track));
    
    return polylines;
  }
  
  /// Рендерит сохраненные (стабильные) сегменты - кэшируются
  static List<Polyline> _renderStableSegments(UserTrack track) {
    final stableSegmentsCount = track.liveSegmentIndex ?? 0;
    if (stableSegmentsCount == 0) return [];
    
    final cacheKey = '${track.id}_stable_${stableSegmentsCount}';
    
    // Проверяем кэш
    if (_stableSegmentsCache.containsKey(cacheKey)) {
      return _stableSegmentsCache[cacheKey]!;
    }
    
    final polylines = <Polyline>[];
    
    // Рендерим только стабильные сегменты (до live)
    for (int i = 0; i < stableSegmentsCount; i++) {
      final segment = track.segments[i];
      final points = _convertSegmentToPoints(segment);
      
      if (points.length >= 2) {
        polylines.add(Polyline(
          points: points,
          strokeWidth: 4.0,
          color: const Color(0xFFFF1493).withOpacity(0.7), // Стабильные сегменты
        ));
      }
    }
    
    // Кэшируем результат
    _stableSegmentsCache[cacheKey] = polylines;
    _cleanupStableCache();
    
    return polylines;
  }
  
  /// Рендерит live сегмент (текущий буфер) с throttling
  static List<Polyline> _renderLiveSegment(UserTrack track) {
    if (track.liveSegmentIndex == null || 
        track.liveSegmentIndex! >= track.segments.length) {
      return [];
    }
    
    final liveSegment = track.segments[track.liveSegmentIndex!];
    if (liveSegment.isEmpty) return [];
    
    // Группируем точки по 3 для уменьшения частоты обновлений
    final pointGroup = (liveSegment.pointCount / 3).floor();
    final cacheKey = '${track.id}_live_${track.liveSegmentIndex}_${pointGroup}';
    
    // Проверяем кэш live точек
    List<LatLng> points;
    if (_livePointsCache.containsKey(cacheKey)) {
      points = _livePointsCache[cacheKey]!;
    } else {
      points = _convertSegmentToPoints(liveSegment);
      _livePointsCache[cacheKey] = points;
      _cleanupLiveCache();
    }
    
    if (points.length < 2) return [];
    
    return [
      Polyline(
        points: points,
        strokeWidth: 5.0,
        color: const Color(0xFFFF006A).withOpacity(0.9), // Live сегмент ярче
      ),
    ];
  }
  
  /// Рендерит соединительные линии между сегментами
  static List<Polyline> _renderSegmentConnections(UserTrack track) {
    final polylines = <Polyline>[];
    
    for (int i = 0; i < track.segments.length - 1; i++) {
      final currentSegment = track.segments[i];
      final nextSegment = track.segments[i + 1];
      
      if (currentSegment.isNotEmpty && nextSegment.isNotEmpty) {
        final (lat1, lng1) = currentSegment.getCoordinates(currentSegment.pointCount.toInt() - 1);
        final (lat2, lng2) = nextSegment.getCoordinates(0);
        
        // Соединяем если расстояние разумное
        final distance = _calculateDistance(lat1, lng1, lat2, lng2);
        if (distance < 1000) {
          polylines.add(
            Polyline(
              points: [LatLng(lat1, lng1), LatLng(lat2, lng2)],
              color: const Color(0xFFFF1493),
              strokeWidth: 3.0,
            ),
          );
        }
      }
    }
    
    return polylines;
  }
  
  /// Конвертирует сегмент в список точек с оптимизацией
  static List<LatLng> _convertSegmentToPoints(CompactTrack segment) {
    final points = <LatLng>[];
    
    // Прореживание для больших сегментов
    final maxPoints = 100;
    final skipFactor = segment.pointCount > maxPoints
        ? (segment.pointCount / maxPoints).ceil()
        : 1;
    
    for (int i = 0; i < segment.pointCount; i += skipFactor) {
      final (lat, lng) = segment.getCoordinates(i);
      points.add(LatLng(lat, lng));
    }
    
    // Всегда добавляем последнюю точку
    if (segment.pointCount > 1 && skipFactor > 1) {
      final (lat, lng) = segment.getCoordinates(segment.pointCount.toInt() - 1);
      if (points.isEmpty || 
          points.last.latitude != lat || 
          points.last.longitude != lng) {
        points.add(LatLng(lat, lng));
      }
    }
    
    return points;
  }
  
  /// Вычисляет расстояние между двумя точками
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // метры
    final double dLat = (lat2 - lat1) * (3.14159265359 / 180);
    final double dLng = (lng2 - lng1) * (3.14159265359 / 180);
    
    final double a = (dLat / 2) * (dLat / 2) +
        (lat1 * (3.14159265359 / 180)) * (lat2 * (3.14159265359 / 180)) *
        (dLng / 2) * (dLng / 2);
    final double c = 2 * (a.sqrt());
    return earthRadius * c;
  }
  
  /// Очищает кэш стабильных сегментов (ограничивает размер)
  static void _cleanupStableCache() {
    if (_stableSegmentsCache.length > 20) {
      final keysToRemove = _stableSegmentsCache.keys.take(_stableSegmentsCache.length - 20).toList();
      for (final key in keysToRemove) {
        _stableSegmentsCache.remove(key);
      }
    }
  }
  
  /// Очищает кэш live точек (более агрессивно)
  static void _cleanupLiveCache() {
    if (_livePointsCache.length > 10) {
      final keysToRemove = _livePointsCache.keys.take(_livePointsCache.length - 10).toList();
      for (final key in keysToRemove) {
        _livePointsCache.remove(key);
      }
    }
  }
  
  /// Полная очистка всех кэшей
  static void clearAllCaches() {
    _stableSegmentsCache.clear();
    _livePointsCache.clear();
    _renderTimer?.cancel();
  }
  
  /// Очистка кэшей для конкретного трека
  static void clearTrackCaches(int trackId) {
    final stableKeysToRemove = _stableSegmentsCache.keys
        .where((key) => key.startsWith('${trackId}_'))
        .toList();
    final liveKeysToRemove = _livePointsCache.keys
        .where((key) => key.startsWith('${trackId}_'))
        .toList();
    
    for (final key in stableKeysToRemove) {
      _stableSegmentsCache.remove(key);
    }
    for (final key in liveKeysToRemove) {
      _livePointsCache.remove(key);
    }
  }
}

/// Расширение для математических операций (если нужно)
extension _MathExtensions on double {
  double sqrt() {
    if (this < 0) return double.nan;
    double x = this;
    double prev;
    do {
      prev = x;
      x = (x + this / x) / 2;
    } while ((x - prev).abs() > 1e-10);
    return x;
  }
}
