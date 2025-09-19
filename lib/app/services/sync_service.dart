import 'dart:async';
import 'dart:isolate';

import 'package:logging/logging.dart';

import '../../../shared/models/sync_config.dart';
import '../../../shared/models/sync_progress.dart';
import '../../../shared/models/sync_result.dart';
import 'session_manager.dart';
import 'sync_isolate_manager.dart';
import 'sync_progress_manager.dart';

/// Сервис для управления синхронизацией данных
abstract class SyncService {
  /// Stream прогресса синхронизации
  Stream<SyncProgress> get syncProgress;

  /// Stream результатов синхронизации
  Stream<SyncResult> get syncResults;

  /// Stream статусов синхронизации
  Stream<String> get syncStatus;

  /// Синхронизирует данные согласно конфигурации
  Future<SyncResult> sync(SyncConfig config);

  /// Отменяет текущую синхронизацию
  Future<void> cancel();

  /// Ставит синхронизацию на паузу
  Future<void> pause();

  /// Возобновляет синхронизацию
  Future<void> resume();

  /// Активна ли синхронизация
  bool get isActive;

  /// На паузе ли синхронизация
  bool get isPaused;
}

/// Базовая реализация сервиса синхронизации
class BaseSyncService implements SyncService {
  static final Logger _logger = Logger('BaseSyncService');

  final SessionManager _sessionManager;
  final SyncIsolateManager _isolateManager;
  final SyncProgressManager _progressManager;

  bool _isPaused = false;
  Completer<void>? _pauseCompleter;

  BaseSyncService({
    required SessionManager sessionManager,
    required SyncIsolateManager isolateManager,
    required SyncProgressManager progressManager,
  })  : _sessionManager = sessionManager,
        _isolateManager = isolateManager,
        _progressManager = progressManager;

  @override
  Stream<SyncProgress> get syncProgress => _progressManager.progressStream;

  @override
  Stream<SyncResult> get syncResults => _progressManager.resultStream;

  @override
  Stream<String> get syncStatus => _progressManager.statusStream;

  @override
  bool get isActive => _progressManager.isActive;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<SyncResult> sync(SyncConfig config) async {
    if (isActive) {
      throw StateError('Синхронизация уже активна');
    }

    _logger.info('Начало синхронизации с конфигом: $config');

    try {
      // Проверяем сессию
      final sessionValid = await _validateSession();
      if (!sessionValid) {
        throw StateError('Сессия недействительна, требуется повторная аутентификация');
      }

      // Начинаем синхронизацию
      _progressManager.startSync();
      _isPaused = false;

      // Временно выполняем синхронизацию в основном потоке для отладки
      final result = await _performSyncInIsolate(config, ReceivePort().sendPort);

      // Завершаем синхронизацию
      _progressManager.completeSync(result);

      _logger.info('Синхронизация успешно завершена');
      return result;

    } catch (e, st) {
      _logger.severe('Ошибка синхронизации', e, st);
      _progressManager.failSync(e, st);
      rethrow;
    }
  }

  @override
  Future<void> cancel() async {
    if (!isActive) {
      _logger.warning('Попытка отменить неактивную синхронизацию');
      return;
    }

    _logger.info('Отмена синхронизации');
    _isPaused = false;
    _pauseCompleter?.complete();

    await _isolateManager.cancelIsolate();
    _progressManager.cancelSync();
  }

  @override
  Future<void> pause() async {
    if (!isActive || isPaused) {
      _logger.warning('Невозможно поставить на паузу: активна=$isActive, пауза=$isPaused');
      return;
    }

    _logger.info('Пауза синхронизации');
    _isPaused = true;
    _pauseCompleter = Completer<void>();

    // TODO: Реализовать паузу в изоляте
    // Пока просто ждем resume
    await _pauseCompleter!.future;
  }

  @override
  Future<void> resume() async {
    if (!isActive || !isPaused) {
      _logger.warning('Невозможно возобновить: активна=$isActive, пауза=$isPaused');
      return;
    }

    _logger.info('Возобновление синхронизации');
    _isPaused = false;
    _pauseCompleter?.complete();
  }

  /// Выполняет синхронизацию в изоляте
  Future<SyncResult> _performSyncInIsolate(
    SyncConfig config,
    SendPort progressPort,
  ) async {
    // Эта функция будет переопределена в конкретных реализациях
    // (например, ProductSyncService)
    throw UnimplementedError('Должен быть реализован в подклассе');
  }

  /// Проверяет валидность сессии
  Future<bool> _validateSession() async {
    try {
      return _sessionManager.hasActiveSession();
    } catch (e) {
      _logger.warning('Ошибка проверки сессии', e);
      return false;
    }
  }
}