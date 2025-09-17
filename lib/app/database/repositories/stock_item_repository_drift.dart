// lib/app/database/repositories/stock_item_repository_drift.dart

import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:logging/logging.dart';

/// Drift реализация репозитория остатков и цен товаров
class DriftStockItemRepository implements StockItemRepository {
  static final Logger _logger = Logger('DriftStockItemRepository');
  final AppDatabase _database = GetIt.instance<AppDatabase>();

  @override
  Future<Either<Failure, List<StockItem>>> getStockItemsByProductCode(int productCode) async {
    try {
      final entities = await (_database.select(_database.stockItems)
        ..where((tbl) => tbl.productCode.equals(productCode))
      ).get();

      final stockItems = entities.map(_mapToStockItem).toList();
      return Right(stockItems);
    } catch (e, st) {
      _logger.severe('Ошибка получения остатков для продукта $productCode', e, st);
      return Left(DatabaseFailure('Ошибка получения остатков: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> getStockItemsByVendorId(String vendorId) async {
    try {
      final entities = await (_database.select(_database.stockItems)
        ..where((tbl) => tbl.warehouseVendorId.equals(vendorId))
      ).get();

      final stockItems = entities.map(_mapToStockItem).toList();
      return Right(stockItems);
    } catch (e, st) {
      _logger.severe('Ошибка получения остатков для продавца $vendorId', e, st);
      return Left(DatabaseFailure('Ошибка получения остатков: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StockItem>>> getAvailableStockItems({
    String? vendorId,
    int? warehouseId,
  }) async {
    try {
      final query = _database.select(_database.stockItems)
        ..where((tbl) => tbl.stock.isBiggerThanValue(0));
      
      if (vendorId != null) {
        query.where((tbl) => tbl.warehouseVendorId.equals(vendorId));
      }
      
      if (warehouseId != null) {
        query.where((tbl) => tbl.warehouseId.equals(warehouseId));
      }

      final entities = await query.get();
      final stockItems = entities.map(_mapToStockItem).toList();
      return Right(stockItems);
    } catch (e, st) {
      _logger.severe('Ошибка получения доступных остатков', e, st);
      return Left(DatabaseFailure('Ошибка получения остатков: $e'));
    }
  }

  @override
  Future<Either<Failure, StockItem?>> getStockItem(int productCode, int warehouseId) async {
    try {
      final entity = await (_database.select(_database.stockItems)
        ..where((tbl) => tbl.productCode.equals(productCode) & tbl.warehouseId.equals(warehouseId))
      ).getSingleOrNull();

      if (entity == null) return const Right(null);

      final stockItem = _mapToStockItem(entity);
      return Right(stockItem);
    } catch (e, st) {
      _logger.severe('Ошибка получения остатка для продукта $productCode на складе $warehouseId', e, st);
      return Left(DatabaseFailure('Ошибка получения остатка: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveStockItems(List<StockItem> stockItems) async {
    try {
      await _database.transaction(() async {
        for (final stockItem in stockItems) {
          await _saveStockItem(stockItem);
        }
      });
      
      _logger.info('Сохранено ${stockItems.length} остатков товаров');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка сохранения остатков', e, st);
      return Left(DatabaseFailure('Ошибка сохранения остатков: $e'));
    }
  }

  Future<void> _saveStockItem(StockItem stockItem) async {
    // 🔍 Проверяем существует ли продукт с таким кодом
    final productExists = await (_database.select(_database.products)
      ..where((tbl) => tbl.code.equals(stockItem.productCode))
    ).getSingleOrNull();
    
    _logger.info('🔍 StockItem productCode=${stockItem.productCode}: продукт существует=${productExists != null}');
    if (productExists != null) {
      _logger.info('🔍 Найден продукт: id=${productExists.id}, code=${productExists.code}, catalogId=${productExists.catalogId}');
    }
    
    final companion = _mapToStockItemData(stockItem);
    
    // Просто INSERT - если есть конфликт UNIQUE, то произойдет ошибка которая поможет найти проблему
    await _database.into(_database.stockItems).insert(companion);
  }

  @override
  Future<Either<Failure, void>> batchUpdateStock(List<StockUpdate> updates) async {
    try {
      await _database.transaction(() async {
        for (final update in updates) {
          await (_database.update(_database.stockItems)
            ..where((tbl) => 
              tbl.productCode.equals(update.productCode) & 
              tbl.warehouseId.equals(update.warehouseId)
            )
          ).write(StockItemsCompanion(
            stock: Value(update.newStock),
            updatedAt: Value(DateTime.now()),
          ));
        }
      });
      
      _logger.info('Обновлено остатков: ${updates.length}');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка пакетного обновления остатков', e, st);
      return Left(DatabaseFailure('Ошибка обновления остатков: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> batchUpdatePrices(List<PriceUpdate> updates) async {
    try {
      await _database.transaction(() async {
        for (final update in updates) {
          await (_database.update(_database.stockItems)
            ..where((tbl) => 
              tbl.productCode.equals(update.productCode) & 
              tbl.warehouseId.equals(update.warehouseId)
            )
          ).write(StockItemsCompanion(
            defaultPrice: update.defaultPrice != null ? Value(update.defaultPrice!) : const Value.absent(),
            offerPrice: update.offerPrice != null ? Value(update.offerPrice!) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ));
        }
      });
      
      _logger.info('Обновлено цен: ${updates.length}');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка пакетного обновления цен', e, st);
      return Left(DatabaseFailure('Ошибка обновления цен: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStockItemsForWarehouse(int warehouseId) async {
    try {
      final deletedCount = await (_database.delete(_database.stockItems)
        ..where((tbl) => tbl.warehouseId.equals(warehouseId))
      ).go();
      
      _logger.info('Удалено остатков для склада $warehouseId: $deletedCount');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка удаления остатков для склада $warehouseId', e, st);
      return Left(DatabaseFailure('Ошибка удаления остатков: $e'));
    }
  }

  /// Маппинг из БД в доменную модель
  StockItem _mapToStockItem(StockItemData data) {
    return StockItem(
      id: data.id,
      productCode: data.productCode,
      warehouseId: data.warehouseId,
      warehouseName: data.warehouseName,
      warehouseVendorId: data.warehouseVendorId,
      isPickUpPoint: data.isPickUpPoint,
      stock: data.stock,
      multiplicity: data.multiplicity,
      publicStock: data.publicStock,
      defaultPrice: data.defaultPrice,
      discountValue: data.discountValue,
      availablePrice: data.availablePrice,
      offerPrice: data.offerPrice,
      currency: data.currency,
      promotionJson: data.promotionJson,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Маппинг из доменной модели в БД
  StockItemsCompanion _mapToStockItemData(StockItem stockItem) {
    return StockItemsCompanion(
      id: stockItem.id == 0 ? const Value.absent() : Value(stockItem.id),
      productCode: Value(stockItem.productCode),
      warehouseId: Value(stockItem.warehouseId),
      warehouseName: Value(stockItem.warehouseName),
      warehouseVendorId: Value(stockItem.warehouseVendorId),
      isPickUpPoint: Value(stockItem.isPickUpPoint),
      stock: Value(stockItem.stock),
      multiplicity: stockItem.multiplicity != null ? Value(stockItem.multiplicity!) : const Value.absent(),
      publicStock: Value(stockItem.publicStock),
      defaultPrice: Value(stockItem.defaultPrice),
      discountValue: Value(stockItem.discountValue),
      availablePrice: stockItem.availablePrice != null ? Value(stockItem.availablePrice!) : const Value.absent(),
      offerPrice: stockItem.offerPrice != null ? Value(stockItem.offerPrice!) : const Value.absent(),
      currency: Value(stockItem.currency),
      promotionJson: Value(stockItem.promotionJson),
      createdAt: Value(stockItem.createdAt),
      updatedAt: Value(stockItem.updatedAt),
    );
  }

  @override
  Future<Either<Failure, StockItem>> getById(int stockItemId) async {
    try {
      final entity = await (_database.select(_database.stockItems)
        ..where((tbl) => tbl.id.equals(stockItemId))
      ).getSingle();

      final stockItem = _mapToStockItem(entity);
      return Right(stockItem);
    } catch (e, st) {
      _logger.severe('Ошибка получения остатка по ID $stockItemId', e, st);
      return Left(DatabaseFailure('Остаток с ID $stockItemId не найден: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllStockItems() async {
    try {
      await _database.delete(_database.stockItems).go();
      _logger.info('Все остатки очищены');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка очистки остатков', e, st);
      return Left(DatabaseFailure('Ошибка очистки остатков: $e'));
    }
  }
}