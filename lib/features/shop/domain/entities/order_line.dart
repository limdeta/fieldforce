import 'package:equatable/equatable.dart';
import 'stock_item.dart';
import 'product.dart';

/// Строка заказа - конкретный товар со склада с количеством и ценой
class OrderLine extends Equatable {
  final int? id;
  final int orderId;
  final StockItem stockItem; // Конкретный остаток на складе (содержит Product + Warehouse + цены)
  final Product? product;
  final int quantity;
  final int pricePerUnit;
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

  int get productCode => stockItem.productCode;
  int get warehouseId => stockItem.warehouseId;
  int get totalCost => quantity * pricePerUnit;

  String get productTitle => product?.title ?? 'ОШИБКА: товар не найден (код: $productCode)';
  String get productDescription => product?.description ?? 'Товар не найден в базе данных';
  String get productVendorCode => product?.vendorCode ?? 'НЕТ ДАННЫХ';
  String get warehouseName => stockItem.warehouseName;

  int get saving {
    final basePrice = stockItem.defaultPrice;
    if (basePrice > pricePerUnit) {
      return (basePrice - pricePerUnit) * quantity;
    }
    return 0;
  }

  int get totalBaseCost {
    return quantity * stockItem.defaultPrice;
  }

  OrderLine updateQuantity(int newQuantity) {
    if (newQuantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }
    
    return copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
  }

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