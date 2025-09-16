// test/unit/product_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';

void main() {
  group('Product Entity Tests', () {
    test('should create Product with required fields', () {
      // Arrange & Act
      final product = Product(
        title: 'Test Product',
        barcodes: ['123456789'],
        code: 1001,
        bcode: 1001,
        catalogId: 100,
        novelty: false,
        popular: true,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      // Assert
      expect(product.title, 'Test Product');
      expect(product.code, 1001);
      expect(product.canBuy, true);
      expect(product.popular, true);
      expect(product.novelty, false);
      expect(product.barcodes, ['123456789']);
    });

    test('should serialize and deserialize to JSON correctly', () {
      // Arrange
      final originalProduct = Product(
        title: 'Краска акриловая белая',
        barcodes: ['4607001234567', '4607001234568'],
        code: 2001,
        bcode: 2001,
        catalogId: 200,
        novelty: true,
        popular: false,
        isMarked: true,
        description: 'Высококачественная краска',
        howToUse: 'Наносить кистью',
        ingredients: 'Акрил, пигмент',
        vendorCode: 'TB-001',
        amountInPackage: 12,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      // Act
      final json = originalProduct.toJson();
      final deserializedProduct = Product.fromJson(json);

      // Assert
      expect(deserializedProduct.title, originalProduct.title);
      expect(deserializedProduct.code, originalProduct.code);
      expect(deserializedProduct.bcode, originalProduct.bcode);
      expect(deserializedProduct.catalogId, originalProduct.catalogId);
      expect(deserializedProduct.novelty, originalProduct.novelty);
      expect(deserializedProduct.popular, originalProduct.popular);
      expect(deserializedProduct.isMarked, originalProduct.isMarked);
      expect(deserializedProduct.canBuy, originalProduct.canBuy);
      expect(deserializedProduct.description, originalProduct.description);
      expect(deserializedProduct.vendorCode, originalProduct.vendorCode);
    });

    test('should handle empty arrays correctly', () {
      // Arrange
      final product = Product(
        title: 'Simple Product',
        barcodes: [],
        code: 3001,
        bcode: 3001,
        catalogId: 300,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      // Act
      final json = product.toJson();
      final deserializedProduct = Product.fromJson(json);

      // Assert
      expect(deserializedProduct.barcodes, isEmpty);
      expect(deserializedProduct.images, isEmpty);
      expect(deserializedProduct.categoriesInstock, isEmpty);
      expect(deserializedProduct.numericCharacteristics, isEmpty);
      expect(deserializedProduct.stringCharacteristics, isEmpty);
      expect(deserializedProduct.boolCharacteristics, isEmpty);
    });

    test('should handle null optional fields correctly', () {
      // Arrange
      final product = Product(
        title: 'Product with nulls',
        barcodes: ['1234567890123'],
        code: 4001,
        bcode: 4001,
        catalogId: 400,
        novelty: false,
        popular: false,
        isMarked: false,
        brand: null,
        manufacturer: null,
        colorImage: null,
        defaultImage: null,
        description: null,
        howToUse: null,
        ingredients: null,
        series: null,
        category: null,
        priceListCategoryId: null,
        amountInPackage: null,
        vendorCode: null,
        type: null,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      // Act
      final json = product.toJson();
      final deserializedProduct = Product.fromJson(json);

      // Assert
      expect(deserializedProduct.brand, isNull);
      expect(deserializedProduct.manufacturer, isNull);
      expect(deserializedProduct.description, isNull);
      expect(deserializedProduct.howToUse, isNull);
      expect(deserializedProduct.ingredients, isNull);
      expect(deserializedProduct.series, isNull);
      expect(deserializedProduct.vendorCode, isNull);
      expect(deserializedProduct.amountInPackage, isNull);
    });

    test('should handle basic product properties', () {
      // Arrange
      final product = Product(
        title: 'Basic Product',
        barcodes: ['1111', '2222'],
        code: 5001,
        bcode: 5001,
        catalogId: 500,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      // Assert
      expect(product.title, 'Basic Product');
      expect(product.barcodes.length, 2);
      expect(product.barcodes, contains('1111'));
      expect(product.barcodes, contains('2222'));
      expect(product.code, 5001);
      expect(product.catalogId, 500);
      expect(product.canBuy, true);
    });

    test('should provide correct string representation', () {
      // Arrange
      final product = Product(
        title: 'String Test Product',
        barcodes: ['999'],
        code: 6001,
        bcode: 6001,
        catalogId: 600,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      // Act & Assert
      final stringRepr = product.toString();
      expect(stringRepr, contains('Product'));
      expect(stringRepr, contains('6001')); // code
      expect(stringRepr, contains('String Test Product')); // title
    });
  });
}