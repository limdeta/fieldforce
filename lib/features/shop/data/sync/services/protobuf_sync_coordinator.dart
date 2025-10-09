import 'package:logging/logging.dart';

import 'regional_sync_service.dart';
import 'stock_sync_service.dart';
import 'outlet_pricing_sync_service.dart';
import '../repositories/protobuf_sync_repository.dart';
import '../models/product_protobuf_converter.dart';
import '../models/stock_item_protobuf_converter.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/stock_item_repository.dart';

/// Координатор всех protobuf синхронизаций
/// Управляет последовательностью и приоритетами синхронизации данных
class ProtobufSyncCoordinator {
  static final Logger _logger = Logger('ProtobufSyncCoordinator');
  
  final RegionalSyncService _regionalSyncService;
  final StockSyncService _stockSyncService;
  final OutletPricingSyncService _outletPricingSyncService;
  final ProtobufSyncRepository _syncRepository;
  final ProductRepository _productRepository;
  final StockItemRepository _stockItemRepository;
  
  ProtobufSyncCoordinator({
    required RegionalSyncService regionalSyncService,
    required StockSyncService stockSyncService,
    required OutletPricingSyncService outletPricingSyncService,
    required ProtobufSyncRepository syncRepository,
    required ProductRepository productRepository,
    required StockItemRepository stockItemRepository,
  }) : _regionalSyncService = regionalSyncService,
       _stockSyncService = stockSyncService,
       _outletPricingSyncService = outletPricingSyncService,
       _syncRepository = syncRepository,
       _productRepository = productRepository,
       _stockItemRepository = stockItemRepository;

  /// Выполняет полную синхронизацию региона
  /// 
  /// Последовательность:
  /// 1. Региональный кэш (продукты, базовые данные) - ежедневно
  /// 2. Остатки на складах - ежечасно  
  /// 3. Дифференциальные цены точек - ежечасно
  /// 
  /// [regionFiasId] - FIAS код региона
  /// [outletIds] - список торговых точек для синхронизации цен
  /// [forceFullSync] - принудительная полная синхронизация
  Future<SyncResult> performFullRegionalSync(
    String regionFiasId,
    List<int> outletIds, {
    bool forceFullSync = false,
  }) async {
    _logger.info('🔄 Начинается полная синхронизация региона $regionFiasId');
    final startTime = DateTime.now();
    
    final result = SyncResult();
    
    try {
      // 1. Синхронизация регионального кэша (продукты)
      _logger.info('📦 Этап 1: Синхронизация продуктов...');
      final lastRegionalSync = await _syncRepository.getLastRegionalSync(regionFiasId);
      final regionalResponse = forceFullSync 
        ? await _regionalSyncService.getRegionalProducts(regionFiasId)
        : await _regionalSyncService.getRegionalProductsDelta(regionFiasId, lastRegionalSync ?? DateTime.now().subtract(const Duration(days: 1)));
      
      // Конвертируем protobuf продукты в domain сущности и сохраняем
      final products = ProductProtobufConverter.fromProtobufList(regionalResponse.products);
      final saveResult = await _productRepository.saveProducts(products);
      saveResult.fold(
        (failure) => _logger.warning('⚠️ Ошибка сохранения продуктов: ${failure.message}'),
        (_) => _logger.info('✅ Сохранено ${products.length} продуктов'),
      );
      result.productsCount = products.length;
      
      // Сохраняем время синхронизации
      await _syncRepository.saveLastRegionalSync(regionFiasId, DateTime.now(), result.productsCount);
      
      // 2. Синхронизация остатков на складах
      _logger.info('📊 Этап 2: Синхронизация остатков...');
      final lastStockUpdate = forceFullSync ? null : await _syncRepository.getLastStockSync(regionFiasId);
      
      // Получаем данные остатков через StockSyncService
      final stockCount = await _syncStockItems(regionFiasId, lastStockUpdate);
      result.stockItemsCount = stockCount;
      
      // Сохраняем время синхронизации остатков
      await _syncRepository.saveLastStockSync(regionFiasId, DateTime.now(), result.stockItemsCount);
      
      // 3. Синхронизация дифференциальных цен точек
      _logger.info('💰 Этап 3: Синхронизация цен точек...');
      final pricingResults = await _outletPricingSyncService.batchSyncOutletPricing(
        outletIds,
        null, // Все товары
      );
      result.outletPricingCount = pricingResults.values.fold(0, (a, b) => a + b);
      
      final duration = DateTime.now().difference(startTime);
      result.duration = duration;
      result.success = true;
      
      _logger.info('✅ Полная синхронизация завершена за ${duration.inSeconds} сек');
      _logger.info('📈 Результаты: ${result.productsCount} товаров, ${result.stockItemsCount} остатков, ${result.outletPricingCount} цен');
      
    } catch (e, stackTrace) {
      result.success = false;
      result.error = e.toString();
      
      _logger.severe('❌ Ошибка полной синхронизации: $e', e, stackTrace);
      rethrow;
    }
    
    return result;
  }

