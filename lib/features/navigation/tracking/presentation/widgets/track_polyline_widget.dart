import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../domain/entities/user_track.dart';
import '../services/track_visualization_service.dart';

/// Виджет для отрисовки GPS треков на карте в виде полилиний
class TrackPolylineWidget extends StatelessWidget {
  final List<UserTrack> tracks;
  final bool showOnlyActive;
  final int? routeId; // Фильтр по конкретному маршруту
  final double strokeWidth;
  final double opacity;

  const TrackPolylineWidget({
    super.key,
    required this.tracks,
    this.showOnlyActive = false,
    this.routeId,
    this.strokeWidth = 3.0,
    this.opacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    // Фильтруем треки для отображения
    final filteredTracks = TrackVisualizationService.filterTracksForDisplay(
      tracks,
      showOnlyActive: showOnlyActive,
      routeId: routeId,
    );

    if (filteredTracks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Преобразуем треки в полилинии
    final polylines = <Polyline>[];
    
    for (final track in filteredTracks) {
      final points = TrackVisualizationService.convertTrackToPolylinePoints(track);
      
      if (points.length < 2) continue; // Нужно минимум 2 точки для линии
      
      final color = TrackVisualizationService.getTrackColor(track);
      
      polylines.add(
        Polyline(
          points: points,
          color: color.withValues(alpha: opacity),
          strokeWidth: strokeWidth,
          // Дополнительные стили для лучшей видимости
          borderColor: Colors.white.withValues(alpha: 0.5),
          borderStrokeWidth: strokeWidth + 1.0,
        ),
      );
    }

    return PolylineLayer(polylines: polylines);
  }
}

/// Вспомогательный виджет для простого отображения одного трека
class SingleTrackPolylineWidget extends StatelessWidget {
  final UserTrack track;
  final Color? color;
  final double strokeWidth;
  final double opacity;

  const SingleTrackPolylineWidget({
    super.key,
    required this.track,
    this.color,
    this.strokeWidth = 3.0,
    this.opacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    final points = TrackVisualizationService.convertTrackToPolylinePoints(track);
    
    if (points.length < 2) {
      return const SizedBox.shrink();
    }
    
    final trackColor = color ?? TrackVisualizationService.getTrackColor(track);
    
    return PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          color: trackColor.withValues(alpha: opacity),
          strokeWidth: strokeWidth,
          borderColor: Colors.white.withValues(alpha: 0.5),
          borderStrokeWidth: strokeWidth + 1.0,
        ),
      ],
    );
  }
}
