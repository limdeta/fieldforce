// lib/features/shop/domain/entities/shop_list_item.dart

import 'product.dart';
import 'stock_item.dart';

/// Единый интерфейс для отображения товаров в списках
/// Используется как для каталога (ProductWithStock), так и для корзины (OrderLine)
abstract class ShopListItem {
  /// Продукт
  Product get product;
  
  /// Информация о складе и остатках
  StockItem get stockItem;
  
  /// Текущее количество в корзине (0 если не добавлено)
  int get cartQuantity;
  
  /// Идентификатор для обновления количества
  String get updateKey;
  
  // Удобные геттеры для UI
  String get productTitle => product.title;
  String get productCode => product.code.toString();
  String get warehouseName => stockItem.warehouseName;
  ImageData? get productImage => product.defaultImage ?? (product.images.isNotEmpty ? product.images.first : null);
  double get pricePerUnit => (stockItem.availablePrice ?? 0) / 100.0;
  int get totalStock => stockItem.stock;
  int get multiplicity => stockItem.multiplicity ?? 1;
}