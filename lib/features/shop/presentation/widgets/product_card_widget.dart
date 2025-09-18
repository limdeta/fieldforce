// lib/features/shop/presentation/widgets/product_card_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/presentation/widgets/cart_control_widget.dart';
import 'package:fieldforce/shared/services/image_cache_service.dart';

/// Варианты отображения карточки продукта
enum ProductCardVariant {
  card,
  row,
  cart,
}

/// Единый переиспользуемый виджет для отображения карточки продукта
/// Работает как с ProductWithStock (каталог), так и с OrderLine (корзина)
/// Следует формату compact_view для унификации отображения
/// 
/// Поддерживает различные варианты отображения:
/// - card: компактная карточка для сеток
/// - row: строка для списков
/// - cart: специальный режим для корзины
class ProductCardWidget extends StatelessWidget {
  // Данные продукта (один из вариантов должен быть передан)
  final ProductWithStock? productWithStock;
  final OrderLine? orderLine;
  
  final ProductCardVariant variant;
  
  // Режимы отображения
  final bool showNavigation;
  final bool showCharacteristics;
  final bool showLabels;
  final bool compactView;
  
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  
  // Количество в корзине (для каталога)
  final int currentCartQuantity;

  const ProductCardWidget({
    super.key,
    this.productWithStock,
    this.orderLine,
    this.variant = ProductCardVariant.card,
    this.showNavigation = true,
    this.showCharacteristics = false,
    this.showLabels = true,
    this.compactView = false,
    this.onTap,
    this.onAddToCart,
    this.onQuantityChanged,
    this.onRemove,
    this.currentCartQuantity = 0,
  }) : assert(
          (productWithStock != null && orderLine == null) ||
          (productWithStock == null && orderLine != null),
          'Должен быть передан либо productWithStock, либо orderLine'
        );

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ProductCardVariant.cart:
        return _buildCartCard(context);
      case ProductCardVariant.row:
        return _buildRowCard(context);
      case ProductCardVariant.card:
        return _buildCatalogCard(context);
    }
  }

  /// Карточка для режима каталога (ProductWithStock)
  Widget _buildCatalogCard(BuildContext context) {
    final product = productWithStock!.product;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Изображение продукта (заглушка)
              _buildProductImage(),
              const SizedBox(width: 12),
              
              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название продукта
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Артикул и бренд
                    _buildProductMeta(),
                    const SizedBox(height: 4),
                    
                    // Статус остатков
                    _buildStockStatus(),
                    const SizedBox(height: 8),
                    
                    // Цена с возможной скидкой
                    _buildPriceInfo(),
                  ],
                ),
              ),
              
              // Управление корзиной + навигация
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Контрол корзины
                  if (productWithStock!.isAvailable)
                    CartControlWidget(
                      initialQuantity: currentCartQuantity,
                      amountInPackage: product.amountInPackage,
                      onAddToCart: onAddToCart,
                      onQuantityChanged: onQuantityChanged,
                      showCartIcon: true,
                      isInCart: false,
                    )
                  else
                    _buildUnavailableWidget(),
                    
                  // Стрелка навигации
                  // if (showNavigation && onTap != null) ...[
                  //   const SizedBox(height: 8),
                  //   Icon(
                  //     Icons.chevron_right,
                  //     color: Colors.grey.shade600,
                  //     size: 20,
                  //   ),
                  // ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Карточка для режима корзины (OrderLine)
  Widget _buildCartCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
        children: [
            // Изображение продукта
            _buildProductImage(),
            const SizedBox(width: 12),
            
            // Основная информация (кликабельная для навигации)
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название продукта
                  Text(
                    orderLine!.productTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Артикул
                  if (orderLine!.productVendorCode.isNotEmpty)
                    Text(
                      'Артикул: ${orderLine!.productVendorCode}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  
                  // Склад
                  Text(
                    'Склад: ${orderLine!.warehouseName}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  
                  // Цена за единицу и общая сумма
                  Row(
                    children: [
                      Text(
                        '${(orderLine!.pricePerUnit / 100).toStringAsFixed(2)} ₽',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Сумма: ${(orderLine!.totalCost / 100).toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                ),
              ),
            ),
            
            // Управление в корзине
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Стрелка навигации к деталям
                if (showNavigation && onTap != null) ...[
                  IconButton(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 16,
                    color: Colors.grey.shade600,
                    tooltip: 'Посмотреть детали',
                  ),
                  const SizedBox(height: 4),
                ],
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Контрол количества
                    CartControlWidget(
                      initialQuantity: orderLine!.quantity,
                      amountInPackage: orderLine!.stockItem.multiplicity,
                      isInCart: true,
                      onQuantityChanged: onQuantityChanged,
                    ),
                    const SizedBox(width: 8),
                    
                    // Кнопка удаления
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade600,
                      iconSize: 20,
                      tooltip: 'Удалить из корзины',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка для режима строки (копирует дизайн ProductCard из ProductListPage)
  Widget _buildRowCard(BuildContext context) {
    // Определяем продукт в зависимости от того, что передано
    final product = productWithStock?.product ?? orderLine?.product;
    if (product == null) {
      return const Card(child: Text('Ошибка: нет данных о продукте'));
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Изображение продукта 80x80
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: product.defaultImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            product.defaultImage!.uri,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.grey,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 12),
                
                // Основная информация о продукте
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Название товара
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Артикул
                      if (product.vendorCode?.isNotEmpty == true)
                        Text(
                          'Артикул: ${product.vendorCode!}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      
                      // Остатки на складе
                      Row(
                        children: [
                          Icon(
                            productWithStock!.totalStock > 0 
                                ? Icons.check_circle 
                                : Icons.cancel,
                            color: productWithStock!.totalStock > 0 
                                ? Colors.green 
                                : Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            productWithStock!.totalStock > 0 
                                ? 'В наличии: ${productWithStock!.totalStock} шт'
                                : 'Нет в наличии',
                            style: TextStyle(
                              fontSize: 12,
                              color: productWithStock!.totalStock > 0 
                                  ? Colors.green.shade700 
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Цена и управление корзиной
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Цена
                    Text(
                      '${(productWithStock!.minPrice / 100).toStringAsFixed(2)} ₽',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // Контрол корзины
                    // Определяем количество в зависимости от источника данных
                    Builder(builder: (context) {
                      final quantity = orderLine?.quantity ?? currentCartQuantity;
                      final hasStock = productWithStock?.totalStock ?? orderLine?.stockItem.stock ?? 0;
                      final multiplicity = orderLine?.stockItem.multiplicity ?? 1;
                      
                      if (hasStock > 0) {
                        return CartControlWidget(
                          initialQuantity: quantity,
                          amountInPackage: multiplicity,
                          onAddToCart: onAddToCart,
                          onQuantityChanged: onQuantityChanged,
                          showCartIcon: true,
                          isInCart: quantity > 0,
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Недоступно',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                    }),
                  ],
                ),
                
                // Стрелка навигации к деталям товара
                if (showNavigation)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Виджет изображения продукта
  Widget _buildProductImage() {
    ImageData? imageData;
    
    if (productWithStock != null) {
      // Для каталога берем изображение из productWithStock
      final product = productWithStock!.product;
      imageData = product.defaultImage ?? (product.images.isNotEmpty ? product.images.first : null);
    } else if (orderLine != null && orderLine!.product != null) {
      // Для корзины берем изображение из orderLine.product
      final product = orderLine!.product!;
      imageData = product.defaultImage ?? (product.images.isNotEmpty ? product.images.first : null);
    }
    // Если нет изображения, показываем заглушку
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7), // Немного меньше чем у контейнера для отступа
        child: imageData != null 
          ? ImageCacheService.getCachedThumbnail(
              imageUrl: imageData.uri,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: Container(
                width: 56,
                height: 56,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              errorWidget: Container(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
              ),
            )
          : Icon(
              Icons.inventory_2,
              color: Colors.grey.shade600,
              size: 24,
            ),
      ),
    );
  }
  
  // Убрали _getSizedImageUrl чтобы не спамить запросами к серверу изображений

  /// Мета-информация продукта (артикул, бренд)
  Widget _buildProductMeta() {
    if (productWithStock == null) return const SizedBox.shrink();
    
    final product = productWithStock!.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Артикул в скобках с отступом справа
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '[${product.code}]',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        // Бренд (если есть)
        if (product.brand?.name.isNotEmpty == true)
          Text(
            'Бренд: ${product.brand!.name}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  /// Статус остатков для каталога
  Widget _buildStockStatus() {
    if (productWithStock == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        Icon(
          _getStockIcon(),
          color: _getStockColor(),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          productWithStock!.stockStatusText,
          style: TextStyle(
            fontSize: 12,
            color: _getStockColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Информация о цене (с возможными скидками)
  Widget _buildPriceInfo() {
    if (productWithStock == null) return const SizedBox.shrink();
    
    // Базовая цена
    final displayPrice = productWithStock!.displayPrice;
    final maxPrice = productWithStock!.maxPrice;
    
    // Если есть диапазон цен - показываем обе цены
    if (productWithStock!.hasPriceRange) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Диапазон цен
          Text(
            'от ${(displayPrice / 100).toStringAsFixed(2)} до ${(maxPrice / 100).toStringAsFixed(2)} ₽',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          // Показатель скидки если есть
          if (productWithStock!.hasDiscounts)
            Text(
              'Скидки доступны',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      );
    }
    
    // Обычная цена без скидки
    return Text(
      '${(displayPrice / 100).toStringAsFixed(2)} ₽',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  /// Виджет для недоступного товара
  Widget _buildUnavailableWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Недоступно',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Возвращает иконку для статуса остатков
  IconData _getStockIcon() {
    if (productWithStock == null) return Icons.help_outline;
    
    switch (productWithStock!.stockStatusColor) {
      case StockStatusColor.green:
        return Icons.check_circle;
      case StockStatusColor.yellow:
        return Icons.warning;
      case StockStatusColor.red:
        return Icons.cancel;
    }
  }

  /// Возвращает цвет для статуса остатков
  Color _getStockColor() {
    if (productWithStock == null) return Colors.grey;
    
    switch (productWithStock!.stockStatusColor) {
      case StockStatusColor.green:
        return Colors.green;
      case StockStatusColor.yellow:
        return Colors.orange;
      case StockStatusColor.red:
        return Colors.red;
    }
  }
}