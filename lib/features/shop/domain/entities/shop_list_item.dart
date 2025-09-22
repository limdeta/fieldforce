// lib/features/shop/domain/entities/shop_list_item.dart

import 'product.dart';
import 'stock_item.dart';

/// Единый интерфейс для отображения товаров в списках
/// Используется как для каталога (ProductWithStock), так и для корзины (OrderLine)
abstract class ShopListItem {
  Product get product;
  StockItem get stockItem;
  
  int get cartQuantity;
  
  String get updateKey;
  
  String get productTitle => product.title;
  String get productCode => product.code.toString();
  String get warehouseName => stockItem.warehouseName;
  ImageData? get productImage => product.defaultImage ?? (product.images.isNotEmpty ? product.images.first : null);
  
  String? get productImageUrl => productImage?.getOptimalUrl();
  double get pricePerUnit => (stockItem.availablePrice ?? 0) / 100.0;
  int get totalStock => stockItem.stock;
  int get multiplicity => stockItem.multiplicity ?? 1;
}