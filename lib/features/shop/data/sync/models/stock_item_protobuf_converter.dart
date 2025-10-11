import '../generated/stockitem.pb.dart' as pb;
import '../../../domain/entities/stock_item.dart';

/// Конвертор для преобразования protobuf RegionalStockItem в domain StockItem
class StockItemProtobufConverter {
  
  /// Конвертирует protobuf RegionalStockItem в domain StockItem
  static StockItem fromProtobuf(pb.RegionalStockItem pbStockItem) {
    final now = DateTime.now();
    
    return StockItem(
      id: pbStockItem.id,
      productCode: pbStockItem.productCode,
      warehouseId: pbStockItem.hasWarehouse() ? pbStockItem.warehouse.id : 0,
      warehouseName: pbStockItem.hasWarehouse() ? pbStockItem.warehouse.name : 'Неизвестный склад',
      warehouseVendorId: pbStockItem.hasWarehouse() ? pbStockItem.warehouse.vendorId : '',
      isPickUpPoint: pbStockItem.hasWarehouse() ? pbStockItem.warehouse.isPickUpPoint : false,
      stock: pbStockItem.stock, // Используем новое числовое поле stock
      multiplicity: pbStockItem.multiplicity > 0 ? pbStockItem.multiplicity : null,
      publicStock: pbStockItem.publicStock,
      defaultPrice: pbStockItem.regionalBasePrice,
      discountValue: 0, // Protobuf пока не содержит информации о скидках
      availablePrice: pbStockItem.regionalBasePrice, // Используем базовую цену как доступную
      offerPrice: null, // Protobuf пока не содержит информации об акционных ценах
      currency: 'RUB', // По умолчанию рубли (можно сделать настраиваемым)
      promotionJson: null, // Protobuf пока не содержит детальной информации об акциях
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Конвертирует список protobuf RegionalStockItems в domain StockItems
  static List<StockItem> fromProtobufList(List<pb.RegionalStockItem> pbStockItems) {
    return pbStockItems.map(fromProtobuf).toList();
  }


}