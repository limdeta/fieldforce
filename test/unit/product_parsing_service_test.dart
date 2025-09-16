// test/unit/product_parsing_service_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';

void main() {
  late ProductParsingService service;

  setUp(() {
    service = ProductParsingService();
  });

  group('ProductParsingService Tests', () {
    test('parseProduct should parse real JSON from fixture correctly', () async {
      // Arrange - загружаем реальный JSON из fixture
      final jsonString = await rootBundle.loadString('assets/fixtures/product_example.json');

      // Act
      final product = service.parseProduct(jsonString);

      // Assert
      expect(product.title, 'Туалетная бумага YOKO Takeshi Бамбук 3-х слойная 10 рулонов');
      expect(product.code, 170094);
      expect(product.catalogId, 110142);
      expect(product.canBuy, true);
      expect(product.stockItems.length, 1);
      expect(product.stockItems[0].defaultPrice, 66847);
      expect(product.category?.id, 99);
      expect(product.category?.name, 'Туалетная бумага');
      expect(product.brand?.name, 'YOKO');
      expect(product.numericCharacteristics.length, 1);
      expect(product.stringCharacteristics.length, 2);
      expect(product.images.length, 3);
    });

    test('parseProductsFromJsonArray should parse array with real products', () async {
      // Arrange - создаем массив из реальных JSON
      final product1Json = await rootBundle.loadString('assets/fixtures/product_example.json');
      final product2Json = await rootBundle.loadString('assets/fixtures/product_example1.json');

      final jsonArray = [
        jsonDecode(product1Json),
        jsonDecode(product2Json)
      ];
      final jsonArrayString = jsonEncode(jsonArray);

      // Act
      final products = service.parseProductsFromJsonArray(jsonArrayString);

      // Assert
      expect(products.length, 2);
      expect(products[0].title, 'Туалетная бумага YOKO Takeshi Бамбук 3-х слойная 10 рулонов');
      expect(products[1].title, isNotEmpty); // Второй продукт тоже должен быть валидным
    });

    test('createCompactView should work with real product data', () async {
      // Arrange
      final jsonString = await rootBundle.loadString('assets/fixtures/product_example.json');
      final product = service.parseProduct(jsonString);

      // Act
      final compactView = service.createCompactView(product);

      // Assert
      expect(compactView.id, 110142);
      expect(compactView.title, 'Туалетная бумага YOKO Takeshi Бамбук 3-х слойная 10 рулонов');
      expect(compactView.code, 170094);
      expect(compactView.price, 66847);
      expect(compactView.discountPrice, 45456); // availablePrice из JSON
      expect(compactView.hasPromotion, true); // У продукта есть promotion
      expect(compactView.canBuy, true);
      expect(compactView.amountInPackage, 5);
      expect(compactView.formattedPrice, '668.47 ₽');
      expect(compactView.formattedDiscountPrice, '454.56 ₽');
      expect(compactView.hasDiscount, true);
    });

    test('createCompactViews should handle multiple real products', () async {
      // Arrange
      final product1Json = await rootBundle.loadString('assets/fixtures/product_example.json');
      final product2Json = await rootBundle.loadString('assets/fixtures/product_example1.json');

      final products = [
        service.parseProduct(product1Json),
        service.parseProduct(product2Json)
      ];

      // Act
      final compactViews = service.createCompactViews(products);

      // Assert
      expect(compactViews.length, 2);
      expect(compactViews[0].hasPromotion, true);
      expect(compactViews[1].hasPromotion, isNotNull); // Может быть true или false
    });

    test('parseProduct should handle product_example2.json with null adaptValue', () async {
      // Arrange - тестируем product_example2.json который содержит null в adaptValue
      final jsonString = await rootBundle.loadString('assets/fixtures/product_example2.json');

      // Act
      final product = service.parseProduct(jsonString);

      // Assert
      expect(product.title, 'Нитроэмаль Расцвет НЦ-132КП С золотисто-желтая 0.7 кг');
      expect(product.code, 102969);
      expect(product.catalogId, 44759);
      expect(product.category?.id, 221);
      expect(product.category?.name, 'Эмали НЦ');
      expect(product.boolCharacteristics.length, 1);
      // Проверяем, что adaptValue может быть null
      expect(product.boolCharacteristics[0].adaptValue, null);
      expect(product.boolCharacteristics[0].value, true);
    });

    test('parseProduct should handle product_example3.json with null adaptValue', () async {
      // Arrange - тестируем product_example3.json который тоже содержит null в adaptValue
      final jsonString = await rootBundle.loadString('assets/fixtures/product_example3.json');

      // Act
      final product = service.parseProduct(jsonString);

      // Assert
      expect(product.title, 'Нитроэмаль Расцвет НЦ-132КП С синяя 0.7 кг');
      expect(product.code, 102970);
      expect(product.catalogId, 44760);
      expect(product.category?.id, 221);
      expect(product.category?.name, 'Эмали НЦ');
      expect(product.boolCharacteristics.length, 1);
      // Проверяем, что adaptValue может быть null
      expect(product.boolCharacteristics[0].adaptValue, null);
      expect(product.boolCharacteristics[0].value, true);
    });

    test('parseProduct should handle invalid JSON gracefully', () {
      // Arrange
      const invalidJsonString = '{ invalid json }';

      // Act & Assert
      expect(
        () => service.parseProduct(invalidJsonString),
        throwsA(isA<Exception>()),
      );
    });

    test('parseProductsFromJsonArray should handle empty array', () {
      // Arrange
      const jsonArrayString = '[]';

      // Act
      final products = service.parseProductsFromJsonArray(jsonArrayString);

      // Assert
      expect(products, isEmpty);
    });

    test('createCompactView should handle product without stock items', () {
      // Arrange
      final product = Product(
        title: 'Продукт без цены',
        barcodes: [],
        code: 1003,
        bcode: 1003,
        catalogId: 1003,
        novelty: false,
        popular: false,
        isMarked: false,
        brand: null,
        manufacturer: null,
        colorImage: null,
        defaultImage: null,
        images: [],
        description: '',
        howToUse: null,
        ingredients: null,
        series: null,
        category: null,
        priceListCategoryId: null,
        amountInPackage: 1,
        vendorCode: 'TEST003',
        type: null,
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        stockItems: [], // Пустой список
        canBuy: true,
      );

      // Act
      final compactView = service.createCompactView(product);

      // Assert
      expect(compactView.price, null);
      expect(compactView.discountPrice, null);
      expect(compactView.formattedPrice, 'Цена не указана');
      expect(compactView.formattedDiscountPrice, '');
      expect(compactView.hasDiscount, false);
    });
  });
}