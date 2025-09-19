import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../shared/models/sync_progress.dart';
import '../../../shared/models/sync_result.dart';

/// Менеджер изолятов для фоновой синхронизации
class SyncIsolateManager {
  static final Logger _logger = Logger('SyncIsolateManager');

  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  Completer<SyncResult>? _resultCompleter;
  StreamController<SyncProgress>? _progressController;
  Timer? _timeoutTimer;

  /// Запускает операцию синхронизации в изоляте
  Future<SyncResult> runInIsolate(
    String operationId,
    void Function(SyncProgress) onProgress, {
    Map<String, dynamic> context = const {},
    Duration timeout = const Duration(minutes: 30),
  }) async {
    _logger.info('Запуск синхронизации в изоляте: $operationId');

    // Используем compute для простых случаев - это обертка над изолятами
    try {
      final result = await compute(_executeInIsolate, {
        'operationId': operationId,
        'context': context,
      });
      return result;
    } catch (e) {
      _logger.severe('Ошибка в изоляте', e);
      rethrow;
    }
  }

  /// Отменяет выполнение изолята
  Future<void> cancelIsolate() async {
    _logger.info('Отмена синхронизации в изоляте');

    if (_sendPort != null) {
      try {
        _sendPort!.send(_IsolateMessage.cancel());
      } catch (e) {
        _logger.warning('Не удалось отправить сигнал отмены', e);
      }
    }

    await cleanup();
  }

  /// Очищает ресурсы
  Future<void> cleanup() async {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    _receivePort?.close();
    _receivePort = null;

    _progressController?.close();
    _progressController = null;

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    _sendPort = null;

    if (_resultCompleter != null && !_resultCompleter!.isCompleted) {
      _resultCompleter!.completeError(StateError('Синхронизация была отменена'));
    }
  }
}

/// Выполняет операцию в изоляте (статическая функция для compute)
Future<SyncResult> _executeInIsolate(Map<String, dynamic> params) async {
  final operationId = params['operationId'] as String;

  switch (operationId) {
    // Продукты синхронизируются в основном потоке
    default:
      throw UnsupportedError('Неизвестная операция: $operationId');
  }
}

/// Типы сообщений между главным изолятом и рабочим
enum _IsolateMessageType {
  cancel,
}

/// Сообщение для коммуникации между изолятами
class _IsolateMessage {
  final _IsolateMessageType type;

  const _IsolateMessage._({
    required this.type,
  });

  factory _IsolateMessage.cancel() => _IsolateMessage._(
        type: _IsolateMessageType.cancel,
  );
}