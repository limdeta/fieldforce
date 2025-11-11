import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_selector_widget.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/shared/widgets/cached_network_image_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_images_carousel_dialog.dart';

/// Компактная карточка товара для сплит-режима каталога.
/// Минимальная высота, без скруглений, теней и избыточных отступов.
/// Использует Divider вместо Card для визуального разделения.
class ProductPurchaseCardCompact extends StatelessWidget {
  final String? imageUrl;
  final String? webpUrl;
  final String title;
  final String productCode;
  final int priceInKopecks;
  final StockItem? selectedStockItem;
  final void Function(StockItem) onStockItemSelected;
  final void Function()? onAddToCart;
  final Widget? trailingControl;
  final VoidCallback? onTap;
  final Color? priceColor;
  final Color? priceBackgroundColor;
  final Product? product; // Для карусели изображений

  const ProductPurchaseCardCompact({
    super.key,
    this.imageUrl,
    this.webpUrl,
    required this.title,
    required this.productCode,
    required this.priceInKopecks,
    required this.onStockItemSelected,
    this.selectedStockItem,
    this.onAddToCart,
    this.trailingControl,
    this.onTap,
    this.priceColor,
    this.priceBackgroundColor,
    this.product,
  });

  String _formatPrice(int priceInKopecks) {
    return (priceInKopecks / 100).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final displayImageUrl = imageUrl ?? webpUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Картинка - занимает полную высоту карточки (2 строки)
              if (displayImageUrl != null && displayImageUrl.isNotEmpty)
                InkWell(
                  onTap: () {
                    // Приоритет: карусель изображений, если есть product
                    if (product != null && product!.images.isNotEmpty) {
                      ProductImagesCarouselDialog.show(
                        context,
                        images: product!.images,
                        productTitle: title,
                      );
                    } else if (onTap != null) {
                      // Иначе переход в детали товара
                      onTap!();
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CachedNetworkImageWidget.lazyProduct(
                      imageUrl: displayImageUrl,
                      webpUrl: webpUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                // Placeholder если нет картинки
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 24,
                    color: Colors.grey.shade400,
                  ),
                ),
              
              const SizedBox(width: 6),
              
              // Правая часть - 2 строки
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Строка 1: Название + Цена
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: onTap,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Цена
                        Container(
                          padding: priceBackgroundColor != null 
                              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                              : EdgeInsets.zero,
                          decoration: priceBackgroundColor != null
                              ? BoxDecoration(
                                  color: priceBackgroundColor,
                                  borderRadius: BorderRadius.circular(3),
                                )
                              : null,
                          child: Text(
                            '${_formatPrice(priceInKopecks)} ₽',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: priceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Строка 2: Склад + Количество + Кнопка
                    Row(
                      children: [
                        Expanded(
                          child: StockItemSelectorWidget(
                            productCode: int.tryParse(productCode) ?? 0,
                            onStockItemSelected: onStockItemSelected,
                            selectedStockItem: selectedStockItem,
                            showFullInfo: false,
                            outerMargin: EdgeInsets.zero,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (trailingControl != null)
                          trailingControl!
                        else
                          SizedBox(
                            height: 24,
                            child: ElevatedButton(
                              onPressed: onAddToCart,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                visualDensity: VisualDensity.compact,
                                minimumSize: const Size(0, 24),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Разделитель вместо Card margin
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
