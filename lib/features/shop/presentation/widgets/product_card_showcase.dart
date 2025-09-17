// lib/features/shop/presentation/widgets/product_card_showcase.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_card_widget.dart';

/// Демонстрация различных вариантов отображения ProductCardWidget
/// Показывает как выглядят card, row и cart варианты
class ProductCardShowcase extends StatelessWidget {
  const ProductCardShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем тестовый продукт для демонстрации
    final testProduct = _createTestProduct();
    final testProductWithStock = _createTestProductWithStock(testProduct);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Варианты карточек продуктов'),

        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card variant
            const Text(
              '📱 Card Variant (дефолтный)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Компактные карточки для сеток товаров',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ProductCardWidget(
              productWithStock: testProductWithStock,
              variant: ProductCardVariant.card,
              showNavigation: true,
              showCharacteristics: true,
              onTap: () => _showMessage(context, 'Переход к деталям товара'),
              onAddToCart: () => _showMessage(context, 'Товар добавлен в корзину'),
              onQuantityChanged: (qty) => _showMessage(context, 'Количество изменено: $qty'),
            ),
            
            const SizedBox(height: 24),
            
            // Row variant
            const Text(
              '📋 Row Variant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Компактные строки для списков товаров',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ProductCardWidget(
              productWithStock: testProductWithStock,
              variant: ProductCardVariant.row,
              showNavigation: true,
              compactView: true,
              onTap: () => _showMessage(context, 'Переход к деталям товара'),
              onAddToCart: () => _showMessage(context, 'Товар добавлен в корзину'),
              onQuantityChanged: (qty) => _showMessage(context, 'Количество изменено: $qty'),
            ),
            
            const SizedBox(height: 8),
            
            // Еще один row для демонстрации
            ProductCardWidget(
              productWithStock: _createTestProductWithStock(_createTestProduct2()),
              variant: ProductCardVariant.row,
              showNavigation: true,
              compactView: true,
              onTap: () => _showMessage(context, 'Переход к деталям товара 2'),
              onAddToCart: () => _showMessage(context, 'Товар 2 добавлен в корзину'),
              onQuantityChanged: (qty) => _showMessage(context, 'Количество товара 2: $qty'),
            ),
            
            const SizedBox(height: 24),
            
            // Cart variant (показать как выглядит в корзине)
            const Text(
              '🛒 Cart Variant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Специальный режим для отображения в корзине (требует OrderLine)',
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              '(Будет показан после добавления товаров в корзину)',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
            
            const SizedBox(height: 24),
            
            // Сравнение размеров
            const Text(
              '📐 Сравнение размеров',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                // Card в узкой колонке
                Expanded(
                  child: Column(
                    children: [
                      const Text('Card', style: TextStyle(fontWeight: FontWeight.w600)),
                      ProductCardWidget(
                        productWithStock: testProductWithStock,
                        variant: ProductCardVariant.card,
                        compactView: true,
                        showNavigation: false,
                        onAddToCart: () => _showMessage(context, 'Добавлено'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Row в широкой колонке
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text('Row', style: TextStyle(fontWeight: FontWeight.w600)),
                      ProductCardWidget(
                        productWithStock: testProductWithStock,
                        variant: ProductCardVariant.row,
                        compactView: true,
                        showNavigation: false,
                        onAddToCart: () => _showMessage(context, 'Добавлено'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Product _createTestProduct() {
    return Product(
      title: 'Нитроэмаль Расцвет НЦ-132КП С золотисто-желтая 0.7 кг',
      barcodes: ['4605365042182'],
      code: 102969,
      bcode: 44759,
      catalogId: 44759,
      novelty: false,
      popular: true,
      isMarked: false,
      brand: Brand(
        searchPriority: 0,
        id: 328,
        name: 'Расцвет',
        adaptedName: null,
      ),
      images: [],
      amountInPackage: 14,
      vendorCode: '4605365042182',
      categoriesInstock: [],
      numericCharacteristics: [],
      stringCharacteristics: [],
      boolCharacteristics: [],
      canBuy: true,
    );
  }

  Product _createTestProduct2() {
    return Product(
      title: 'Краска акриловая белая 1.5 кг',
      barcodes: ['1234567890123'],
      code: 123456,
      bcode: 12345,
      catalogId: 12345,
      novelty: true,
      popular: false,
      isMarked: false,
      brand: Brand(
        searchPriority: 0,
        id: 123,
        name: 'ProPaint',
        adaptedName: null,
      ),
      images: [],
      amountInPackage: 6,
      vendorCode: '1234567890123',
      categoriesInstock: [],
      numericCharacteristics: [],
      stringCharacteristics: [],
      boolCharacteristics: [],
      canBuy: true,
    );
  }

  ProductWithStock _createTestProductWithStock(Product product) {
    return ProductWithStock(
      product: product,
      totalStock: 42,
      maxPrice: 55408,
      minPrice: 22163,
      hasDiscounts: true,
    );
  }
}