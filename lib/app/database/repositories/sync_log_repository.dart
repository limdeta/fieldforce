import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_log_entry.dart';
import 'package:fixnum/fixnum.dart';

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
      detailsJson: Value(details == null ? null : _safeJsonEncode(details)),
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

  /// Безопасно сериализует объект в JSON, обрабатывая Int64 и другие проблемные типы
  String _safeJsonEncode(Map<String, dynamic> details) {
    try {
      return jsonEncode(_sanitizeForJson(details));
    } catch (e) {
      // Если сериализация не удалась, создаем упрощенную версию
      return jsonEncode({
        'error': 'Failed to serialize details',
        'details_summary': details.keys.map((key) => '$key: ${details[key].runtimeType}').join(', '),
      });
    }
  }

  /// Рекурсивно обрабатывает объект, заменяя несериализуемые типы на строковые представления
  dynamic _sanitizeForJson(dynamic obj) {
    if (obj == null) return null;
    
    if (obj is Int64) {
      return obj.toInt();
    }
    
    if (obj is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      for (final entry in obj.entries) {
        result[entry.key] = _sanitizeForJson(entry.value);
      }
      return result;
    }
    
    if (obj is List) {
      return obj.map(_sanitizeForJson).toList();
    }
    
    if (obj is String || obj is int || obj is double || obj is bool) {
      return obj;
    }
    
    // Для всех остальных типов возвращаем строковое представление
    return obj.toString();
  }
}
