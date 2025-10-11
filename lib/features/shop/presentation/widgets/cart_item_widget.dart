// lib/features/shop/presentation/widgets/cart_item_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_cart_control_widget.dart';
import 'package:fieldforce/shared/widgets/cached_network_image_widget.dart';

/// Виджет элемента корзины
class CartItemWidget extends StatelessWidget {
  final OrderLine orderLine;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showNavigation;

  const CartItemWidget({
    super.key,
    required this.orderLine,
    this.onTap,
    this.onRemove,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение товара
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
                child: orderLine.product?.defaultImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImageWidget.product(
                          imageUrl: orderLine.product!.defaultImage!.getOptimalUrl(),
                          webpUrl: null, // WebP можно добавить в будущем
                          width: 60,
                          height: 60,
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 24,
                        color: Colors.grey.shade400,
                      ),
              ),
              const SizedBox(width: 12),
              
              // Информация о товаре
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название
                    Text(
                      orderLine.productTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    
                    // Артикул
                    Text(
                      'Артикул: ${orderLine.productVendorCode}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    
                    // Склад (только текст в корзине)
                    Text(
                      'Склад: ${orderLine.warehouseName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    
                    // Цена за единицу и общая сумма
                    Row(
                      children: [
                        Text(
                          '${(orderLine.pricePerUnit / 100).toStringAsFixed(2)} ₽',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Сумма: ${(orderLine.totalCost / 100).toStringAsFixed(2)} ₽',
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
                  
                  // Контрол количества с кнопкой удаления
                  StockItemCartControlWidget(
                    stockItem: orderLine.stockItem,
                    isInCart: true,
                    onRemove: onRemove,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}