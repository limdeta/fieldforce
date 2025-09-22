// test/unit/product_parsing_service_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/data/mappers/product_api_models.dart';

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
      expect(compactView.price, null); // Пока не реализовано извлечение цены
      expect(compactView.discountPrice, null); // Пока не реализовано извлечение скидки
      expect(compactView.hasPromotion, false); // Пока всегда false
      expect(compactView.canBuy, true);
      expect(compactView.amountInPackage, 5);
      expect(compactView.formattedPrice, 'Цена не указана'); // Пока цена не извлекается
      expect(compactView.formattedDiscountPrice, ''); // Пока скидка не извлекается
      expect(compactView.hasDiscount, false);
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
      expect(compactViews[0].hasPromotion, false); // Пока всегда false
      expect(compactViews[1].hasPromotion, false); // Пока всегда false
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

    test('parseProductApiResponse should parse API response correctly', () {
      // Arrange
      const apiResponseJson = '''
      {
        "data": [
          {
            "code": 170094,
            "title": "Test Product",
            "barcodes": ["123456"],
            "bcode": 110142,
            "catalogId": 110142,
            "novelty": false,
            "popular": true,
            "isMarked": false,
            "canBuy": true,
            "brand": {"id": 1, "name": "Test Brand"},
            "manufacturer": {"id": 1, "name": "Test Manufacturer"},
            "defaultImage": {"url": "http://example.com/image.jpg"},
            "images": [{"url": "http://example.com/image.jpg"}],
            "category": {"id": 1, "name": "Test Category"},
            "amountInPackage": 10,
            "vendorCode": "TEST001",
            "type": {"id": 1, "name": "Test Type"},
            "categoriesInstock": [{"id": 1, "name": "Test Category"}],
            "numericCharacteristics": [],
            "stringCharacteristics": [],
            "boolCharacteristics": [],
            "stockItems": [
              {
                "warehouseId": 1,
                "warehouseName": "Test Warehouse",
                "price": 100.50,
                "stock": 25,
                "reserved": 0
              }
            ]
          }
        ],
        "totalCount": 1
      }
      ''';

      // Act
      final apiResponse = service.parseProductApiResponse(apiResponseJson);

      // Assert
      expect(apiResponse.products.length, 1);
      expect(apiResponse.totalCount, 1);

      final product = apiResponse.products.first;
      expect(product.code, 170094);
      expect(product.title, 'Test Product');
      expect(product.canBuy, true);
      expect(product.stockItems.length, 1);
    });

    test('convertApiItemToProduct should convert API item from real product_example.json', () async {
      // Arrange - Загружаем реальный пример продукта
      final productExampleJson = await rootBundle.loadString('assets/fixtures/product_example.json');
      final productData = jsonDecode(productExampleJson) as Map<String, dynamic>;
      
      // Создаем API response в правильном формате с реальными данными
      final apiResponseJson = jsonEncode({
        "data": [productData],
        "totalCount": 1
      });

      final apiResponse = service.parseProductApiResponse(apiResponseJson);
      final apiItem = apiResponse.products.first;

      // Act
      final result = service.convertApiItemToProduct(apiItem, null);

      // Assert - Используем реальные данные из product_example.json
      expect(result.product.title, 'Туалетная бумага YOKO Takeshi Бамбук 3-х слойная 10 рулонов');
      expect(result.product.code, 170094);
      expect(result.product.canBuy, true);
      expect(result.stockItems.length, 1);
      
      final stockItem = result.stockItems.first;
      expect(stockItem.productCode, 170094);
      expect(stockItem.warehouseId, 10);
      expect(stockItem.warehouseName, 'Основной склад');
      expect(stockItem.defaultPrice, 66847); // Реальная цена из API в копейках (668.47 ₽)
      expect(stockItem.availablePrice, 45456); // Цена со скидкой 454.56 ₽
    });

    test('ProductApiItem.fromJson should handle real API data with null values', () async {
      // Arrange - загружаем реальный JSON из fixture
      final jsonString = await rootBundle.loadString('assets/fixtures/product_example.json');
      final json = jsonDecode(jsonString);

      // Act & Assert - не должно быть исключения
      try {
        final apiItem = ProductApiItem.fromJson(json);
        expect(apiItem.code, 170094);
      } catch (e) {
        rethrow;
      }
    });

    test('parseProductApiResponse should handle product_example2.json format', () async {
      // Arrange - Загружаем другой реальный пример продукта с stockItems
      final productExample2Json = await rootBundle.loadString('assets/fixtures/product_example2.json');
      final productData = jsonDecode(productExample2Json) as Map<String, dynamic>;
      
      // Создаем API response в правильном формате
      final apiResponseJson = jsonEncode({
        "data": [productData],
        "totalCount": 1
      });

      // Act - должен успешно парсить без исключений
      final apiResponse = service.parseProductApiResponse(apiResponseJson);

      // Assert
      expect(apiResponse.products.length, 1);
      expect(apiResponse.totalCount, 1);
      
      final product = apiResponse.products.first;
      expect(product.code, 102969);
      expect(product.title, 'Нитроэмаль Расцвет НЦ-132КП С золотисто-желтая 0.7 кг');
      expect(product.canBuy, true);
      expect(product.stockItems.length, greaterThan(0)); // Должны быть stockItems в реальных данных
    });

    test('ДИАГНОСТИКА: проверить обработку изображений в product_example.json', () async {
      // Arrange - Загружаем реальный пример с изображениями
      final productJsonString = await rootBundle.loadString('assets/fixtures/product_example.json');
      
      // Act - Парсим продукт
      final product = service.parseProduct(productJsonString);
      
      // Assert - Основные проверки
      expect(product.defaultImage, isNotNull, reason: 'defaultImage должно быть не null');
      expect(product.images, isNotEmpty, reason: 'images должно содержать элементы');
      expect(product.defaultImage?.uri, isNotEmpty, reason: 'defaultImage.uri не должно быть пустым');
      expect(product.images.first.uri, isNotEmpty, reason: 'images[0].uri не должно быть пустым');
      
      // Проверяем что URLs корректные
      expect(product.defaultImage?.uri, startsWith('https://'), reason: 'defaultImage.uri должно начинаться с https://');
      expect(product.images.first.uri, startsWith('https://'), reason: 'images[0].uri должно начинаться с https://');  
    });

    test('ProductApiItem.fromJson should handle null values gracefully', () {
      // Arrange - JSON с null значениями для обязательных полей
      final jsonWithNulls = {
        'code': null,
        'title': null,
        'barcodes': null,
        'bcode': null,
        'catalogId': null,
        'novelty': null,
        'popular': null,
        'isMarked': null,
        'canBuy': null,
        'images': null,
        'categoriesInstock': null,
        'numericCharacteristics': null,
        'stringCharacteristics': null,
        'boolCharacteristics': null,
        'stockItems': null,
      };

      // Act & Assert - не должно быть исключения
      expect(() => ProductApiItem.fromJson(jsonWithNulls), returnsNormally);

      final apiItem = ProductApiItem.fromJson(jsonWithNulls);

      // Assert - проверяем дефолтные значения
      expect(apiItem.code, 0);
      expect(apiItem.title, 'Без названия');
      expect(apiItem.barcodes, isEmpty);
      expect(apiItem.catalogId, 0);
      expect(apiItem.canBuy, true);
      expect(apiItem.images, isEmpty);
      expect(apiItem.stockItems, isEmpty);
    });
  });
}