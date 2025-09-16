// test/unit/stock_item_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';

void main() {
  group('StockItem Entity Tests', () {
    test('should create StockItem with all required fields', () {
      // Arrange & Act
      final stockItem = StockItem(
        id: 1,
        productCode: 1001,
        warehouseId: 1,
        warehouseName: 'Склад Москва',
        warehouseVendorId: 'vendor_moscow',
        isPickUpPoint: false,
        stock: 100,
        multiplicity: 1,
        publicStock: '100 шт.',
        defaultPrice: 15000, // 150 руб в копейках
        discountValue: 0,
        availablePrice: null,
        offerPrice: null,
        currency: 'RUB',
        promotionJson: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Assert
      expect(stockItem.id, 1);
      expect(stockItem.productCode, 1001);
      expect(stockItem.warehouseId, 1);
      expect(stockItem.warehouseName, 'Склад Москва');
      expect(stockItem.warehouseVendorId, 'vendor_moscow');
      expect(stockItem.isPickUpPoint, false);
      expect(stockItem.stock, 100);
      expect(stockItem.defaultPrice, 15000);
      expect(stockItem.offerPrice, null);
      expect(stockItem.currency, 'RUB');
      expect(stockItem.isAvailable, true);
      expect(stockItem.hasDiscount, false);
      expect(stockItem.effectivePrice, 15000);
    });

    test('should calculate effective price correctly with discount', () {
      // Arrange & Act
      final stockItemWithDiscount = StockItem(
        id: 2,
        productCode: 1002,
        warehouseId: 1,
        warehouseName: 'Склад СПб',
        warehouseVendorId: 'vendor_spb',
        isPickUpPoint: true,
        stock: 50,
        multiplicity: 1,
        publicStock: '50 шт.',
        defaultPrice: 20000, // 200 руб
        discountValue: 25,
        availablePrice: 15000,
        offerPrice: 15000,   // 150 руб (скидка 25%)
        currency: 'RUB',
        promotionJson: '{"type": "discount", "percent": 25}',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Assert
      expect(stockItemWithDiscount.effectivePrice, 15000);
      expect(stockItemWithDiscount.hasDiscount, true);
      expect(stockItemWithDiscount.discountPercent, 25.0);
    });

    test('should detect when product is not available', () {
      // Arrange & Act
      final outOfStockItem = StockItem(
        id: 3,
        productCode: 1003,
        warehouseId: 2,
        warehouseName: 'ПВЗ Новосибирск',
        warehouseVendorId: 'vendor_nsk',
        isPickUpPoint: true,
        stock: 0, // Нет в наличии
        multiplicity: 1,
        publicStock: 'Нет в наличии',
        defaultPrice: 10000,
        discountValue: 0,
        availablePrice: null,
        offerPrice: null,
        currency: 'RUB',
        promotionJson: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Assert
      expect(outOfStockItem.isAvailable, false);
      expect(outOfStockItem.stock, 0);
    });

    test('should create copy with modified fields', () {
      // Arrange
      final originalItem = StockItem(
        id: 4,
        productCode: 1004,
        warehouseId: 3,
        warehouseName: 'Склад Екатеринбург',
        warehouseVendorId: 'vendor_ekb',
        isPickUpPoint: false,
        stock: 200,
        multiplicity: 1,
        publicStock: '200 шт.',
        defaultPrice: 25000,
        discountValue: 0,
        availablePrice: null,
        offerPrice: null,
        currency: 'RUB',
        promotionJson: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Act
      final updatedItem = originalItem.copyWith(
        stock: 150,
        offerPrice: 20000,
        promotionJson: '{"type": "cashback", "percent": 10}',
      );

      // Assert
      expect(updatedItem.stock, 150);
      expect(updatedItem.offerPrice, 20000);
      expect(updatedItem.promotionJson, '{"type": "cashback", "percent": 10}');
      expect(updatedItem.hasDiscount, true);
      expect(updatedItem.effectivePrice, 20000);
      
      // Другие поля должны остаться неизменными
      expect(updatedItem.id, originalItem.id);
      expect(updatedItem.productCode, originalItem.productCode);
      expect(updatedItem.warehouseName, originalItem.warehouseName);
    });

    test('should create valid toString representation', () {
      // Arrange & Act
      final stockItem = StockItem(
        id: 5,
        productCode: 1005,
        warehouseId: 4,
        warehouseName: 'ПВЗ Краснодар',
        warehouseVendorId: 'vendor_krd',
        isPickUpPoint: true,
        stock: 75,
        multiplicity: 1,
        publicStock: '75 шт.',
        defaultPrice: 18000,
        discountValue: 20,
        availablePrice: 14400,
        offerPrice: 14400, // 20% скидка
        currency: 'RUB',
        promotionJson: '{"type": "discount", "percent": 20}',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      // Act & Assert
      final stringRepresentation = stockItem.toString();
      expect(stringRepresentation, contains('StockItem(id: 5'));
      expect(stringRepresentation, contains('productCode: 1005'));
      expect(stringRepresentation, contains('ПВЗ Краснодар(id: 4)'));
      expect(stringRepresentation, contains('stock: 75'));
      expect(stringRepresentation, contains('price: 14400 RUB'));
    });
  });

  group('StockUpdate DTO Tests', () {
    test('should create StockUpdate with correct fields', () {
      // Arrange & Act
      const stockUpdate = StockUpdate(
        productCode: 1001,
        warehouseId: 1,
        newStock: 250,
      );

      // Assert
      expect(stockUpdate.productCode, 1001);
      expect(stockUpdate.warehouseId, 1);
      expect(stockUpdate.newStock, 250);
    });

    test('should support equality comparison', () {
      // Arrange
      const update1 = StockUpdate(productCode: 1001, warehouseId: 1, newStock: 100);
      const update2 = StockUpdate(productCode: 1001, warehouseId: 1, newStock: 100);
      const update3 = StockUpdate(productCode: 1001, warehouseId: 1, newStock: 150);

      // Assert
      expect(update1, equals(update2));
      expect(update1, isNot(equals(update3)));
    });
  });

  group('PriceUpdate DTO Tests', () {
    test('should create PriceUpdate with optional prices', () {
      // Arrange & Act
      const priceUpdate = PriceUpdate(
        productCode: 1002,
        warehouseId: 2,
        defaultPrice: 20000,
        offerPrice: 15000,
      );

      // Assert
      expect(priceUpdate.productCode, 1002);
      expect(priceUpdate.warehouseId, 2);
      expect(priceUpdate.defaultPrice, 20000);
      expect(priceUpdate.offerPrice, 15000);
    });

    test('should handle null prices', () {
      // Arrange & Act
      const priceUpdatePartial = PriceUpdate(
        productCode: 1003,
        warehouseId: 3,
        defaultPrice: 25000,
        offerPrice: null, // Убираем акционную цену
      );

      // Assert
      expect(priceUpdatePartial.offerPrice, null);
      expect(priceUpdatePartial.defaultPrice, 25000);
    });
  });
}