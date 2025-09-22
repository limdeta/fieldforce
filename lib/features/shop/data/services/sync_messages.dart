// lib/features/shop/data/services/sync_messages.dart

/// Типы сообщений между главным изолятом и worker изолятом синхронизации
class SyncMessage {
  final String type;
  final Map<String, dynamic> data;

  const SyncMessage({
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
  };

  factory SyncMessage.fromJson(Map<String, dynamic> json) {
    return SyncMessage(
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }
}

/// Команды от главного изолята к worker изоляту
class SyncCommands {
  static const String startProductSync = 'start_product_sync';
  static const String startCategorySync = 'start_category_sync';
  static const String pauseSync = 'pause_sync';
  static const String resumeSync = 'resume_sync';
  static const String cancelSync = 'cancel_sync';
  static const String shutdown = 'shutdown';
}

/// Ответы от worker изолята к главному изоляту
class SyncResponses {
  static const String initialized = 'initialized';
  static const String progress = 'progress';
  static const String completed = 'completed';
  static const String error = 'error';
  static const String paused = 'paused';
  static const String resumed = 'resumed';
  static const String cancelled = 'cancelled';
  static const String heartbeat = 'heartbeat';
}

SyncMessage createStartProductSyncMessage({
  required Map<String, dynamic> config,
  required String apiUrl,
  required String? sessionCookie,
}) {
  return SyncMessage(
    type: SyncCommands.startProductSync,
    data: {
      'config': config,
      'apiUrl': apiUrl,
      'sessionCookie': sessionCookie,
    },
  );
}

SyncMessage createStartCategorySyncMessage({
  required Map<String, dynamic> config,
  required String apiUrl,
  required String? sessionCookie,
}) {
  return SyncMessage(
    type: SyncCommands.startCategorySync,
    data: {
      'config': config,
      'apiUrl': apiUrl,
      'sessionCookie': sessionCookie,
    },
  );
}

SyncMessage createProgressMessage({
  required String syncType,
  required int current,
  required int total,
  required String status,
  double? percentage,
}) {
  return SyncMessage(
    type: SyncResponses.progress,
    data: {
      'syncType': syncType,
      'current': current,
      'total': total,
      'status': status,
      'percentage': percentage ?? (total > 0 ? current / total : 0.0),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}

SyncMessage createResultMessage({
  required String syncType,
  required bool success,
  required int successCount,
  int? errorCount,
  List<String>? errors,
  required int durationMs,
}) {
  return SyncMessage(
    type: SyncResponses.completed,
    data: {
      'syncType': syncType,
      'success': success,
      'successCount': successCount,
      'errorCount': errorCount ?? 0,
      'errors': errors ?? [],
      'durationMs': durationMs,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}

SyncMessage createErrorMessage({
  required String syncType,
  required String error,
  required String stackTrace,
}) {
  return SyncMessage(
    type: SyncResponses.error,
    data: {
      'syncType': syncType,
      'error': error,
      'stackTrace': stackTrace,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}