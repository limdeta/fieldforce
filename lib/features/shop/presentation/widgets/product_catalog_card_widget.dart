// lib/features/shop/presentation/widgets/product_catalog_card_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_cart_control_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_purchase_card_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_purchase_card_compact.dart';
import 'package:fieldforce/features/shop/presentation/helpers/price_color_helper.dart';

/// Виджет карточки товара для каталога
class ProductCatalogCardWidget extends StatelessWidget {
  final ProductWithStock productWithStock;
  final StockItem? selectedStockItem;
  final VoidCallback? onTap;
  final Function(StockItem stockItem)? onStockItemChanged;
  final bool compact; // Новый параметр для сплит-режима

  const ProductCatalogCardWidget({
    super.key,
    required this.productWithStock,
    this.selectedStockItem,
    this.onTap,
    this.onStockItemChanged,
    this.compact = false, // По умолчанию обычная карточка
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

    // В компактном режиме используем компактную карточку
    if (compact) {
      return ProductPurchaseCardCompact(
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
          : const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Выберите склад',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
        onAddToCart: null,
        product: product, // Передаём product для карусели
      );
    }

    // Обычная карточка для полноэкранного режима
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