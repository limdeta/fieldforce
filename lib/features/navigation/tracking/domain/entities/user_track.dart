import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';

import '../enums/track_status.dart';
import 'compact_track.dart';

/// Трек (путь) пользователя за определенный период времени с сегментацией
///
/// Представляет собой коллекцию сегментов GPS треков, где каждый сегмент
/// может соответствовать:
/// - Движению между точками маршрута
/// - Остановке у клиента
/// - Временному интервалу
/// - Изменению активности (движение/остановка)
///
/// Сегментация обеспечивает:
/// - Высокую производительность (ленивая загрузка сегментов)
/// - Удобный анализ (отдельная статистика по движению/остановкам)
/// - Эффективный рендеринг (отображение только видимых сегментов)
class UserTrack {
  final int id;
  final NavigationUser user;
  final TrackStatus status;

  final DateTime startTime;
  final DateTime? endTime;

  /// Сегменты трека для оптимальной производительности и анализа
  final List<CompactTrack> segments;

  /// Индекс живого сегмента (который еще может изменяться)
  /// Если null - нет живого сегмента, все сегменты сохранены в БД
  final int? liveSegmentIndex;

  /// Кешированные метаданные для быстрого доступа
  final int totalPoints;
  final double totalDistanceKm;
  final Duration totalDuration;

  final Map<String, dynamic>? metadata;

  const UserTrack({
    required this.id,
    required this.user,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.segments,
    this.liveSegmentIndex,
    required this.totalPoints,
    required this.totalDistanceKm,
    required this.totalDuration,
    this.metadata,
  });

  factory UserTrack.fromSingleTrack({
    required int id,
    required NavigationUser user,
    required CompactTrack track,
    TrackStatus status = TrackStatus.completed,
    Map<String, dynamic>? metadata,
  }) {
    final startTime = track.isEmpty ? DateTime.now() : track.getTimestamp(0);
    final endTime = track.isEmpty ? null : track.getTimestamp(track.pointCount - 1);

    return UserTrack(
      id: id,
      user: user,
      status: status,
      startTime: startTime,
      endTime: endTime,
      segments: [track],
      totalPoints: track.pointCount,
      totalDistanceKm: track.getTotalDistance() / 1000,
      totalDuration: track.getDuration(),
      metadata: metadata,
    );
  }

  factory UserTrack.fromSegments({
    required int id,
    required NavigationUser user,
    required List<CompactTrack> segments,
    TrackStatus status = TrackStatus.completed,
    Map<String, dynamic>? metadata,
  }) {
    if (segments.isEmpty) {
      return UserTrack(
        id: id,
        user: user,
        status: status,
        startTime: DateTime.now(),
        endTime: null,
        segments: [],
        totalPoints: 0,
        totalDistanceKm: 0.0,
        totalDuration: Duration.zero,
        metadata: metadata,
      );
    }

    final nonEmptySegments = segments.where((s) => s.isNotEmpty).toList();
    if (nonEmptySegments.isEmpty) {
      return UserTrack(
        id: id,
        user: user,
        status: status,
        startTime: DateTime.now(),
        endTime: null,
        segments: segments,
        totalPoints: 0,
        totalDistanceKm: 0.0,
        totalDuration: Duration.zero,
        metadata: metadata,
      );
    }

    // Вычисляем общие метрики
    int totalPoints = 0;
    double totalDistance = 0.0;
    Duration totalDuration = Duration.zero;

    for (final segment in segments) {
      totalPoints += segment.pointCount;
      totalDistance += segment.getTotalDistance();
      totalDuration += segment.getDuration();
    }

    final startTime = nonEmptySegments.first.getTimestamp(0);
    final lastSegment = nonEmptySegments.last;
    final endTime = lastSegment.getTimestamp(lastSegment.pointCount - 1);

    return UserTrack(
      id: id,
      user: user,
      status: status,
      startTime: startTime,
      endTime: endTime,
      segments: segments,
      totalPoints: totalPoints,
      totalDistanceKm: totalDistance / 1000,
      totalDuration: totalDuration,
      metadata: metadata,
    );
  }

  /// Создает пустой UserTrack
  factory UserTrack.empty({
    required int id,
    required NavigationUser user,
    TrackStatus status = TrackStatus.active,
    Map<String, dynamic>? metadata,
  }) {
    return UserTrack(
      id: id,
      user: user,
      status: status,
      startTime: DateTime.now(),
      endTime: null,
      segments: [],
      totalPoints: 0,
      totalDistanceKm: 0.0,
      totalDuration: Duration.zero,
      metadata: metadata,
    );
  }

  bool get isActive => status.isActive;
  bool get isCompleted => endTime != null;
  bool get isEmpty => segments.isEmpty || totalPoints == 0;
  bool get isNotEmpty => !isEmpty;
  int get segmentCount => segments.length;

  /// Проверяет является ли сегмент по индексу живым
  bool isSegmentLive(int segmentIndex) {
    return liveSegmentIndex == segmentIndex;
  }

  /// Есть ли живой сегмент в треке
  bool get hasLiveSegment => liveSegmentIndex != null;

  CompactTrack get fullTrack => CompactTrack.merge(segments);

  CompactTrack getSegment(int index) {
    if (index < 0 || index >= segments.length) {
      throw RangeError('Segment index $index out of range 0-${segments.length - 1}');
    }
    return segments[index];
  }

