// lib/app/database/repositories/stock_item_repository_drift.dart

import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/app/database/mappers/stock_item_mapper.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:logging/logging.dart';

class DriftStockItemRepository implements StockItemRepository {
  static final Logger _logger = Logger('DriftStockItemRepository');
  final AppDatabase _database = GetIt.instance<AppDatabase>();

  @override
  Future<Either<Failure, List<StockItem>>> getStockItemsByProductCode(int productCode) async {
    try {
      final entities = await (_database.select(_database.stockItems)
        ..where((tbl) => tbl.productCode.equals(productCode))
      ).get();

      final stockItems = StockItemMapper.fromDataList(entities);
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

      final stockItems = StockItemMapper.fromDataList(entities);
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
      final stockItems = StockItemMapper.fromDataList(entities);
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

      final stockItem = StockItemMapper.fromData(entity);
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
    
    if (productExists == null) {
      _logger.warning('⚠️ Попытка сохранить StockItem для несуществующего продукта с кодом ${stockItem.productCode}');
      return; // Пропускаем сохранение StockItem если продукт не существует
    }
    
    // Проверяем существует ли уже StockItem с такой комбинацией productCode + warehouseId
    final existing = await (_database.select(_database.stockItems)
      ..where((tbl) => 
        tbl.productCode.equals(stockItem.productCode) & 
        tbl.warehouseId.equals(stockItem.warehouseId)
      )
    ).getSingleOrNull();
    
    final companion = StockItemMapper.toCompanion(stockItem, excludeId: true);
    
    if (existing != null) {
      // Обновляем существующий StockItem
      await (_database.update(_database.stockItems)
        ..where((tbl) => 
          tbl.productCode.equals(stockItem.productCode) & 
          tbl.warehouseId.equals(stockItem.warehouseId)
        )
      ).write(companion);
      _logger.fine('Обновлен StockItem для продукта ${stockItem.productCode}, склад ${stockItem.warehouseId}');
    } else {
      // Создаем новый StockItem
      await _database.into(_database.stockItems).insert(companion);
      _logger.fine('Создан новый StockItem для продукта ${stockItem.productCode}, склад ${stockItem.warehouseId}');
    }
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
          ).write(StockItemMapper.toStockUpdateCompanion(update));
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
          ).write(StockItemMapper.toPriceUpdateCompanion(update));
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

  // Маппинг теперь вынесен в StockItemMapper для лучшей организации кода

  @override
  Future<Either<Failure, StockItem>> getById(int stockItemId) async {
    try {
      final entity = await (_database.select(_database.stockItems)
        ..where((tbl) => tbl.id.equals(stockItemId))
      ).getSingle();

      final stockItem = StockItemMapper.fromData(entity);
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