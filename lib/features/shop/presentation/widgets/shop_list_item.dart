// lib/features/shop/presentation/widgets/shop_list_item.dart

import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';

/// Унифицированный интерфейс для отображения продуктов в различных списках
/// Позволяет использовать один виджет для каталога (ProductWithStock) и корзины (OrderLine)
abstract class ShopListItem {
  // Основная информация о продукте
  Product get product;
  StockItem? get stockItem;
  
  // Количество в корзине (0 если не в корзине)
  int get cartQuantity;
  
  // Основные поля для отображения
  String get title => product.title;
  String get vendorCode => product.vendorCode ?? '';
  String get displayCode => '[${product.code}]';
  
  // Изображения  
  ImageData? get primaryImage => product.defaultImage ?? (product.images.isNotEmpty ? product.images.first : null);
  
  // Цена (в копейках)
  int get displayPrice;
  int? get maxPrice => null; // Только для каталога с диапазоном цен
  bool get hasPriceRange => false;
  
  // Остатки и доступность
  int get totalStock;
  bool get isAvailable => totalStock > 0;
  bool get isLowStock => totalStock > 0 && totalStock <= 5;
  bool get isInStock => totalStock > 5;
  bool get isOutOfStock => totalStock == 0;
  
  // UI helpers
  String get stockStatusText {
    if (isOutOfStock) return 'Нет на складе';
    if (isLowStock) return 'Малый остаток: $totalStock шт';
    return 'В наличии: $totalStock шт';
  }
  
  String get formattedPrice => '${(displayPrice / 100).toStringAsFixed(2)} ₽';
  
  // Multiplicity для упаковок
  int get multiplicity => stockItem?.multiplicity ?? (product.amountInPackage ?? 1);
  
  // Цена за единицу (для корзины)
  int? get pricePerUnit => null;
  
  // Общая стоимость (для корзины)
  int? get totalCost => null;
  
  // Название склада (для корзины)
  String? get warehouseName => null;
  
  // Бренд
  String? get brandName => product.brand?.name;
  
  // Скидки (для каталога)
  bool get hasDiscounts => false;
}