// lib/features/shop/presentation/widgets/product_catalog_card_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_selector_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_cart_control_widget.dart';
import 'package:fieldforce/shared/services/image_cache_service.dart';

/// Виджет карточки товара для каталога
class ProductCatalogCardWidget extends StatelessWidget {
  final ProductWithStock productWithStock;
  final StockItem? selectedStockItem;
  final VoidCallback? onTap;
  final Function(StockItem stockItem)? onStockItemChanged;

  const ProductCatalogCardWidget({
    super.key,
    required this.productWithStock,
    this.selectedStockItem,
    this.onTap,
    this.onStockItemChanged,
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
                child: productWithStock.product.defaultImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ImageCacheService.getCachedThumbnail(
                          imageUrl: productWithStock.product.defaultImage!.getOptimalUrl(),
                          width: 80,
                          height: 80,
                          placeholder: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.image,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                          ),
                          errorWidget: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 32,
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
                      productWithStock.product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Артикул
                    if (productWithStock.product.vendorCode?.isNotEmpty == true)
                      Text(
                        'Артикул: ${productWithStock.product.vendorCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Селектор склада
                    StockItemSelectorWidget(
                      productCode: productWithStock.product.code,
                      selectedStockItem: selectedStockItem,
                      onStockItemSelected: (stockItem) {
                        if (onStockItemChanged != null) {
                          onStockItemChanged!(stockItem);
                        }
                      },
                      showFullInfo: true,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (selectedStockItem?.offerPrice != null)
                        Text(
                          '${(selectedStockItem!.defaultPrice / 100).toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        selectedStockItem != null
                          ? '${((selectedStockItem!.offerPrice ?? selectedStockItem!.defaultPrice) / 100).toStringAsFixed(0)} ₽'
                          : '${(productWithStock.displayPrice / 100).toStringAsFixed(0)} ₽',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selectedStockItem?.offerPrice != null 
                            ? Colors.red 
                            : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Контрол корзины для конкретного StockItem
                  selectedStockItem != null
                    ? StockItemCartControlWidget(
                        stockItem: selectedStockItem!,
                        isInCart: false,
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          'Выберите склад',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
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