// lib/features/shop/domain/entities/product_with_stock.dart

import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:flutter/material.dart';

/// Продукт с информацией об остатках на складе
/// 
/// Используется в каталоге для отображения доступности товара
class ProductWithStock extends Equatable {
  /// Информация о товаре
  final Product product;
  
  /// Общий остаток на всех складах пользователя
  final int totalStock;
  
  /// Максимальная цена среди всех складов
  final int maxPrice;
  
  /// Минимальная цена среди всех складов
  final int minPrice;
  
  /// Есть ли скидки на этот товар
  final bool hasDiscounts;

  const ProductWithStock({
    required this.product,
    required this.totalStock,
    required this.maxPrice,
    required this.minPrice,
    required this.hasDiscounts,
  });

  /// Товар доступен для добавления в корзину
  bool get isAvailable => totalStock > 0;

  /// Малый остаток (меньше 5 штук)
  bool get isLowStock => totalStock > 0 && totalStock <= 5;

  /// Большой остаток (больше 5 штук) 
  bool get isInStock => totalStock > 5;

  /// Товар отсутствует на складе
  bool get isOutOfStock => totalStock == 0;

  /// Цена для отображения (минимальная если есть диапазон)
  int get displayPrice => minPrice;

  /// Есть ли диапазон цен 
  bool get hasPriceRange => maxPrice != minPrice;

  /// Текст статуса остатков для UI
  String get stockStatusText {
    if (isOutOfStock) return 'Нет на складе';
    if (isLowStock) return 'Малый остаток: $totalStock шт';
    return 'В наличии: $totalStock шт';
  }

  /// Цвет для индикации остатков
  StockStatusColor get stockStatusColor {
    if (isOutOfStock) return StockStatusColor.red;
    if (isLowStock) return StockStatusColor.yellow; 
    return StockStatusColor.green;
  }

  @override
  List<Object?> get props => [
    product,
    totalStock,
    maxPrice,
    minPrice,
    hasDiscounts,
  ];
}

/// Цвета для индикации остатков
enum StockStatusColor {
  green,   // В наличии
  yellow,  // Малый остаток  
  red,     // Нет на складе
}

/// Extension для получения UI свойств статуса остатков
extension StockStatusColorExt on StockStatusColor {
  Color get color {
    switch (this) {
      case StockStatusColor.green:
        return const Color(0xFF4CAF50);
      case StockStatusColor.yellow:  
        return const Color(0xFFFF9800);
      case StockStatusColor.red:
        return const Color(0xFFF44336);
    }
  }
  
  IconData get icon {
    switch (this) {
      case StockStatusColor.green:
        return Icons.check_circle;
      case StockStatusColor.yellow:
        return Icons.warning;
      case StockStatusColor.red:
        return Icons.cancel;
    }
  }
}