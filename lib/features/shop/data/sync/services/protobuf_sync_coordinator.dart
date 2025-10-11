// lib/features/shop/data/sync/services/protobuf_sync_coordinator.dart

import 'package:fieldforce/app/services/category_tree_cache_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

import '../models/product_protobuf_converter.dart';
import '../models/stock_item_protobuf_converter.dart';
import '../models/warehouse_protobuf_converter.dart';
import '../repositories/protobuf_sync_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'regional_sync_service.dart';
import 'stock_sync_service.dart';
import 'outlet_pricing_sync_service.dart';
import 'warehouse_sync_service.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_report.dart';

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
  final WarehouseSyncService _warehouseSyncService;
  final ProductRepository _productRepository;
  final StockItemRepository _stockItemRepository;
  final WarehouseRepository _warehouseRepository;
  final CategoryTreeCacheService _categoryTreeCacheService;
  
  ProtobufSyncCoordinator({
    required RegionalSyncService regionalSyncService,
    required StockSyncService stockSyncService,
    required OutletPricingSyncService outletPricingSyncService,
    required WarehouseSyncService warehouseSyncService,
    required ProtobufSyncRepository syncRepository,
    required ProductRepository productRepository,
    required StockItemRepository stockItemRepository,
    required WarehouseRepository warehouseRepository,
  required CategoryTreeCacheService categoryTreeCacheService,
  })  : _regionalSyncService = regionalSyncService,
        _stockSyncService = stockSyncService,
        _outletPricingSyncService = outletPricingSyncService,
        _warehouseSyncService = warehouseSyncService,
        _productRepository = productRepository,
    _stockItemRepository = stockItemRepository,
    _warehouseRepository = warehouseRepository,
    _categoryTreeCacheService = categoryTreeCacheService;

  /// Простая синхронизация всех данных для региона
  Future<Map<String, dynamic>> performFullSync(
    String regionCode, {
    List<String>? outletVendorIds,
    Function(String stage, double progress)? onProgress,
  }) async {
    _logger.info('🔄 Начинаем protobuf синхронизацию для региона: $regionCode');
    
    final result = <String, dynamic>{
      'success': false,
      'products_synced': 0,
      'stock_synced': 0,
      'prices_synced': 0,
      'warehouses_synced': 0,
      'errors': <String>[],
    };
    
    try {
      onProgress?.call('Подготовка', 0.1);

      onProgress?.call('Загрузка продуктов', 0.2);
      final productsEither = await syncRegionalProducts(regionCode);
      final productsReport = productsEither.fold<SyncReport?>(
        (failure) {
          _logger.warning('⚠️ Ошибка синхронизации продуктов региона $regionCode: ${failure.message}');
          result['errors'].add(failure.message);
          result['success'] = false;
          return null;
        },
        (report) {
          result['products_synced'] = report.processedCount;
          return report;
        },
      );

      if (productsReport == null) {
        return result;
      }

      onProgress?.call('Загрузка складов и остатков', 0.6);
      final stockEither = await syncRegionalStock(regionCode);
      final stockReport = stockEither.fold<SyncReport?>(
        (failure) {
          _logger.warning('⚠️ Ошибка синхронизации остатков региона $regionCode: ${failure.message}');
          result['errors'].add(failure.message);
          result['success'] = false;
          return null;
        },
        (report) {
          result['stock_synced'] = report.details['stockItems'] is int
              ? report.details['stockItems'] as int
              : report.processedCount;
          result['warehouses_synced'] = report.details['warehouses'] as int? ?? 0;
          return report;
        },
      );

      if (stockReport == null) {
        return result;
      }

      if (outletVendorIds != null && outletVendorIds.isNotEmpty) {
        onProgress?.call('Загрузка цен торговых точек', 0.8);

        final pricesEither = await syncOutletPrices(outletVendorIds);
        final pricesReport = pricesEither.fold<SyncReport?>(
          (failure) {
            _logger.warning('⚠️ Ошибка синхронизации цен торговых точек: ${failure.message}');
            result['errors'].add(failure.message);
            result['success'] = false;
            return null;
          },
          (report) {
            result['prices_synced'] = report.processedCount;
            return report;
          },
        );

        if (pricesReport == null) {
          return result;
        }
      } else {
        _logger.info('💰 Торговые точки не указаны — пропускаем синхронизацию цен');
      }

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
  Future<Map<String, dynamic>> syncProductsOnly(String regionCode) async {
    _logger.info('📦 Быстрая синхронизация продуктов для $regionCode');
    
    final result = <String, dynamic>{
      'success': false,
      'products_synced': 0,
      'errors': <String>[],
    };
    
    try {
  final response = await _regionalSyncService.getRegionalProducts(regionCode);
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

  Future<Either<Failure, SyncReport>> syncRegionalProducts(String regionCode) async {
    final start = DateTime.now();

    try {
      final regionalResponse = await _regionalSyncService.getRegionalProducts(regionCode);
      final products = ProductProtobufConverter.fromProtobufList(regionalResponse.products);

      Failure? failure;
      final saveResult = await _productRepository.saveProducts(products);
      saveResult.fold((f) => failure = f, (_) {});

      if (failure != null) {
        return Left(failure!);
      }

      final duration = DateTime.now().difference(start);

      return Right(
        SyncReport(
          processedCount: products.length,
          duration: duration,
          description: 'Загружено ${products.length} продуктов региона $regionCode',
          details: <String, dynamic>{
            'region': regionCode,
            'products': products.length,
            'cacheVersion': regionalResponse.cacheVersion,
          },
        ),
      );
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка синхронизации продуктов региона $regionCode', e, stackTrace);
      return Left(GeneralFailure('Ошибка синхронизации продуктов региона $regionCode: $e', details: stackTrace));
    }
  }

  Future<Either<Failure, SyncReport>> syncRegionalStock(String regionCode) async {
    final start = DateTime.now();

    try {
      final warehouseResponse = await _warehouseSyncService.fetchWarehouses(regionVendorId: regionCode);
      final warehouses = WarehouseProtobufConverter.fromProtoList(warehouseResponse.warehouses);

      Failure? failure;

      final clearResult = await _warehouseRepository.clearWarehousesByRegion(regionCode);
      clearResult.fold((f) => failure = f, (_) {});
      if (failure != null) {
        return Left(failure!);
      }

      final saveWarehouseResult = await _warehouseRepository.saveWarehouses(warehouses);
      saveWarehouseResult.fold((f) => failure = f, (_) {});
      if (failure != null) {
        return Left(failure!);
      }

      final stockResponse = await _stockSyncService.getRegionalStock(regionCode);
      final stockItems = StockItemProtobufConverter.fromProtobufList(stockResponse.stockItems);

      final saveStockResult = await _stockItemRepository.saveStockItems(stockItems);
      saveStockResult.fold((f) => failure = f, (_) {});
      if (failure != null) {
        return Left(failure!);
      }

      var cacheUpdated = false;
      final cacheResult = await _categoryTreeCacheService.refreshRegion(regionCode);
      cacheResult.fold(
        (f) {
          cacheUpdated = false;
          _logger.warning('⚠️ Не удалось обновить кэш дерева категорий для региона $regionCode: ${f.message}');
        },
        (_) {
          cacheUpdated = true;
        },
      );

      final duration = DateTime.now().difference(start);

      return Right(
        SyncReport(
          processedCount: stockItems.length,
          duration: duration,
          description: 'Обновлено ${stockItems.length} записей остатков по региону $regionCode',
          details: <String, dynamic>{
            'region': regionCode,
            'warehouses': warehouses.length,
            'stockItems': stockItems.length,
            'cacheUpdated': cacheUpdated,
            'warehouseSyncTimestamp': warehouseResponse.syncTimestamp,
          },
        ),
      );
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка синхронизации остатков региона $regionCode', e, stackTrace);
      return Left(GeneralFailure('Ошибка синхронизации остатков региона $regionCode: $e', details: stackTrace));
    }
  }

  Future<Either<Failure, SyncReport>> syncOutletPrices(List<String> outletVendorIds) async {
    if (outletVendorIds.isEmpty) {
      return Right(
        const SyncReport(
          processedCount: 0,
          duration: Duration.zero,
          description: 'Нет торговых точек для синхронизации цен',
          details: <String, dynamic>{'outlets': <String>[]},
        ),
      );
    }

    final start = DateTime.now();
  final errors = <String>[];
  final perOutlet = <Map<String, dynamic>>[];
    var totalPrices = 0;

    for (final vendorId in outletVendorIds) {
      final attemptStarted = DateTime.now();
      try {
        final response = await _outletPricingSyncService.getOutletPrices(vendorId);
        final outletPricingCount = response.outletPricing.length;
        totalPrices += outletPricingCount;
        perOutlet.add(<String, dynamic>{
          'outlet': vendorId,
          'status': 'success',
          'pricingRecords': outletPricingCount,
          'promotions': response.activePromotions.length,
          'syncTimestamp': response.syncTimestamp.toInt(),
          'durationMs': DateTime.now().difference(attemptStarted).inMilliseconds,
        });
      } catch (e, stackTrace) {
        _logger.warning('⚠️ Ошибка загрузки цен для торговой точки $vendorId: $e', e, stackTrace);
        errors.add('Точка $vendorId: $e');
        final Map<String, dynamic> failureDetails = <String, dynamic>{
          'outlet': vendorId,
          'status': 'failure',
          'error': e.toString(),
          'durationMs': DateTime.now().difference(attemptStarted).inMilliseconds,
          'stackTrace': stackTrace.toString().split('\n').take(12).join('\n'),
        };

        if (e is ProtobufPayloadException) {
          failureDetails['payloadDebug'] = e.debugData;
        }

        perOutlet.add(failureDetails);
      }
    }

    final duration = DateTime.now().difference(start);

    if (errors.isNotEmpty) {
      return Left(
        GeneralFailure(
          'Ошибки при синхронизации цен: ${errors.join("; ")}',
          details: <String, dynamic>{
            'errors': errors,
            'attemptedOutlets': outletVendorIds,
            'processedPrices': totalPrices,
            'durationMs': duration.inMilliseconds,
            'perOutlet': perOutlet,
          },
        ),
      );
    }

    return Right(
      SyncReport(
        processedCount: totalPrices,
        duration: duration,
        description: 'Обновлено $totalPrices записей цен для ${outletVendorIds.length} точек',
        details: <String, dynamic>{
          'outlets': outletVendorIds,
          'durationMs': duration.inMilliseconds,
          'perOutlet': perOutlet,
        },
      ),
    );
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

      final warehouseResult = await _warehouseRepository.getAllWarehouses();
      warehouseResult.fold(
        (failure) => stats['warehouses'] = 'Ошибка: ${failure.message}',
        (warehouses) => stats['warehouses'] = warehouses.length,
      );
      
      return stats;
    } catch (e) {
      _logger.severe('❌ Ошибка получения статистики: $e');
      return {'error': e.toString()};
    }
  }
}