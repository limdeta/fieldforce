import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_selector_widget.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/shared/widgets/cached_network_image_widget.dart';

/// Компонент карточки покупки товара для каталога / списка
/// Структура:
///  - слева: картинка (полная высота карточки)
///  - справа (вверху): название и код продукта (код под названием), в конце — цена
///  - справа (внизу): селектор склада слева, кнопка "В корзину" справа
class ProductPurchaseCard extends StatelessWidget {
  final String? imageUrl;
  final String? webpUrl;
  final String title;
  final String productCode; // показываем под названием
  final int priceInKopecks;
  final StockItem? selectedStockItem;
  final void Function(StockItem) onStockItemSelected;
  final void Function()? onAddToCart;
  final Widget? trailingControl;
  final VoidCallback? onTap;

  const ProductPurchaseCard({
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
  });

  String _formatPrice(int priceInKopecks) {
    return (priceInKopecks / 100).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final displayImageUrl = imageUrl ?? webpUrl;

    return Card(
      // Remove horizontal offset so card stretches to list padding edges
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        // Reduced padding for a more compact card
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main info column (image moved inline into the top row)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + code and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Inline tappable area: image + title block
                      if (displayImageUrl != null && displayImageUrl.isNotEmpty) ...[
                        InkWell(
                          onTap: onTap,
                          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImageWidget.lazyProduct(
                              imageUrl: displayImageUrl,
                              webpUrl: webpUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: onTap,
                              child: Text(
                                title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Show product article/code under the title (stock shown in selector)
                            Text(
                              productCode,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Price
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 60, maxWidth: 110),
                        child: Text(
                          '${_formatPrice(priceInKopecks)} ₽',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Bottom row: stock selector (left expands) and add-to-cart button (fixed right)
                  Container(
                    width: double.infinity,
                    child: Row(
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

                        // Trailing control allows embedding a richer widget (e.g. StockItemCartControlWidget)
                        if (trailingControl != null)
                          trailingControl!
                        else
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: onAddToCart,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  visualDensity: VisualDensity.compact,
                                  minimumSize: const Size(0, 32), // ensure button respects smaller height
                                ),
                                child: const Text('В корзину'),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
