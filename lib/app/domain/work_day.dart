import '../../features/shop/domain/entities/route.dart' as shop;
import '../../features/navigation/tracking/domain/entities/user_track.dart';

/// Рабочий день - объединяет маршрут (план) и GPS трек (факт)
/// 
/// Представляет собой один рабочий день торгового представителя,
/// включающий запланированный маршрут и фактически пройденный путь.
class WorkDay {
  final int id;
  final int userId;
  final DateTime date;
  final shop.Route? plannedRoute;
  /// Фактический GPS трек (может быть null если день еще не начался)
  final UserTrack? actualTrack;
  final WorkDayStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final Map<String, dynamic>? metadata;

  const WorkDay({
    required this.id,
    required this.userId,
    required this.date,
    this.plannedRoute,
    this.actualTrack,
    required this.status,
    this.startTime,
    this.endTime,
    this.metadata,
  });

  WorkDay copyWith({
    int? id,
    int? userId,
    DateTime? date,
    shop.Route? plannedRoute,
    UserTrack? actualTrack,
    WorkDayStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? metadata,
  }) {
    return WorkDay(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      plannedRoute: plannedRoute ?? this.plannedRoute,
      actualTrack: actualTrack ?? this.actualTrack,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool get canStart => status == WorkDayStatus.planned && isToday;
  bool get isActive => status == WorkDayStatus.active;
  bool get isCompleted => status == WorkDayStatus.completed;

  Duration? get duration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  // double get actualDistanceMeters => actualTrack?.totalDistanceMeters ?? 0.0;

  @override
  String toString() {
    return 'WorkDay(date: $date, status: $status, route: ${plannedRoute?.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkDay && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum WorkDayStatus {
  planned,
  active,
  completed,
  cancelled,
}
