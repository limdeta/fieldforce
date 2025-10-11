// lib/features/shop/data/sync/models/product_with_price.dart

import 'package:equatable/equatable.dart';

/// Объединенная модель продукта с итоговой ценой для торговой точки
/// 
/// Эта модель объединяет:
/// - Базовую информацию о продукте (из Regional sync)
/// - Остатки на складах (из Regional Stock sync) 
/// - Итоговую цену для конкретной торговой точки (из Outlet Pricing sync)
class ProductWithPrice extends Equatable {
  /// Базовая информация о продукте
  final ProductInfo product;
  
  /// Остатки и склады
  final List<StockInfo> stockItems;
  
  /// Итоговая цена для отображения (в копейках)
  final int finalPrice;
  
  /// Тип цены: "regional_base", "differential_price", "promotion"
  final String priceType;
  
  /// Базовая цена региона (для сравнения)
  final int? regionalBasePrice;
  
  /// Разница с региональной ценой (в копейках)
  final int? priceDifference;
  
  /// Разница с региональной ценой (в процентах)
  final double? priceDifferencePercent;
  
  /// Есть ли активная акция
  final bool hasPromotion;
  
  /// ID торговой точки для которой рассчитана цена
  final String outletVendorId;
  
  /// Информация об активной акции
  final PromotionInfo? promotion;

  const ProductWithPrice({
    required this.product,
    required this.stockItems,
    required this.finalPrice,
    required this.priceType,
    required this.outletVendorId,
    this.regionalBasePrice,
    this.priceDifference,
    this.priceDifferencePercent,
    this.hasPromotion = false,
    this.promotion,
  });

  /// Есть ли скидка относительно региональной цены
  bool get hasDiscount => priceDifference != null && priceDifference! < 0;
  
  /// Есть ли наценка относительно региональной цены
  bool get hasMarkup => priceDifference != null && priceDifference! > 0;
  
  /// Размер скидки в процентах (положительное число)
  double get discountPercent {
    if (!hasDiscount || priceDifferencePercent == null) return 0.0;
    return priceDifferencePercent!.abs();
  }
  
  /// Размер наценки в процентах
  double get markupPercent {
    if (!hasMarkup || priceDifferencePercent == null) return 0.0;
    return priceDifferencePercent!;
  }
  
  /// Есть ли товар в наличии
  bool get isAvailable => stockItems.any((stock) => stock.availableQuantity > 0);
  
  /// Общий остаток по всем складам
  int get totalStock => stockItems.fold(0, (sum, stock) => sum + stock.quantity);
  
  /// Доступно к продаже по всем складам
  int get totalAvailable => stockItems.fold(0, (sum, stock) => sum + stock.availableQuantity);
  
  /// Форматированная цена для отображения
  String get formattedPrice => '${(finalPrice / 100).toStringAsFixed(2)} ₽';
  
  /// Форматированная региональная цена
  String get formattedRegionalPrice {
    if (regionalBasePrice == null) return '';
    return '${(regionalBasePrice! / 100).toStringAsFixed(2)} ₽';
  }

  @override
  List<Object?> get props => [
        product,
        stockItems,
        finalPrice,
        priceType,
        regionalBasePrice,
        priceDifference,
        priceDifferencePercent,
        hasPromotion,
        outletVendorId,
        promotion,
      ];

  ProductWithPrice copyWith({
    ProductInfo? product,
    List<StockInfo>? stockItems,
    int? finalPrice,
    String? priceType,
    int? regionalBasePrice,
    int? priceDifference,
    double? priceDifferencePercent,
    bool? hasPromotion,
    String? outletVendorId,
    PromotionInfo? promotion,
  }) {
    return ProductWithPrice(
      product: product ?? this.product,
      stockItems: stockItems ?? this.stockItems,
      finalPrice: finalPrice ?? this.finalPrice,
      priceType: priceType ?? this.priceType,
      outletVendorId: outletVendorId ?? this.outletVendorId,
      regionalBasePrice: regionalBasePrice ?? this.regionalBasePrice,
      priceDifference: priceDifference ?? this.priceDifference,
      priceDifferencePercent: priceDifferencePercent ?? this.priceDifferencePercent,
      hasPromotion: hasPromotion ?? this.hasPromotion,
      promotion: promotion ?? this.promotion,
    );
  }
}

/// Базовая информация о продукте (из региональной синхронизации)
class ProductInfo extends Equatable {
  final int code;
  final int bcode;
  final String title;
  final String vendorCode;
  final List<String> barcodes;
  final bool isMarked;
  final bool novelty;
  final bool popular;
  final int amountInPackage;
  final bool canBuy;
  
  // Бренд и производитель
  final String? brandName;
  final String? manufacturerName;
  
  // Категории
  final String? categoryName;
  final String? typeName;
  final String? seriesName;
  
  // Изображения
  final String? defaultImageUrl;
  final List<String> imageUrls;
  
  // Описания
  final String? description;
  final String? howToUse;
  final String? ingredients;

  const ProductInfo({
    required this.code,
    required this.bcode,
    required this.title,
    required this.vendorCode,
    required this.barcodes,
    required this.isMarked,
    required this.novelty,
    required this.popular,
    required this.amountInPackage,
    required this.canBuy,
    this.brandName,
    this.manufacturerName,
    this.categoryName,
    this.typeName,
    this.seriesName,
    this.defaultImageUrl,
    this.imageUrls = const [],
    this.description,
    this.howToUse,
    this.ingredients,
  });

  @override
  List<Object?> get props => [
        code, bcode, title, vendorCode, barcodes,
        isMarked, novelty, popular, amountInPackage, canBuy,
        brandName, manufacturerName, categoryName, typeName, seriesName,
        defaultImageUrl, imageUrls, description, howToUse, ingredients,
      ];
}

/// Информация об остатках на складе
class StockInfo extends Equatable {
  final int stockItemId;
  final int warehouseId;
  final String warehouseName;
  final String warehouseVendorId;
  final String publicStock; // "1666 шт."
  final int quantity;
  final int reservedQuantity;
  final int availableQuantity;
  final int multiplicity;
  final bool isPickUpPoint;

  const StockInfo({
    required this.stockItemId,
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseVendorId,
    required this.publicStock,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.multiplicity,
    required this.isPickUpPoint,
  });

  @override
  List<Object?> get props => [
        stockItemId, warehouseId, warehouseName, warehouseVendorId,
        publicStock, quantity, reservedQuantity, availableQuantity,
        multiplicity, isPickUpPoint,
      ];
}

/// Информация об активной акции
class PromotionInfo extends Equatable {
  final int promotionId;
  final String promotionType; // "discount", "nx", "bundle"
  final String title;
  final String? description;
  final DateTime validFrom;
  final DateTime validTo;
  final double? discountPercent;
  final int? discountAmount;
  final int? buyQuantity; // для NX акций
  final int? getQuantity; // для NX акций

  const PromotionInfo({
    required this.promotionId,
    required this.promotionType,
    required this.title,
    required this.validFrom,
    required this.validTo,
    this.description,
    this.discountPercent,
    this.discountAmount,
    this.buyQuantity,
    this.getQuantity,
  });

  /// Является ли акция активной в данный момент
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo);
  }

  @override
  List<Object?> get props => [
        promotionId, promotionType, title, description,
        validFrom, validTo, discountPercent, discountAmount,
        buyQuantity, getQuantity,
      ];
}