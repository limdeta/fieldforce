import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';

class WorkDayMapper {
  static WorkDay fromDb(
    WorkDayData dbWorkDay, {
    required AppUser user,
    shop.Route? route,
    UserTrack? track,
  }) {
    return WorkDay(
      id: dbWorkDay.id,
      user: user,
      date: dbWorkDay.date,
      route: route,
      track: track,
      status: _stringToStatus(dbWorkDay.status),
      startTime: dbWorkDay.startTime,
      endTime: dbWorkDay.endTime,
      metadata: dbWorkDay.metadata != null ? jsonDecode(dbWorkDay.metadata!) as Map<String, dynamic> : null,
    );
  }

  static WorkDaysCompanion toDb(WorkDay workDay) {
    return WorkDaysCompanion(
      user: Value(workDay.user.id),
      date: Value(workDay.date),
      routeId: workDay.route != null ? Value(workDay.route!.id) : const Value.absent(),
      trackId: workDay.track != null ? Value(workDay.track!.id) : const Value.absent(),
      status: Value(_statusToString(workDay.status)),
      startTime: workDay.startTime != null ? Value(workDay.startTime!) : const Value.absent(),
      endTime: workDay.endTime != null ? Value(workDay.endTime!) : const Value.absent(),
      metadata: workDay.metadata != null ? Value(jsonEncode(workDay.metadata!)) : const Value.absent(),
    );
  }

  static WorkDaysCompanion toCompanion(WorkDay workDay) {
    return WorkDaysCompanion(
      user: Value(workDay.user.id),
      date: Value(workDay.date),
      routeId: workDay.route != null ? Value(workDay.route!.id) : const Value.absent(),
      trackId: workDay.track != null ? Value(workDay.track!.id) : const Value.absent(),
      status: Value(_statusToString(workDay.status)),
      startTime: workDay.startTime != null ? Value(workDay.startTime!) : const Value.absent(),
      endTime: workDay.endTime != null ? Value(workDay.endTime!) : const Value.absent(),
      metadata: workDay.metadata != null ? Value(jsonEncode(workDay.metadata!)) : const Value.absent(),
      // createdAt и updatedAt выставляются базой по умолчанию
    );
  }

  static WorkDaysCompanion toCompanionForUpdate(WorkDay workDay) {
    return WorkDaysCompanion(
      user: Value(workDay.user.id),
      date: Value(workDay.date),
      routeId: workDay.route != null ? Value(workDay.route!.id) : const Value.absent(),
      trackId: workDay.track != null ? Value(workDay.track!.id) : const Value.absent(),
      status: Value(_statusToString(workDay.status)),
      startTime: workDay.startTime != null ? Value(workDay.startTime!) : const Value.absent(),
      endTime: workDay.endTime != null ? Value(workDay.endTime!) : const Value.absent(),
      metadata: workDay.metadata != null ? Value(jsonEncode(workDay.metadata!)) : const Value.absent(),
      // id не обновляется, createdAt не обновляется, updatedAt выставляется базой
    );
  }

  static WorkDayStatus _stringToStatus(String status) {
    return WorkDayStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => WorkDayStatus.planned,
    );
  }

  static String _statusToString(WorkDayStatus status) {
    return status.name;
  }
}
