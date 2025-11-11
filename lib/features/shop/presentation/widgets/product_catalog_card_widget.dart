// lib/features/shop/presentation/widgets/product_catalog_card_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_cart_control_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_purchase_card_widget.dart';
import 'package:fieldforce/features/shop/presentation/helpers/price_color_helper.dart';
// image cache and selector are not used here; the ProductPurchaseCard handles image and selector

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
    final product = productWithStock.product;
    final defaultImage = product.defaultImage;
    final imageUrl = defaultImage == null
        ? null
        : (defaultImage.uri.isNotEmpty ? defaultImage.uri : defaultImage.getOptimalUrl());
    final price = selectedStockItem != null
      ? (selectedStockItem!.offerPrice ?? selectedStockItem!.defaultPrice)
      : productWithStock.displayPrice;

    return ProductPurchaseCard(
      imageUrl: imageUrl,
      webpUrl: defaultImage?.webp,
      title: product.title,
      productCode: product.code.toString(),
      priceInKopecks: price,
      priceColor: selectedStockItem != null 
        ? PriceColorHelper.getPriceColor(selectedStockItem!)
        : null,
      priceBackgroundColor: selectedStockItem != null
        ? PriceColorHelper.getPriceBackgroundColor(selectedStockItem!)
        : null,
      onTap: onTap,
      selectedStockItem: selectedStockItem,
      onStockItemSelected: (stockItem) {
        if (onStockItemChanged != null) onStockItemChanged!(stockItem);
      },
      trailingControl: selectedStockItem != null
        ? StockItemCartControlWidget(stockItem: selectedStockItem!, isInCart: false)
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text('Выберите склад', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
      onAddToCart: null,
    );
  }


}