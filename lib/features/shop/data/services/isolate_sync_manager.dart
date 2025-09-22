// lib/features/shop/data/services/isolate_sync_manager.dart

import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';

import 'sync_messages.dart';
import 'sync_isolate_worker.dart';
import '../../../../shared/models/sync_config.dart';
import '../../../../shared/models/sync_result.dart';
import '../../../../shared/models/sync_progress.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_item_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/entities/category.dart' as cat;
import '../../domain/entities/product.dart';
import '../../domain/entities/stock_item.dart';
import '../../data/mappers/product_api_models.dart';
import 'product_parsing_service.dart';
import '../../../../app/services/session_manager.dart';

/// Менеджер для управления синхронизацией через изоляты
/// 
/// Этот класс оркестрирует процесс синхронизации:
/// 1. Запускает worker изоляты для тяжелых операций
/// 2. Обрабатывает коммуникацию между главным и worker изолятами
/// 3. Сохраняет результаты в БД через репозитории
/// 4. Предоставляет контроль над процессом (пауза/отмена/прогресс)
class IsolateSyncManager {
  static final Logger _logger = Logger('IsolateSyncManager');
  
  final ProductRepository _productRepository;
  final StockItemRepository _stockItemRepository;
  final CategoryRepository _categoryRepository;
  final String _productsApiUrl;
  final String _categoriesApiUrl;
  final SessionManager _sessionManager;

  // State для управления изолятом
  Isolate? _workerIsolate;
  SendPort? _sendPortToWorker;
  late ReceivePort _receivePortInMain;
  
  // Контроллеры для уведомлений
  final StreamController<SyncProgress> _progressController = StreamController<SyncProgress>.broadcast();
  final StreamController<SyncResult> _resultController = StreamController<SyncResult>.broadcast();
  
  // Состояние синхронизации
  bool _isRunning = false;
  String? _currentSyncType;
  
  IsolateSyncManager({
    required ProductRepository productRepository,
    required StockItemRepository stockItemRepository,
    required CategoryRepository categoryRepository,
    required String productsApiUrl,
    required String categoriesApiUrl,
    required SessionManager sessionManager,
  }) : _productRepository = productRepository,
       _stockItemRepository = stockItemRepository,
       _categoryRepository = categoryRepository,
       _productsApiUrl = productsApiUrl,
       _categoriesApiUrl = categoriesApiUrl,
       _sessionManager = sessionManager;

  // helper removed — keep logs concise

  /// Stream уведомлений о прогрессе синхронизации
  Stream<SyncProgress> get progressStream => _progressController.stream;

  /// Stream результатов синхронизации  
  Stream<SyncResult> get resultStream => _resultController.stream;

  /// Текущий статус синхронизации
  bool get isRunning => _isRunning;
  String? get currentSyncType => _currentSyncType;

