import 'dart:convert';

import 'package:equatable/equatable.dart';

class SyncLogEntry extends Equatable {
  const SyncLogEntry({
    required this.id,
    required this.task,
    required this.eventType,
    required this.message,
    required this.createdAt,
    this.status,
    this.durationMs,
    this.regionCode,
    this.tradingPointExternalId,
    this.details,
  });

  final int id;
  final String task;
  final String eventType;
  final String message;
  final String? status;
  final int? durationMs;
  final String? regionCode;
  final String? tradingPointExternalId;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  SyncLogEntry copyWith({
    int? id,
    String? task,
    String? eventType,
    String? message,
    String? status,
    int? durationMs,
    String? regionCode,
    String? tradingPointExternalId,
    Map<String, dynamic>? details,
    DateTime? createdAt,
  }) {
    return SyncLogEntry(
      id: id ?? this.id,
      task: task ?? this.task,
      eventType: eventType ?? this.eventType,
      message: message ?? this.message,
      status: status ?? this.status,
      durationMs: durationMs ?? this.durationMs,
      regionCode: regionCode ?? this.regionCode,
      tradingPointExternalId: tradingPointExternalId ?? this.tradingPointExternalId,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Map<String, dynamic>? decodeDetails(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        task,
        eventType,
        message,
        status,
        durationMs,
        regionCode,
        tradingPointExternalId,
        details,
        createdAt,
      ];
}
