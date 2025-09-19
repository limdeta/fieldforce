import 'dart:async';
import 'dart:isolate';

import 'package:get_it/get_it.dart';
import '../../../../app/services/session_manager.dart';
import '../../../../app/services/sync_isolate_manager.dart';
import '../../../../app/services/sync_progress_manager.dart';
import '../../../../app/config/app_config.dart';
import '../../../../shared/models/sync_config.dart';
import '../../../../shared/models/sync_progress.dart';
import '../../../../shared/models/sync_result.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_item_repository.dart';
import 'product_sync_service.dart';

/// Конкретная реализация сервиса синхронизации продуктов
class ProductSyncServiceImpl {
  final SessionManager _sessionManager;
  final SyncIsolateManager _isolateManager;
  final SyncProgressManager _progressManager;

  bool _isActive = false;
  bool _isPaused = false;
  Completer<void>? _pauseCompleter;

  ProductSyncServiceImpl({
    required SessionManager sessionManager,
    required SyncIsolateManager isolateManager,
    required SyncProgressManager progressManager,
  })  : _sessionManager = sessionManager,
        _isolateManager = isolateManager,
        _progressManager = progressManager;

  Stream<SyncProgress> get syncProgress => _progressManager.progressStream;

  Stream<SyncResult> get syncResults => _progressManager.resultStream;

  Stream<String> get syncStatus => _progressManager.statusStream;

  bool get isActive => _isActive;

  bool get isPaused => _isPaused;

  Future<SyncResult> sync(SyncConfig config) async {
    if (_isActive) {
      throw StateError('Синхронизация уже активна');
    }

    try {
      // Проверяем сессию
      if (!_sessionManager.hasActiveSession()) {
        throw StateError('Сессия недействительна, требуется повторная аутентификация');
      }

      // Начинаем синхронизацию
      _isActive = true;
      _isPaused = false;
      _progressManager.startSync();

      // Временно выполняем синхронизацию в основном потоке для отладки
      final result = await _performSyncInMainThread(config);

      // Завершаем синхронизацию
      _progressManager.completeSync(result);
      _isActive = false;

      return result;

    } catch (e) {
      _isActive = false;
      _progressManager.failSync(e);
      rethrow;
    }
  }

  Future<void> cancel() async {
    if (!_isActive) return;

    _isActive = false;
    _isPaused = false;
    _pauseCompleter?.complete();

    await _isolateManager.cancelIsolate();
    _progressManager.cancelSync();
  }

  Future<void> pause() async {
    if (!_isActive || _isPaused) return;

    _isPaused = true;
    _pauseCompleter = Completer<void>();
    // TODO: Реализовать паузу в изоляте
    await _pauseCompleter!.future;
  }

  Future<void> resume() async {
    if (!_isActive || !_isPaused) return;

    _isPaused = false;
    _pauseCompleter?.complete();
  }

  Future<SyncResult> _performSyncInMainThread(SyncConfig config) async {
    final apiUrl = AppConfig.productsApiUrl;
    final sessionCookie = _sessionManager.getSessionCookie();
    
    // Получаем репозитории из DI
    final productRepository = GetIt.instance<ProductRepository>();
    final stockItemRepository = GetIt.instance<StockItemRepository>();
    
    // Создаем сервис синхронизации на основе конфига
    final syncService = ProductSyncServiceFactory.create(config, apiUrl, sessionCookie);

    // Создаем порт для прогресса (в основном потоке просто игнорируем)
    final progressPort = ReceivePort();
    
    // Запускаем синхронизацию
    return syncService.syncProducts(config, progressPort.sendPort, productRepository, stockItemRepository);
  }

  /// Регистрация сервиса в DI
  static void register(GetIt getIt) {
    getIt.registerSingleton(
      ProductSyncServiceImpl(
        sessionManager: getIt(),
        isolateManager: getIt(),
        progressManager: getIt(),
      ),
    );
  }
}