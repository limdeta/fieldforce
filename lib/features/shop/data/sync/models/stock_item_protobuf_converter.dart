import '../generated/stockitem.pb.dart' as pb;
import '../../../domain/entities/stock_item.dart';
import 'dart:convert';

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
      priceType: null, // Региональные цены всегда regional_base
      promotionJson: null, // Protobuf пока не содержит детальной информации об акциях
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Конвертирует список protobuf RegionalStockItems в domain StockItems
  static List<StockItem> fromProtobufList(List<pb.RegionalStockItem> pbStockItems) {
    return pbStockItems.map(fromProtobuf).toList();
  }
  
  /// Конвертирует protobuf OutletStockPricing в обновление StockItem
  /// 
  /// OutletStockPricing содержит дифференциальные цены для конкретной торговой точки.
  /// Этот метод определяет тип цены и заполняет соответствующие поля:
  /// - priceType = "promotion" → данные идут в offerPrice
  /// - priceType = "differential_price" → данные идут в availablePrice  
  /// - priceType = "regional_base" → используется defaultPrice (regionalBasePrice)
  static Map<String, dynamic> fromOutletPricing(pb.OutletStockPricing pricing) {
    int? offerPrice;
    int? availablePrice;
    String? promotionJson;
    String? priceType;
    
    if (pricing.hasPriceType()) {
      priceType = pricing.priceType;
      
      switch (pricing.priceType) {
        case 'promotion':
          // Акционная цена → offerPrice
          offerPrice = pricing.finalPrice;
          
          // Сериализуем информацию об акции в JSON
          if (pricing.hasPromotion && pricing.hasPromotion_11()) {
            final promotion = pricing.promotion_11;
            promotionJson = jsonEncode({
              'promotionId': promotion.promotionId.toInt(), // Int64 → int
              'promotionType': promotion.promotionType,
              'title': promotion.title,
              'description': promotion.description,
              'validFrom': promotion.validFrom.toInt(), // Int64 → int
              'validTo': promotion.validTo.toInt(), // Int64 → int
              'applicableProducts': promotion.applicableProducts.map((e) => e.toInt()).toList(), // List<Int64> → List<int>
            });
          }
          break;
          
        case 'differential_price':
          // Индивидуальная цена для торговой точки → availablePrice
          availablePrice = pricing.finalPrice;
          break;
          
        case 'regional_base':
        default:
          // Региональная базовая цена уже в defaultPrice, ничего не делаем
          break;
      }
    }
    
    return {
      'productCode': pricing.productCode,
      'warehouseId': pricing.warehouseId,
      'offerPrice': offerPrice,
      'availablePrice': availablePrice,
      'priceType': priceType,
      'promotionJson': promotionJson,
      'discountValue': pricing.hasDiscountValue() ? pricing.discountValue.toInt() : 0,
    };
  }


}