  /// Выполняет быструю инкрементальную синхронизацию
  /// 
  /// Используется для частых обновлений (каждые 15-30 минут):
  /// - Только изменившиеся остатки
  /// - Только изменившиеся цены для активных точек
  /// 
  /// [regionFiasId] - FIAS код региона
  /// [activeOutletIds] - список активных торговых точек
  Future<SyncResult> performIncrementalSync(
    String regionFiasId,
    List<int> activeOutletIds,
  ) async {
    _logger.info('⚡ Инкрементальная синхронизация региона $regionFiasId');
    final startTime = DateTime.now();
    
    final result = SyncResult();
    
    try {
      // Получаем время последних обновлений
      final lastStockUpdate = await _syncRepository.getLastStockSync(regionFiasId);
      
      // Параллельная синхронизация остатков и цен
      final futures = <Future>[];
      
      // Остатки товаров
      futures.add(
        _stockSyncService.syncRegionalStock(
          regionFiasId,
          lastUpdate: lastStockUpdate,
        ).then((count) => result.stockItemsCount = count),
      );
      
      // Цены для активных точек
      if (activeOutletIds.isNotEmpty) {
        futures.add(
          _outletPricingSyncService.batchSyncOutletPricing(
            activeOutletIds,
            null, // Все товары, но только изменившиеся цены
          ).then((pricingResults) {
            result.outletPricingCount = pricingResults.values.fold(0, (a, b) => a + b);
          }),
        );
      }
      
      await Future.wait(futures);
      
      final duration = DateTime.now().difference(startTime);
      result.duration = duration;
      result.success = true;
      
      _logger.info('✅ Инкрементальная синхронизация завершена за ${duration.inMilliseconds} мс');
      
    } catch (e, stackTrace) {
      result.success = false;
      result.error = e.toString();
      
      _logger.severe('❌ Ошибка инкрементальной синхронизации: $e', e, stackTrace);
      rethrow;
    }
    
    return result;
  }

  /// Устанавливает сессионную куку для всех сервисов
  void setSessionCookie(String cookie) {
    _regionalSyncService.setSessionCookie(cookie);
    _stockSyncService.setSessionCookie(cookie);
    _outletPricingSyncService.setSessionCookie(cookie);
    _logger.info('🔐 Сессионная кука установлена для всех sync сервисов');
  }

  /// Очищает сессию для всех сервисов
  void clearSession() {
    _regionalSyncService.clearSession();
    _stockSyncService.clearSession();
    _outletPricingSyncService.clearSession();
    _logger.info('🚪 Сессия очищена для всех sync сервисов');
  }

  /// Синхронизирует остатки товаров с сохранением в базу
  /// 
  /// [regionFiasId] - FIAS код региона
  /// [lastUpdate] - время последнего обновления (null для полной синхронизации)
  /// 
  /// Возвращает количество обработанных записей остатков
  Future<int> _syncStockItems(String regionFiasId, DateTime? lastUpdate) async {
    try {
      // Пока что используем существующий метод stockSyncService
      // В будущем можно создать метод, возвращающий protobuf данные
      final stockCount = await _stockSyncService.syncRegionalStock(
        regionFiasId,
        lastUpdate: lastUpdate,
      );
      
      // TODO: Когда StockSyncService будет возвращать protobuf данные:
      // final stockResponse = await _stockSyncService.getRegionalStockData(regionFiasId, lastUpdate);
      // final stockItems = StockItemProtobufConverter.fromProtobufList(stockResponse.stockItems);
      // final saveResult = await _stockItemRepository.saveStockItems(stockItems);
      // saveResult.fold(
      //   (failure) => _logger.warning('⚠️ Ошибка сохранения остатков: ${failure.message}'),
      //   (_) => _logger.info('✅ Сохранено ${stockItems.length} остатков'),
      // );
      
      return stockCount;
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка синхронизации остатков для региона $regionFiasId: $e', e, stackTrace);
      rethrow;
    }
  }
}

/// Результат выполнения синхронизации
class SyncResult {
  bool success = false;
  int productsCount = 0;
  int stockItemsCount = 0;
  int outletPricingCount = 0;
  Duration? duration;
  String? error;

  @override
  String toString() {
    if (!success) {
      return 'SyncResult(failed: $error)';
    }
    
    return 'SyncResult(products: $productsCount, stock: $stockItemsCount, prices: $outletPricingCount, duration: ${duration?.inSeconds}s)';
  }
}