  /// Инициализирует worker изолят
  Future<void> initialize() async {
    if (_workerIsolate != null) {
      _logger.warning('Worker изолят уже инициализирован');
      return;
    }

    _logger.info('🚀 Инициализация worker изолята...');
    
    try {
      _receivePortInMain = ReceivePort();
      
      // Запускаем worker изолят
      _workerIsolate = await Isolate.spawn(
        syncWorkerEntryPoint,
        _receivePortInMain.sendPort,
        debugName: 'SyncWorkerIsolate',
      );
      
      // Ждем инициализации worker изолята
      final completer = Completer<void>();
      late StreamSubscription subscription;
      
      subscription = _receivePortInMain.listen((message) {
        try {
          if (message is SendPort) {
            // Получили SendPort от worker изолята
            _sendPortToWorker = message;
            _logger.info('✅ Получен SendPort от worker изолята');
            return;
          }
          
          if (message is Map<String, dynamic>) {
            final syncMessage = SyncMessage.fromJson(message);
            
            if (syncMessage.type == SyncResponses.initialized) {
              _logger.info('✅ Worker изолят инициализирован');
              completer.complete();
              return;
            }
            
            // Обрабатываем другие сообщения
            _handleWorkerMessage(syncMessage);
          }
        } catch (e, stackTrace) {
          _logger.severe('Ошибка обработки сообщения от worker изолята', e, stackTrace);
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      });
      
      // Ожидаем инициализацию с таймаутом
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          subscription.cancel();
          throw TimeoutException('Worker изолят не инициализировался за 10 секунд');
        },
      );
      
      _logger.info('🎉 IsolateSyncManager успешно инициализирован');
      
    } catch (e, stackTrace) {
      _logger.severe('Ошибка инициализации worker изолята', e, stackTrace);
      await dispose();
      rethrow;
    }
  }

  /// Синхронизирует продукты через worker изолят
  Future<SyncResult> syncProducts(SyncConfig config) async {
    if (!_isRunning) {
      _isRunning = true;
      _currentSyncType = 'products';
    }

    try {
      await _ensureInitialized();
      
      _logger.info('🛍️ Запуск синхронизации продуктов через изолят');
      
      // Отправляем команду worker изоляту
      final command = SyncMessage(
        type: SyncCommands.startProductSync,
        data: {
          'config': _syncConfigToJson(config),
          'apiUrl': _productsApiUrl,
          'sessionHeaders': _sessionManager.getSessionHeaders(),
        },
      );
  // Отправляем команду в worker (session headers передаются при необходимости)
  _sendPortToWorker!.send(command.toJson());
      
      // Ожидаем результат синхронизации
      final resultCompleter = Completer<SyncResult>();
      late StreamSubscription subscription;
      
      subscription = _resultController.stream.listen((result) {
        if (result.type == 'products') {
          subscription.cancel();
          resultCompleter.complete(result);
        }
      });
      
      final result = await resultCompleter.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          subscription.cancel();
          return SyncResult.withErrors(
            type: 'products',
            successCount: 0,
            errorCount: 1,
            errors: ['Таймаут синхронизации продуктов'],
            duration: const Duration(minutes: 10),
            startTime: DateTime.now().subtract(const Duration(minutes: 10)),
          );
        },
      );
      
      return result;
      
    } catch (e, stackTrace) {
      _logger.severe('Ошибка синхронизации продуктов', e, stackTrace);
      
      return SyncResult.withErrors(
        type: 'products',
        successCount: 0,
        errorCount: 1,
        errors: [e.toString()],
        duration: Duration.zero,
        startTime: DateTime.now(),
      );
    } finally {
      _isRunning = false;
      _currentSyncType = null;
    }
  }

  /// Синхронизирует категории через worker изолят
  Future<SyncResult> syncCategories(SyncConfig config) async {
    if (!_isRunning) {
      _isRunning = true;
      _currentSyncType = 'categories';
    }

    try {
      await _ensureInitialized();
      
      _logger.info('📂 Запуск синхронизации категорий через изолят');
      
      final command = SyncMessage(
        type: SyncCommands.startCategorySync,
        data: {
          'config': _syncConfigToJson(config),
          'apiUrl': _categoriesApiUrl,
          'sessionHeaders': _sessionManager.getSessionHeaders(),
        },
      );
      
  _logger.info('Отправляем команду в worker: ${command.type}');
      
      _sendPortToWorker!.send(command.toJson());
      
      final resultCompleter = Completer<SyncResult>();
      late StreamSubscription subscription;
      
      subscription = _resultController.stream.listen((result) {
        if (result.type == 'categories') {
          subscription.cancel();
          resultCompleter.complete(result);
        }
      });
      
      final result = await resultCompleter.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          subscription.cancel();
          return SyncResult.withErrors(
            type: 'categories',
            successCount: 0,
            errorCount: 1,
            errors: ['Таймаут синхронизации категорий'],
            duration: const Duration(minutes: 5),
            startTime: DateTime.now().subtract(const Duration(minutes: 5)),
          );
        },
      );
      
      return result;
      
    } catch (e, stackTrace) {
      _logger.severe('Ошибка синхронизации категорий', e, stackTrace);
      
      return SyncResult.withErrors(
        type: 'categories',
        successCount: 0,
        errorCount: 1,
        errors: [e.toString()],
        duration: Duration.zero,
        startTime: DateTime.now(),
      );
    } finally {
      _isRunning = false;
      _currentSyncType = null;
    }
  }

  /// Приостанавливает текущую синхронизацию
  Future<void> pauseSync() async {
    if (_sendPortToWorker != null) {
      final command = SyncMessage(type: SyncCommands.pauseSync, data: {});
      _sendPortToWorker!.send(command.toJson());
      _logger.info('⏸️ Отправлена команда паузы');
    }
  }

  /// Возобновляет приостановленную синхронизацию
  Future<void> resumeSync() async {
    if (_sendPortToWorker != null) {
      final command = SyncMessage(type: SyncCommands.resumeSync, data: {});
      _sendPortToWorker!.send(command.toJson());
      _logger.info('▶️ Отправлена команда возобновления');
    }
  }

  /// Отменяет текущую синхронизацию
  Future<void> cancelSync() async {
    if (_sendPortToWorker != null) {
      final command = SyncMessage(type: SyncCommands.cancelSync, data: {});
      _sendPortToWorker!.send(command.toJson());
      _logger.info('🛑 Отправлена команда отмены');
    }
    
    _isRunning = false;
    _currentSyncType = null;
  }

  /// Освобождает ресурсы и завершает worker изолят
  Future<void> dispose() async {
    _logger.info('🧹 Завершение IsolateSyncManager...');
    
    if (_sendPortToWorker != null) {
      try {
        final command = SyncMessage(type: SyncCommands.shutdown, data: {});
        _sendPortToWorker!.send(command.toJson());
        _logger.info('📤 Отправлена команда завершения worker изоляту');
      } catch (e) {
        _logger.warning('Ошибка отправки команды завершения: $e');
      }
    }
    
    // Даем время worker изоляту на graceful shutdown
    await Future.delayed(const Duration(milliseconds: 500));
    
    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerIsolate = null;
    _sendPortToWorker = null;
    
    if (!_receivePortInMain.isBroadcast) {
      _receivePortInMain.close();
    }
    
    await _progressController.close();
    await _resultController.close();
    
    _isRunning = false;
    _currentSyncType = null;
    
    _logger.info('✅ IsolateSyncManager завершен');
  }

  /// Проверяет инициализацию и при необходимости инициализирует
  Future<void> _ensureInitialized() async {
    if (_workerIsolate == null || _sendPortToWorker == null) {
      await initialize();
    }
  }

  /// Обрабатывает сообщения от worker изолята
  void _handleWorkerMessage(SyncMessage message) {
    _logger.fine('📨 Получено сообщение от worker изолята: ${message.type}');
    
    switch (message.type) {
      case SyncResponses.progress:
        final progress = _syncProgressFromJson(message.data);
        _progressController.add(progress);
        break;
        
      case 'result':
      case SyncResponses.completed:
        final result = _syncResultFromJson(message.data);
        _resultController.add(result);
        _isRunning = false;
        _currentSyncType = null;
        _logger.info('✅ Синхронизация завершена успешно');
        break;
        
      case SyncResponses.error:
        final result = _syncResultFromError(message.data);
        _resultController.add(result);
        break;
        
      case 'save_products':
        _logger.info('📥 Получено сообщение save_products, вызываем _handleSaveProducts');
        _handleSaveProducts(message.data).then((_) {
          _logger.info('✅ _handleSaveProducts завершен');
        }).catchError((e, st) {
          _logger.severe('❌ Ошибка в _handleSaveProducts', e, st);
        });
        break;
        
      case 'save_categories':
        _logger.info('📥 Получено сообщение save_categories, вызываем _handleSaveCategories');
        _handleSaveCategories(message.data).then((_) {
          _logger.info('✅ _handleSaveCategories завершен');
        }).catchError((e, st) {
          _logger.severe('❌ Ошибка в _handleSaveCategories', e, st);
        });
        break;
        
      case SyncResponses.heartbeat:
        _logger.fine('💓 Heartbeat от worker изолята');
        break;
        
      case SyncResponses.paused:
        _logger.info('⏸️ Worker изолят приостановлен');
        break;
        
      case SyncResponses.resumed:
        _logger.info('▶️ Worker изолят возобновлен');
        break;
        
      case SyncResponses.cancelled:
        _logger.info('🛑 Worker изолят отменил операцию');
        _isRunning = false;
        _currentSyncType = null;
        break;
        
      default:
        _logger.warning('⚠️ Неизвестный тип сообщения: ${message.type}');
    }
  }

  /// Обрабатывает сохранение продуктов и stock items
  Future<void> _handleSaveProducts(Map<String, dynamic> data) async {
    try {
      _logger.fine('Получены данные для сохранения');
      
      if (!data.containsKey('apiItems')) {
        throw Exception('Отсутствует ключ apiItems в данных из изолята');
      }
      
      final apiItemsData = data['apiItems'] as List<dynamic>;
      if (apiItemsData.isEmpty) {
        _logger.fine('Список API товаров пуст');
        return;
      }
      
      // Используем существующий ProductParsingService для конвертации
      final parsingService = ProductParsingService();
      final products = <Product>[];
      final allStockItems = <StockItem>[];
      
      for (int i = 0; i < apiItemsData.length; i++) {
        final apiItemData = apiItemsData[i];
        try {
          if (apiItemData == null) {
            throw Exception('Данные продукта $i равны null');
          }
          if (apiItemData is! Map<String, dynamic>) {
            throw Exception('Данные продукта $i не являются Map<String, dynamic>');
          }

          final Map<String, dynamic> itemMap = apiItemData;
          final apiItem = ProductApiItem.fromJson(itemMap);

          final result = parsingService.convertApiItemToProduct(apiItem, itemMap);

          products.add(result.product);
          allStockItems.addAll(result.stockItems);

        } catch (e) {
          final productTitle = (apiItemData as Map<String, dynamic>?)?['title'] ?? 'Unknown';
          _logger.warning('Ошибка конвертации API товара $i: $productTitle — пропускаем');
          // Продолжаем обработку остальных продуктов
        }
      }
      
      // Сохраняем в БД используя существующие репозитории
      _logger.info('💾 Готовы к сохранению: ${products.length} продуктов, ${allStockItems.length} stock items');
      
      if (products.isNotEmpty) {
        _logger.info('💾 Начинаем сохранение ${products.length} продуктов...');
        await _productRepository.saveProducts(products);
        _logger.info('✅ Сохранено ${products.length} продуктов');
      } else {
        _logger.warning('⚠️ Нет продуктов для сохранения');
      }
      
      if (allStockItems.isNotEmpty) {
        _logger.info('📦 Начинаем сохранение ${allStockItems.length} stock items...');
        await _stockItemRepository.saveStockItems(allStockItems);
        _logger.info('✅ Сохранено ${allStockItems.length} stock items');
      } else {
        _logger.warning('⚠️ Нет stock items для сохранения');
      }
      
      _logger.info('✅ Продукты сохранены из изолята');
      
    } catch (e, stackTrace) {
      _logger.severe('Ошибка сохранения продуктов из изолята', e, stackTrace);
      _logger.severe('Тип ошибки: ${e.runtimeType}');
      _logger.severe('Подробности ошибки: $e');
      _logger.severe('Stack trace: $stackTrace');
    }
  }

  /// Обрабатывает сохранение категорий
  Future<void> _handleSaveCategories(Map<String, dynamic> data) async {
    try {
      final categoriesData = data['categories'] as List<dynamic>;
      _logger.info('💾 Сохраняем ${categoriesData.length} категорий из изолята...');
      
      final categories = categoriesData
          .map((data) => cat.Category.fromJson(data as Map<String, dynamic>))
          .toList();
      
      final saveResult = await _categoryRepository.saveCategories(categories);
      saveResult.fold(
        (failure) => throw Exception('Ошибка сохранения категорий: ${failure.message}'),
        (_) => _logger.info('✅ Категории сохранены из изолята'),
      );
      
    } catch (e, stackTrace) {
      _logger.severe('Ошибка сохранения категорий из изолята', e, stackTrace);
    }
  }

  /// Конвертирует SyncConfig в JSON для передачи в изолят
  Map<String, dynamic> _syncConfigToJson(SyncConfig config) {
    return {
      'source': config.source.toString(),
      'categories': config.categories,
      'limit': config.limit,
      'offset': config.offset,
      'maxConcurrent': config.maxConcurrent,
      'timeout': config.timeout.inMilliseconds,
      'maxRetries': config.maxRetries,
      'retryDelay': config.retryDelay.inMilliseconds,
      'filePath': config.filePath,
    };
  }

  /// Восстанавливает SyncProgress из JSON
  SyncProgress _syncProgressFromJson(Map<String, dynamic> data) {
    return SyncProgress(
      type: data['syncType'] as String,
      current: data['current'] as int,
      total: data['total'] as int,
      status: data['status'] as String,
      percentage: (data['current'] as int) / (data['total'] as int),
    );
  }

  /// Восстанавливает SyncResult из JSON
  SyncResult _syncResultFromJson(Map<String, dynamic> data) {
    final success = data['success'] as bool;
    
    if (success) {
      return SyncResult.success(
        type: data['syncType'] as String,
        successCount: data['successCount'] as int,
        duration: Duration(milliseconds: data['durationMs'] as int),
        startTime: DateTime.now().subtract(Duration(milliseconds: data['durationMs'] as int)),
      );
    } else {
      return SyncResult.withErrors(
        type: data['syncType'] as String,
        successCount: 0,
        errorCount: 1,
        errors: [data['error'] as String],
        duration: Duration(milliseconds: data['durationMs'] as int),
        startTime: DateTime.now().subtract(Duration(milliseconds: data['durationMs'] as int)),
      );
    }
  }

  /// Создает SyncResult из сообщения об ошибке
  SyncResult _syncResultFromError(Map<String, dynamic> data) {
    return SyncResult.withErrors(
      type: data['syncType'] as String,
      successCount: 0,
      errorCount: 1,
      errors: [data['error'] as String],
      duration: Duration.zero,
      startTime: DateTime.now(),
    );
  }
}