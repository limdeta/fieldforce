// lib/app/database\mappers\stock_item_mapper.dart

import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:drift/drift.dart';

class StockItemMapper {
  static StockItem fromData(StockItemData data) {
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

  static StockItemsCompanion toCompanion(StockItem stockItem, {bool excludeId = false}) {
    return StockItemsCompanion(
      id: excludeId || stockItem.id == 0 ? const Value.absent() : Value(stockItem.id),
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
      updatedAt: Value(DateTime.now()),
    );
  }

  static StockItemsCompanion toPriceUpdateCompanion(PriceUpdate update) {
    return StockItemsCompanion(
      defaultPrice: update.defaultPrice != null ? Value(update.defaultPrice!) : const Value.absent(),
      offerPrice: update.offerPrice != null ? Value(update.offerPrice!) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }

  static StockItemsCompanion toStockUpdateCompanion(StockUpdate update) {
    return StockItemsCompanion(
      stock: Value(update.newStock),
      updatedAt: Value(DateTime.now()),
    );
  }

  static List<StockItem> fromDataList(List<StockItemData> dataList) {
    return dataList.map(fromData).toList();
  }

  static List<StockItemsCompanion> toCompanionList(List<StockItem> stockItems, {bool excludeId = false}) {
    return stockItems.map((item) => toCompanion(item, excludeId: excludeId)).toList();
  }
}