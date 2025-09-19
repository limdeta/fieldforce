import 'dart:async';

import 'package:logging/logging.dart';

import '../../../shared/models/sync_progress.dart';
import '../../../shared/models/sync_result.dart';

/// Менеджер прогресса синхронизации
class SyncProgressManager {
  static final Logger _logger = Logger('SyncProgressManager');

  final StreamController<SyncProgress> _progressController;
  final StreamController<SyncResult> _resultController;
  final StreamController<String> _statusController;

  SyncProgress? _lastProgress;
  bool _isActive = false;
  DateTime? _startTime;

  SyncProgressManager()
      : _progressController = StreamController<SyncProgress>.broadcast(),
        _resultController = StreamController<SyncResult>.broadcast(),
        _statusController = StreamController<String>.broadcast();

  /// Stream прогресса синхронизации
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// Stream результатов синхронизации
  Stream<SyncResult> get resultStream => _resultController.stream;

  /// Stream статусов синхронизации
  Stream<String> get statusStream => _statusController.stream;

  /// Текущий прогресс
  SyncProgress? get currentProgress => _lastProgress;

  /// Активна ли синхронизация
  bool get isActive => _isActive;

  /// Время начала синхронизации
  DateTime? get startTime => _startTime;

  /// Обновляет прогресс синхронизации
  void updateProgress(SyncProgress progress) {
    if (!_isActive) {
      _logger.warning('Попытка обновить прогресс неактивной синхронизации');
      return;
    }

    _lastProgress = progress;
    _progressController.add(progress);
    _statusController.add(progress.status);

    _logger.fine('Прогресс обновлен: ${progress.toString()}');
  }

  /// Завершает синхронизацию с результатом
  void completeSync(SyncResult result) {
    if (!_isActive) {
      _logger.warning('Попытка завершить неактивную синхронизацию');
      return;
    }

    _isActive = false;
    _resultController.add(result);

    // Отправляем финальный прогресс
    final finalProgress = SyncProgress.completed(result.totalCount);
    _lastProgress = finalProgress;
    _progressController.add(finalProgress);

    _logger.info('Синхронизация завершена: ${result.toString()}');
  }

  /// Завершает синхронизацию с ошибкой
  void failSync(Object error, [StackTrace? stackTrace]) {
    if (!_isActive) {
      _logger.warning('Попытка завершить с ошибкой неактивную синхронизацию');
      return;
    }

    _isActive = false;

    // Отправляем прогресс с ошибкой
    final errorProgress = SyncProgress.error(error.toString());
    _lastProgress = errorProgress;
    _progressController.add(errorProgress);

    _logger.severe('Синхронизация завершилась с ошибкой', error, stackTrace);
  }

  /// Начинает новую синхронизацию
  void startSync() {
    if (_isActive) {
      _logger.warning('Попытка начать синхронизацию, когда предыдущая активна');
      return;
    }

    _isActive = true;
    _startTime = DateTime.now();
    _lastProgress = SyncProgress.initial();

    _progressController.add(_lastProgress!);
    _statusController.add(_lastProgress!.status);

    _logger.info('Синхронизация начата');
  }

  /// Отменяет текущую синхронизацию
  void cancelSync() {
    if (!_isActive) {
      _logger.warning('Попытка отменить неактивную синхронизацию');
      return;
    }

    _isActive = false;

    // Отправляем статус отмены
    const cancelProgress = SyncProgress(
      current: 0,
      total: 0,
      status: 'Отменено',
      percentage: 0.0,
    );
    _lastProgress = cancelProgress;
    _progressController.add(cancelProgress);
    _statusController.add(cancelProgress.status);

    _logger.info('Синхронизация отменена');
  }

  /// Очищает менеджер для новой синхронизации
  void reset() {
    _isActive = false;
    _startTime = null;
    _lastProgress = null;
  }

  /// Освобождает ресурсы
  void dispose() {
    _progressController.close();
    _resultController.close();
    _statusController.close();
    _logger.fine('SyncProgressManager disposed');
  }
}