import 'package:equatable/equatable.dart';
import 'stock_item.dart';
import 'product.dart';

/// Строка заказа - конкретный товар со склада с количеством и ценой
class OrderLine extends Equatable {
  final int? id;
  final int orderId;
  final StockItem stockItem; // Конкретный остаток на складе (содержит Product + Warehouse + цены)
  final Product? product; // Продукт для UI (может быть null если не загружен)
  final int quantity;
  final int pricePerUnit; // в копейках (может отличаться от цены в StockItem из-за скидок)
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderLine({
    this.id,
    required this.orderId,
    required this.stockItem,
    this.product,
    required this.quantity,
    required this.pricePerUnit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создает новую строку заказа
  factory OrderLine.create({
    required int orderId,
    required StockItem stockItem,
    Product? product,
    required int quantity,
    int? pricePerUnit,
  }) {
    final now = DateTime.now();
    return OrderLine(
      orderId: orderId,
      stockItem: stockItem,
      product: product,
      quantity: quantity,
      pricePerUnit: pricePerUnit ?? stockItem.defaultPrice, // Используем базовую цену по умолчанию
      createdAt: now,
      updatedAt: now,
    );
  }

  /// ID продукта из stockItem
  int get productCode => stockItem.productCode;

  /// ID склада из stockItem
  int get warehouseId => stockItem.warehouseId;

  /// Общая стоимость строки заказа
  int get totalCost => quantity * pricePerUnit;

  // UI геттеры для удобства
  /// Название товара для отображения в UI
  String get productTitle => product?.title ?? 'Товар №$productCode';
  
  /// Описание товара
  String get productDescription => product?.description ?? '';
  
  /// Артикул товара
  String get productVendorCode => product?.vendorCode ?? '';
  
  /// Имя склада для UI
  String get warehouseName => stockItem.warehouseName;

  /// Экономия по сравнению с базовой ценой (если есть скидка)
  int get saving {
    final basePrice = stockItem.defaultPrice;
    if (basePrice > pricePerUnit) {
      return (basePrice - pricePerUnit) * quantity;
    }
    return 0;
  }

  /// Общая стоимость по базовой цене без скидки
  int get totalBaseCost {
    return quantity * stockItem.defaultPrice;
  }

  /// Обновляет количество товара в строке
  OrderLine updateQuantity(int newQuantity) {
    if (newQuantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }
    
    return copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
  }

  /// Обновляет цену за единицу товара
  OrderLine updatePrice(int newPricePerUnit) {
    if (newPricePerUnit <= 0) {
      throw ArgumentError('Price must be positive');
    }
    
    return copyWith(
      pricePerUnit: newPricePerUnit,
      updatedAt: DateTime.now(),
    );
  }

  OrderLine copyWith({
    int? id,
    int? orderId,
    StockItem? stockItem,
    Product? product,
    int? quantity,
    int? pricePerUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderLine(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      stockItem: stockItem ?? this.stockItem,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        stockItem,
        product,
        quantity,
        pricePerUnit,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'OrderLine(id: $id, productCode: $productCode, quantity: $quantity, pricePerUnit: $pricePerUnit)';
  }
}