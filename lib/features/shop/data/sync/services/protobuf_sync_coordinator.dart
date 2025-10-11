// lib/features/shop/data/sync/services/protobuf_sync_coordinator.dart

import 'package:logging/logging.dart';

import '../models/product_protobuf_converter.dart';
import '../models/stock_item_protobuf_converter.dart';
import '../repositories/protobuf_sync_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'regional_sync_service.dart';
import 'stock_sync_service.dart';
import 'outlet_pricing_sync_service.dart';

/// Координатор для управления protobuf синхронизацией
/// 
/// Упрощенная версия:
/// 1. getRegionalProducts() - загрузка продуктов региона
/// 2. getRegionalStock() - загрузка остатков региона  
/// 3. getOutletPrices() - загрузка цен для конкретных точек
class ProtobufSyncCoordinator {
  static final Logger _logger = Logger('ProtobufSyncCoordinator');
  
  final RegionalSyncService _regionalSyncService;
  final StockSyncService _stockSyncService;
  final OutletPricingSyncService _outletPricingSyncService;
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
       _productRepository = productRepository,
       _stockItemRepository = stockItemRepository;

  /// Простая синхронизация всех данных для региона
  Future<Map<String, dynamic>> performFullSync(
    String regionFiasId, {
    List<String>? outletVendorIds,
    Function(String stage, double progress)? onProgress,
  }) async {
    _logger.info('🔄 Начинаем protobuf синхронизацию для региона: $regionFiasId');
    
    final result = <String, dynamic>{
      'success': false,
      'products_synced': 0,
      'stock_synced': 0,
      'prices_synced': 0,
      'errors': <String>[],
    };
    
    try {
      // 1. Загружаем продукты региона
      _logger.info('📦 Загрузка продуктов региона...');
      onProgress?.call('Загрузка продуктов', 0.2);
      
      final regionalResponse = await _regionalSyncService.getRegionalProducts(regionFiasId);
      final products = ProductProtobufConverter.fromProtobufList(regionalResponse.products);
      
      final saveResult = await _productRepository.saveProducts(products);
      if (saveResult.isLeft()) {
        final failure = saveResult.fold((f) => f, (r) => null)!;
        _logger.warning('⚠️ Ошибка сохранения: ${failure.message}');
        result['errors'].add(failure.message);
        result['success'] = false;
        return result;
      } else {
        result['products_synced'] = products.length;
        _logger.info('✅ Сохранено ${products.length} продуктов');
      }

      // 2. Загружаем остатки
      _logger.info('📦 Загрузка остатков...');
      onProgress?.call('Загрузка остатков', 0.5);
      
      final stockResponse = await _stockSyncService.getRegionalStock(regionFiasId);
      _logger.info('✅ Загружены остатки для ${stockResponse.stockItems.length} товаров');

      // Конвертируем protobuf в domain entities и сохраняем в БД
      if (stockResponse.stockItems.isNotEmpty) {
        _logger.info('💾 Сохранение остатков в базу данных...');
        onProgress?.call('Сохранение остатков', 0.6);
        
        final stockItems = StockItemProtobufConverter.fromProtobufList(stockResponse.stockItems);
        
        // Диагностика конвертированных данных
        _logger.info('🔍 ДИАГНОСТИКА после конвертации:');
        _logger.info('  Всего элементов: ${stockItems.length}');
        
        final itemsWithStock = stockItems.where((item) => item.stock > 0).toList();
        _logger.info('  Элементов с stock > 0: ${itemsWithStock.length}');
        
        if (stockItems.isNotEmpty) {
          final firstItem = stockItems.first;
          _logger.info('  Первый элемент: productCode=${firstItem.productCode}, stock=${firstItem.stock}, publicStock="${firstItem.publicStock}"');
        }
        
        if (itemsWithStock.isNotEmpty) {
          final firstWithStock = itemsWithStock.first;
          _logger.info('  Первый с stock > 0: productCode=${firstWithStock.productCode}, stock=${firstWithStock.stock}, publicStock="${firstWithStock.publicStock}"');
        }
        
        // Диагностика: проверим сколько продуктов есть в БД
        final existingProductsResult = await _productRepository.getAllProducts();
        existingProductsResult.fold(
          (failure) => _logger.warning('⚠️ Не удалось получить список продуктов для диагностики'),
          (existingProducts) {
            final existingProductCodes = existingProducts.map((p) => p.code).toSet();
            final incomingProductCodes = stockItems.map((s) => s.productCode).toSet();
            final matchingCodes = existingProductCodes.intersection(incomingProductCodes);
            
            _logger.info('🔍 Продуктов в БД: ${existingProducts.length}');
            _logger.info('🔍 Уникальных кодов продуктов в остатках: ${incomingProductCodes.length}');
            _logger.info('🔍 Совпадающих кодов: ${matchingCodes.length}');
            
            if (matchingCodes.isEmpty) {
              _logger.severe('❌ КРИТИЧНО: Ни одного кода продукта из остатков не найдено в БД!');
              _logger.info('📋 Примеры кодов в БД: ${existingProductCodes.take(10).join(", ")}');
              _logger.info('📋 Примеры кодов в остатках: ${incomingProductCodes.take(10).join(", ")}');
            }
          },
        );
        
        final saveResult = await _stockItemRepository.saveStockItems(stockItems);
        
        saveResult.fold(
          (failure) {
            _logger.severe('❌ Ошибка сохранения остатков: ${failure.message}');
            throw Exception('Ошибка сохранения остатков: ${failure.message}');
          },
          (_) {
            _logger.info('✅ Сохранено ${stockItems.length} остатков в базу данных');
            
            // Дополнительная информация для отладки
            if (stockItems.isNotEmpty) {
              final firstItem = stockItems.first;
              _logger.info('📊 Пример сохраненного StockItem: продукт=${firstItem.productCode}, склад=${firstItem.warehouseId}, остаток=${firstItem.stock}, цена=${firstItem.defaultPrice}');
            }
            
            result['stock_synced'] = stockItems.length;
          },
        );
      }

      // 3. Загружаем цены торговых точек (если указаны)
      if (outletVendorIds != null && outletVendorIds.isNotEmpty) {
        _logger.info('💰 Загрузка цен торговых точек...');
        
        int totalPrices = 0;
        for (int i = 0; i < outletVendorIds.length; i++) {
          final vendorId = outletVendorIds[i];
          onProgress?.call('Загрузка цен точки ${i + 1}/${outletVendorIds.length}', 0.7 + 0.2 * (i / outletVendorIds.length));
          
          try {
            final priceResponse = await _outletPricingSyncService.getOutletPrices(vendorId);
            totalPrices += priceResponse.products.length;
          } catch (e) {
            _logger.warning('⚠️ Ошибка загрузки цен для $vendorId: $e');
            result['errors'].add('Ошибка цен для $vendorId: $e');
          }
        }
        
        result['prices_synced'] = totalPrices;
        _logger.info('✅ Загружены цены для $totalPrices товаров');
      }

      // Сохраняем время синхронизации
      // await _syncRepository.updateLastSync(regionFiasId, DateTime.now());
      
      result['success'] = true;
      onProgress?.call('Завершено', 1.0);
      
      _logger.info('✅ Синхронизация завершена успешно');
      return result;
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка синхронизации: $e', e, stackTrace);
      result['success'] = false;
      result['errors'].add('Критическая ошибка: $e');
      rethrow;
    }
  }

