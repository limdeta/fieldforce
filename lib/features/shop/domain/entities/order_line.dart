import 'package:equatable/equatable.dart';
import 'product.dart';

/// Строка заказа - конкретный товар со склада с количеством и ценой
class OrderLine extends Equatable {
  final int? id;
  final int orderId;
  final StockItem stockItem; // Конкретный остаток на складе (содержит Product + Warehouse + цены)
  final int quantity;
  final int pricePerUnit; // в копейках (может отличаться от цены в StockItem из-за скидок)
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderLine({
    this.id,
    required this.orderId,
    required this.stockItem,
    required this.quantity,
    required this.pricePerUnit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создает новую строку заказа
  factory OrderLine.create({
    required int orderId,
    required StockItem stockItem,
    required int quantity,
    int? pricePerUnit,
  }) {
    final now = DateTime.now();
    return OrderLine(
      orderId: orderId,
      stockItem: stockItem,
      quantity: quantity,
      pricePerUnit: pricePerUnit ?? stockItem.offerPrice, // Используем цену предложения по умолчанию
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Удобный доступ к продукту через stockItem
  Product get product => stockItem.product;

  /// Удобный доступ к складу
  Warehouse get warehouse => stockItem.warehouse;

  /// Общая стоимость строки заказа
  int get totalCost => quantity * pricePerUnit;

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
    int? quantity,
    int? pricePerUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderLine(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      stockItem: stockItem ?? this.stockItem,
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
        quantity,
        pricePerUnit,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'OrderLine(id: $id, product: ${product.title}, quantity: $quantity, pricePerUnit: $pricePerUnit)';
  }
}