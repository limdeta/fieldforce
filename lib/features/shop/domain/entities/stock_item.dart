// lib/features/shop/domain/entities/stock_item.dart

import 'package:equatable/equatable.dart';

/// Остатки и цены товара на конкретном складе
/// 
/// Это денормализованная сущность для высокой производительности:
/// - Содержит данные о складе для избежания JOIN-ов
/// - Оптимизирована для частых batch-обновлений остатков и цен
/// - Поддерживает региональную фильтрацию по vendorId
class StockItem extends Equatable {
  /// Уникальный ID записи остатка
  final int id;

  /// Код продукта (ссылка на Product.code)
  final int productCode;

  /// Данные склада (денормализованы для производительности)
  final int warehouseId;
  final String warehouseName;
  final String warehouseVendorId; // Для региональной фильтрации
  final bool isPickUpPoint;

  /// Остатки товара
  final int stock;
  final int? multiplicity;
  final String publicStock;

  /// Цены (в копейках, как и везде в проекте)
  final int defaultPrice;
  final int discountValue;
  final int? availablePrice;
  final int? offerPrice; // Акционная цена (может быть null)
  final String currency;

  /// Дополнительная информация о промоакции (JSON)
  final String? promotionJson;

  /// Метки времени
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockItem({
    required this.id,
    required this.productCode,
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseVendorId,
    required this.isPickUpPoint,
    required this.stock,
    this.multiplicity,
    required this.publicStock,
    required this.defaultPrice,
    this.discountValue = 0,
    this.availablePrice,
    this.offerPrice,
    required this.currency,
    this.promotionJson,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Эффективная цена (акционная или базовая)
  int get effectivePrice => offerPrice ?? defaultPrice;

  /// Есть ли товар в наличии
  bool get isAvailable => stock > 0;

  /// Есть ли скидка
  bool get hasDiscount => offerPrice != null && offerPrice! < defaultPrice;

  /// Размер скидки в процентах
  double get discountPercent {
    if (!hasDiscount) return 0.0;
    return ((defaultPrice - offerPrice!) / defaultPrice) * 100;
  }

  /// Создание копии с изменениями
  StockItem copyWith({
    int? id,
    int? productCode,
    int? warehouseId,
    String? warehouseName,
    String? warehouseVendorId,
    bool? isPickUpPoint,
    int? stock,
    int? multiplicity,
    String? publicStock,
    int? defaultPrice,
    int? discountValue,
    int? availablePrice,
    int? offerPrice,
    String? currency,
    String? promotionJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockItem(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseVendorId: warehouseVendorId ?? this.warehouseVendorId,
      isPickUpPoint: isPickUpPoint ?? this.isPickUpPoint,
      stock: stock ?? this.stock,
      multiplicity: multiplicity ?? this.multiplicity,
      publicStock: publicStock ?? this.publicStock,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      discountValue: discountValue ?? this.discountValue,
      availablePrice: availablePrice ?? this.availablePrice,
      offerPrice: offerPrice ?? this.offerPrice,
      currency: currency ?? this.currency,
      promotionJson: promotionJson ?? this.promotionJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productCode,
        warehouseId,
        warehouseName,
        warehouseVendorId,
        isPickUpPoint,
        stock,
        multiplicity,
        publicStock,
        defaultPrice,
        discountValue,
        availablePrice,
        offerPrice,
        currency,
        promotionJson,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'StockItem(id: $id, productCode: $productCode, '
        'warehouse: $warehouseName(id: $warehouseId), '
        'stock: $stock, price: $effectivePrice $currency)';
  }
}

/// DTO для пакетного обновления остатков
class StockUpdate extends Equatable {
  final int productCode;
  final int warehouseId;
  final int newStock;

  const StockUpdate({
    required this.productCode,
    required this.warehouseId,
    required this.newStock,
  });

  @override
  List<Object?> get props => [productCode, warehouseId, newStock];
}

/// DTO для пакетного обновления цен
class PriceUpdate extends Equatable {
  final int productCode;
  final int warehouseId;
  final int? defaultPrice;
  final int? offerPrice;

  const PriceUpdate({
    required this.productCode,
    required this.warehouseId,
    this.defaultPrice,
    this.offerPrice,
  });

  @override
  List<Object?> get props => [productCode, warehouseId, defaultPrice, offerPrice];
}