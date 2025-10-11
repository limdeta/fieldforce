import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_log_entry.dart';

class SyncLogRepository {
  SyncLogRepository(this._database);

  final AppDatabase _database;

  static const int _defaultLimit = 200;

  Future<int> logEvent({
    required String task,
    required String eventType,
    required String message,
    String? status,
    Duration? duration,
    Map<String, dynamic>? details,
    String? regionCode,
    String? tradingPointExternalId,
    DateTime? timestamp,
  }) async {
    final companion = SyncLogsCompanion(
      task: Value(task),
      eventType: Value(eventType),
      status: Value(status),
      message: Value(message),
      detailsJson: Value(details == null ? null : jsonEncode(details)),
      regionCode: Value(regionCode),
      tradingPointExternalId: Value(tradingPointExternalId),
      durationMs: Value(duration?.inMilliseconds),
      createdAt: Value(timestamp ?? DateTime.now()),
    );

    return _database.into(_database.syncLogs).insert(companion);
  }

  Future<List<SyncLogEntry>> getRecentLogs({int limit = _defaultLimit, String? task}) async {
    final query = _database.select(_database.syncLogs)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);

    if (task != null && task.isNotEmpty) {
      query.where((tbl) => tbl.task.equals(task));
    }

    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  Stream<List<SyncLogEntry>> watchRecentLogs({int limit = _defaultLimit, String? task}) {
    final query = _database.select(_database.syncLogs)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);

    if (task != null && task.isNotEmpty) {
      query.where((tbl) => tbl.task.equals(task));
    }

    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  Future<List<String>> getAvailableTasks() async {
    final rows = await _database
        .customSelect('SELECT DISTINCT task FROM sync_logs ORDER BY task ASC')
        .get();

    return rows
        .map((row) => row.read<String>('task'))
        .where((task) => task.isNotEmpty)
        .toList();
  }

  Future<SyncLogEntry?> getLastSuccessEntryForTask(
    String task, {
    String? regionCode,
    String? tradingPointExternalId,
  }) async {
    final query = _database.select(_database.syncLogs)
      ..where((tbl) => tbl.task.equals(task) & tbl.status.equals('success'))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(1);

    if (regionCode != null) {
      query.where((tbl) => tbl.regionCode.equals(regionCode));
    }

    if (tradingPointExternalId != null) {
      query.where((tbl) => tbl.tradingPointExternalId.equals(tradingPointExternalId));
    }

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

  Future<void> clear() async {
    await _database.delete(_database.syncLogs).go();
  }

  SyncLogEntry _mapRow(SyncLogRow row) {
    Map<String, dynamic>? details;
    if (row.detailsJson != null) {
      try {
        final decoded = jsonDecode(row.detailsJson!);
        if (decoded is Map<String, dynamic>) {
          details = decoded;
        }
      } catch (_) {
        details = null;
      }
    }

    return SyncLogEntry(
      id: row.id,
      task: row.task,
      eventType: row.eventType,
      status: row.status,
      message: row.message,
      durationMs: row.durationMs,
      regionCode: row.regionCode,
      tradingPointExternalId: row.tradingPointExternalId,
      details: details,
      createdAt: row.createdAt,
    );
  }
}