  List<CompactTrack> getSegmentsInTimeRange(DateTime start, DateTime end) {
    final result = <CompactTrack>[];

    for (final segment in segments) {
      if (segment.isEmpty) continue;

      final segmentStart = segment.getTimestamp(0);
      final segmentEnd = segment.getTimestamp(segment.pointCount - 1);

      // Проверяем пересечение временных интервалов
      if (segmentStart.isBefore(end) && segmentEnd.isAfter(start)) {
        result.add(segment);
      }
    }

    return result;
  }

  /// Добавляет новый сегмент к треку (для активных треков)
  UserTrack addSegment(CompactTrack segment) {
    if (isCompleted) {
      throw StateError('Cannot add segment to completed track');
    }

    final newSegments = [...segments, segment];
    final newTotalPoints = totalPoints + segment.pointCount;
    final newTotalDistance = totalDistanceKm + (segment.getTotalDistance() / 1000);
    final newTotalDuration = totalDuration + segment.getDuration();

    // Обновляем endTime если сегмент не пустой
    DateTime? newEndTime = endTime;
    if (segment.isNotEmpty) {
      newEndTime = segment.getTimestamp(segment.pointCount - 1);
    }

    return copyWith(
      segments: newSegments,
      totalPoints: newTotalPoints,
      totalDistanceKm: newTotalDistance,
      totalDuration: newTotalDuration,
      endTime: newEndTime,
    );
  }

  /// Завершает трек (устанавливает endTime)
  UserTrack complete() {
    if (isCompleted) return this;

    final finalEndTime = isEmpty
        ? DateTime.now()
        : segments.last.isEmpty
            ? DateTime.now()
            : segments.last.getTimestamp(segments.last.pointCount - 1);

    return copyWith(endTime: finalEndTime);
  }

  TrackStatistics getStatistics() {
    int movingSegments = 0;
    int stationarySegments = 0;
    double movingDistance = 0.0;
    Duration movingTime = Duration.zero;
    Duration stationaryTime = Duration.zero;

    for (final segment in segments) {
      if (segment.isEmpty) continue;

      final distance = segment.getTotalDistance() / 1000; // в км
      final duration = segment.getDuration();

      // Считаем сегмент движением если средняя скорость > 2 км/ч
      final avgSpeed = duration.inSeconds > 0 ? (distance / duration.inHours) : 0.0;

      if (avgSpeed > 2.0) {
        movingSegments++;
        movingDistance += distance;
        movingTime += duration;
      } else {
        stationarySegments++;
        stationaryTime += duration;
      }
    }

    return TrackStatistics(
      totalSegments: segments.length,
      movingSegments: movingSegments,
      stationarySegments: stationarySegments,
      totalDistanceKm: totalDistanceKm,
      movingDistanceKm: movingDistance,
      totalDuration: totalDuration,
      movingTime: movingTime,
      stationaryTime: stationaryTime,
      averageSpeed: movingTime.inHours > 0 ? (movingDistance / movingTime.inHours) : 0.0,
    );
  }

  /// Создает копию трека с обновленными полями
  UserTrack copyWith({
    int? id,
    NavigationUser? user,
    TrackStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<CompactTrack>? segments,
    int? liveSegmentIndex,
    int? totalPoints,
    double? totalDistanceKm,
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
  }) {
    return UserTrack(
      id: id ?? this.id,
      user: user ?? this.user,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      segments: segments ?? this.segments,
      liveSegmentIndex: liveSegmentIndex ?? this.liveSegmentIndex,
      totalPoints: totalPoints ?? this.totalPoints,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalDuration: totalDuration ?? this.totalDuration,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserTrack(id: $id, user: ${user.firstName} ${user.lastName}, '
           'segments: ${segments.length}, points: $totalPoints, '
           'distance: ${totalDistanceKm.toStringAsFixed(2)}km, '
           'duration: ${totalDuration.toString()}, '
           'active: $isActive)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTrack && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Статистика трека для анализа активности
class TrackStatistics {
  final int totalSegments;
  final int movingSegments;
  final int stationarySegments;
  final double totalDistanceKm;
  final double movingDistanceKm;
  final Duration totalDuration;
  final Duration movingTime;
  final Duration stationaryTime;
  final double averageSpeed;

  const TrackStatistics({
    required this.totalSegments,
    required this.movingSegments,
    required this.stationarySegments,
    required this.totalDistanceKm,
    required this.movingDistanceKm,
    required this.totalDuration,
    required this.movingTime,
    required this.stationaryTime,
    required this.averageSpeed,
  });

  /// Процент времени в движении
  double get movingTimePercentage {
    return totalDuration.inSeconds > 0
        ? (movingTime.inSeconds / totalDuration.inSeconds) * 100
        : 0.0;
  }

  /// Процент времени в остановках
  double get stationaryTimePercentage {
    return totalDuration.inSeconds > 0
        ? (stationaryTime.inSeconds / totalDuration.inSeconds) * 100
        : 0.0;
  }

  @override
  String toString() {
    return 'TrackStatistics('
           'segments: $totalSegments (moving: $movingSegments, stationary: $stationarySegments), '
           'distance: ${totalDistanceKm.toStringAsFixed(2)}km, '
           'time: ${totalDuration.toString()} (moving: ${movingTimePercentage.toStringAsFixed(1)}%), '
           'avg speed: ${averageSpeed.toStringAsFixed(1)} km/h)';
  }
}
