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
      stock: _parseStockFromPublicStock(pbStockItem.publicStock),
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

  /// Парсит строку остатков в числовое значение
  /// 
  /// publicStock может содержать:
  /// - "available" -> большое количество (9999)
  /// - "limited" -> ограниченное количество (5)
  /// - число в строке -> точное количество
  /// - пустая строка -> 0
  static int _parseStockFromPublicStock(String publicStock) {
    if (publicStock.isEmpty) {
      return 0;
    }
    
    switch (publicStock.toLowerCase()) {
      case 'available':
        return 9999; // Показываем как "много в наличии"
      case 'limited':
        return 5; // Показываем как "ограниченное количество"
      default:
        // Пытаемся распарсить как число
        final parsed = int.tryParse(publicStock);
        return parsed ?? 0;
    }
  }
}