import 'dart:async';

import 'package:get_it/get_it.dart';
import '../../../../app/services/session_manager.dart';

import '../../../../shared/models/sync_config.dart';
import '../../../../shared/models/sync_progress.dart';
import '../../../../shared/models/sync_result.dart';
import 'isolate_sync_manager.dart';

/// Конкретная реализация сервиса синхронизации продуктов
class ProductSyncServiceImpl {
  final SessionManager _sessionManager;
  final IsolateSyncManager _isolateManager;

  bool _isActive = false;
  bool _isPaused = false;

  ProductSyncServiceImpl({
    required SessionManager sessionManager,
    required IsolateSyncManager isolateManager,
  })  : _sessionManager = sessionManager,
        _isolateManager = isolateManager;

  Stream<SyncProgress> get syncProgress => _isolateManager.progressStream;

  Stream<SyncResult> get syncResults => _isolateManager.resultStream;

  Stream<String> get syncStatus => _isolateManager.progressStream
      .map((progress) => progress.status);

  bool get isActive => _isActive;

  bool get isPaused => _isPaused;

  Future<SyncResult> syncCategories(SyncConfig config) async {
    if (_isActive || _isolateManager.isRunning) {
      throw StateError('Синхронизация уже активна');
    }

    try {
      if (!await _sessionManager.hasActiveSession()) {
        throw StateError('Сессия недействительна, требуется повторная аутентификация');
      }

      _isActive = true;
      _isPaused = false;

      final result = await _isolateManager.syncCategories(config);
      _isActive = false;

      return result;

    } catch (e) {
      _isActive = false;
      rethrow;
    }
  }

  Future<SyncResult> syncProducts(SyncConfig config) async {
    if (_isActive || _isolateManager.isRunning) {
      throw StateError('Синхронизация уже активна');
    }

    try {
      // Проверяем сессию
      if (!await _sessionManager.hasActiveSession()) {
        throw StateError('Сессия недействительна, требуется повторная аутентификация');
      }

      // Начинаем синхронизацию через новый изолят-менеджер
      _isActive = true;
      _isPaused = false;

      final result = await _isolateManager.syncProducts(config);
      _isActive = false;

      return result;

    } catch (e) {
      _isActive = false;
      rethrow;
    }
  }

  Future<void> cancel() async {
    if (!_isActive && !_isolateManager.isRunning) return;

    _isActive = false;
    _isPaused = false;

    await _isolateManager.cancelSync();
  }

  Future<void> pause() async {
    if (!_isActive || _isPaused) return;

    _isPaused = true;
    await _isolateManager.pauseSync();
  }

  Future<void> resume() async {
    if (!_isActive || !_isPaused) return;

    _isPaused = false;
    await _isolateManager.resumeSync();
  }



  /// Регистрация сервиса в DI
  static void register(GetIt getIt) {
    getIt.registerSingleton(
      ProductSyncServiceImpl(
        sessionManager: getIt(),
        isolateManager: getIt(),
      ),
    );
  }
}
