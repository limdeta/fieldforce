import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/user_track.dart';
import '../../domain/entities/compact_track.dart';
import '../../domain/enums/track_status.dart';

/// Сервис для подготовки данных треков для визуализации на карте
class TrackVisualizationService {
  
  /// Конвертирует UserTrack в список координат для отрисовки на карте
  static List<LatLng> convertTrackToPolylinePoints(UserTrack track) {
    final points = <LatLng>[];
    
    for (final segment in track.segments) {
      points.addAll(_convertCompactTrackToPoints(segment));
    }
    
    return points;
  }
  
  /// Конвертирует CompactTrack в координаты
  static List<LatLng> _convertCompactTrackToPoints(CompactTrack compactTrack) {
    final points = <LatLng>[];
    
    for (int i = 0; i < compactTrack.pointCount; i++) {
      final (lat, lng) = compactTrack.getCoordinates(i);
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }
  
  /// Получает цвет трека в зависимости от его статуса и типа
  static Color getTrackColor(UserTrack track) {
    switch (track.status) {
      case TrackStatus.active:
        return Colors.blue;
      case TrackStatus.completed:
        return Colors.green;
      case TrackStatus.paused:
        return Colors.orange;
      case TrackStatus.cancelled:
        return Colors.red;
    }
  }
  
  /// Фильтрует треки для отображения (например, только активные)
  static List<UserTrack> filterTracksForDisplay(List<UserTrack> tracks, {
    bool showOnlyActive = false,
    int? routeId,
  }) {
    return tracks.where((track) {
      // Фильтр по активности
      if (showOnlyActive && !track.status.isActive) {
        return false;
      }
      
      // Фильтр по маршруту
      // if (routeId != null && track.route?.id != routeId) {
      //   return false;
      // }
      
      return true;
    }).toList();
  }
}