  /// Быстрая синхронизация только продуктов
  Future<Map<String, dynamic>> syncProductsOnly(String regionFiasId) async {
    _logger.info('📦 Быстрая синхронизация продуктов для $regionFiasId');
    
    final result = <String, dynamic>{
      'success': false,
      'products_synced': 0,
      'errors': <String>[],
    };
    
    try {
      final response = await _regionalSyncService.getRegionalProducts(regionFiasId);
      final products = ProductProtobufConverter.fromProtobufList(response.products);
      
      final saveResult = await _productRepository.saveProducts(products);
      if (saveResult.isLeft()) {
        final failure = saveResult.fold((f) => f, (r) => null)!;
        _logger.warning('⚠️ Ошибка: ${failure.message}');
        result['success'] = false;
        result['errors'].add(failure.message);
      } else {
        result['products_synced'] = products.length;
        result['success'] = true;
        _logger.info('✅ Быстро синхронизировано ${products.length} продуктов');
      }
      
      return result;
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка быстрой синхронизации: $e', e, stackTrace);
      result['success'] = false;
      result['errors'].add('Критическая ошибка: $e');
      rethrow;
    }
  }

  /// Получить статистику синхронизированных данных
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final stats = <String, dynamic>{};
      
      // Проверяем количество продуктов
      final productResult = await _productRepository.getAllProducts();
      productResult.fold(
        (failure) => stats['products'] = 'Ошибка: ${failure.message}',
        (products) => stats['products'] = products.length,
      );
      
      // Проверяем количество stock items
      final stockResult = await _stockItemRepository.getAvailableStockItems();
      stockResult.fold(
        (failure) => stats['stock_items'] = 'Ошибка: ${failure.message}',
        (stockItems) {
          stats['stock_items'] = stockItems.length;
          stats['stock_items_with_stock'] = stockItems.where((item) => item.stock > 0).length;
          
          if (stockItems.isNotEmpty) {
            final sampleItem = stockItems.first;
            stats['sample_stock_item'] = {
              'product_code': sampleItem.productCode,
              'warehouse_id': sampleItem.warehouseId,
              'warehouse_name': sampleItem.warehouseName,
              'stock': sampleItem.stock,
              'price': sampleItem.defaultPrice,
            };
          }
        },
      );
      
      return stats;
    } catch (e) {
      _logger.severe('❌ Ошибка получения статистики: $e');
      return {'error': e.toString()};
    }
  }
}