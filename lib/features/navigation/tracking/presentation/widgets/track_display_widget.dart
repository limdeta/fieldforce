import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Виджет для отображения треков на карте
/// Обрабатывает логику преобразования треков в polylines для карты
class TrackDisplayWidget {
  /// Преобразует список треков пользователя в polylines для отображения на карте
  static List<TrackPolyline> convertTracksToPolylines(List<UserTrack> userTracks) {
    final polylines = <TrackPolyline>[];
    
    for (final track in userTracks) {
      if (track.segments.isEmpty) continue;
      
      // Собираем все точки из всех сегментов трека
      final trackPoints = <LatLng>[];
      
      for (final segment in track.segments) {
        for (int i = 0; i < segment.pointCount; i++) {
          final lat = segment.coordinates[i * 2];
          final lng = segment.coordinates[i * 2 + 1];
          trackPoints.add(LatLng(lat, lng));
        }
      }
      
      if (trackPoints.isNotEmpty) {
        polylines.add(TrackPolyline(
          points: trackPoints,
          trackId: track.id,
          trackStatus: track.status,
          color: _getTrackColor(track.status),
          strokeWidth: _getTrackStrokeWidth(track.status),
        ));
      }
    }
    
    return polylines;
  }
  
  /// Получает только активный трек пользователя (если есть)
  static UserTrack? getActiveTrack(List<UserTrack> userTracks) {
    return userTracks.where((track) => track.status.isActive).firstOrNull;
  }
  
  /// Получает завершенные треки пользователя
  static List<UserTrack> getCompletedTracks(List<UserTrack> userTracks) {
    return userTracks.where((track) => track.status == TrackStatus.completed).toList();
  }
  
  /// TODO вынести Фильтрует треки по конкретному маршруту
  // static List<UserTrack> getTracksForRoute(List<UserTrack> userTracks, int routeId) {
  //   return userTracks.where((track) => track.route?.id == routeId).toList();
  // }
  
  /// Определяет цвет трека по статусу
  static Color _getTrackColor(TrackStatus status) {
    switch (status) {
      case TrackStatus.active:
        return Colors.blue.withOpacity(0.8);
      case TrackStatus.completed:
        return Colors.green.withOpacity(0.6);
      case TrackStatus.paused:
        return Colors.orange.withOpacity(0.6);
      case TrackStatus.cancelled:
        return Colors.red.withOpacity(0.6);
    }
  }
  
  /// Определяет толщину линии трека по статусу
  static double _getTrackStrokeWidth(TrackStatus status) {
    switch (status) {
      case TrackStatus.active:
        return 4.0; // Активный трек - толще
      case TrackStatus.completed:
        return 2.5;
      case TrackStatus.paused:
        return 2.5;
      case TrackStatus.cancelled:
        return 2.0;
    }
  }
}

/// Модель для отображения трека на карте
class TrackPolyline {
  final List<LatLng> points;
  final int trackId;
  final TrackStatus trackStatus;
  final Color color;
  final double strokeWidth;
  
  const TrackPolyline({
    required this.points,
    required this.trackId,
    required this.trackStatus,
    required this.color,
    required this.strokeWidth,
  });
  

  bool get isActive => trackStatus.isActive;
  bool get isCompleted => trackStatus == TrackStatus.completed;
}
