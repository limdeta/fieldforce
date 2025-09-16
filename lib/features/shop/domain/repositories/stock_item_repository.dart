// lib/features/shop/domain/repositories/stock_item_repository.dart

import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';

/// Репозиторий для управления остатками и ценами товаров
/// 
/// Этот репозиторий оптимизирован для:
/// - Частых batch-обновлений остатков (синхронизация с админ-панелью)
/// - Региональной фильтрации товаров по vendorId
/// - Быстрого поиска товаров в наличии
/// - Эффективных JOIN-операций с Product при построении каталогов
abstract class StockItemRepository {
  /// Получить все остатки для конкретного продукта
  Future<Either<Failure, List<StockItem>>> getStockItemsByProductCode(int productCode);

  /// Получить остатки товаров для конкретного продавца/региона
  Future<Either<Failure, List<StockItem>>> getStockItemsByVendorId(String vendorId);

  /// Получить товары в наличии с возможностью фильтрации
  Future<Either<Failure, List<StockItem>>> getAvailableStockItems({
    String? vendorId,
    int? warehouseId,
  });

  /// Получить остаток конкретного товара на конкретном складе
  Future<Either<Failure, StockItem?>> getStockItem(int productCode, int warehouseId);

  /// Сохранить список остатков (upsert)
  Future<Either<Failure, void>> saveStockItems(List<StockItem> stockItems);

  /// Пакетное обновление остатков (для синхронизации)
  Future<Either<Failure, void>> batchUpdateStock(List<StockUpdate> updates);

  /// Пакетное обновление цен (для синхронизации)
  Future<Either<Failure, void>> batchUpdatePrices(List<PriceUpdate> updates);

  /// Удалить все остатки для склада (при удалении склада)
  Future<Either<Failure, void>> deleteStockItemsForWarehouse(int warehouseId);
}