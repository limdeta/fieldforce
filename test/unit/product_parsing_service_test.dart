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

    test('convertApiItemToProduct should convert API item to domain entities', () {
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

      final apiResponse = service.parseProductApiResponse(apiResponseJson);
      final apiItem = apiResponse.products.first;

      // Act
      final result = service.convertApiItemToProduct(apiItem);

      // Assert
      expect(result.product.title, 'Test Product');
      expect(result.product.code, 170094);
      expect(result.product.canBuy, true);
      expect(result.stockItems.length, 1);
      
      final stockItem = result.stockItems.first;
      expect(stockItem.productCode, 170094);
      expect(stockItem.warehouseId, 1);
      expect(stockItem.warehouseName, 'Test Warehouse');
      expect(stockItem.stock, 25);
      expect(stockItem.defaultPrice, 10050); // 100.50 * 100 = 10050 копеек
    });

    test('ProductApiItem.fromJson should handle real API data with null values', () async {
      // Arrange - загружаем реальный JSON из fixture
      final jsonString = await rootBundle.loadString('assets/fixtures/product_example.json');
      final json = jsonDecode(jsonString);

      // Debug: проверим основные поля
      print('JSON keys: ${json.keys.toList()}');
      print('code: ${json['code']} (${json['code'].runtimeType})');
      print('title: ${json['title']} (${json['title'].runtimeType})');
      print('stockItems length: ${json['stockItems']?.length}');

      // Act & Assert - не должно быть исключения
      try {
        final apiItem = ProductApiItem.fromJson(json);
        print('Successfully parsed ProductApiItem');
        expect(apiItem.code, 170094);
      } catch (e, st) {
        print('Error parsing ProductApiItem: $e');
        print('Stack trace: $st');
        rethrow;
      }
    });

    test('parseProductApiResponse should handle real API response format', () {
      // Arrange - реальный формат ответа API с data массивом
      const realApiResponseJson = '''
      {
        "data": [
          {
            "title": "Колготки Glamour Velour 120 Den цвет Nero размер 3",
            "sortTitle": "Колготки Glamour Velour 120 Den цвет Nero размер 3",
            "barcodes": ["8051403015902"],
            "code": 117575,
            "bcode": 64213,
            "catalogId": 64213,
            "novelty": false,
            "popular": true,
            "isMarked": true,
            "brand": {
              "search_priority": 0,
              "id": 315,
              "name": "Glamour",
              "adaptedName": "гламур"
            },
            "manufacturer": {
              "id": 30,
              "name": "ИТАЛКОМ"
            },
            "colorImage": null,
            "defaultImage": {
              "id": null,
              "height": 700,
              "width": 700,
              "uri": "https://api.bonjour-dv.ru/public_v1/products/64213/images/41643.jpg",
              "webp": "https://api.bonjour-dv.ru/public_v1/products/64213/images/41643.webp"
            },
            "images": [
              {
                "height": 700,
                "uri": "https://api.bonjour-dv.ru/public_v1/products/64213/images/41643.jpg",
                "webp": "https://api.bonjour-dv.ru/public_v1/products/64213/images/41643.webp",
                "width": 700
              }
            ],
            "series": {
              "id": 3234,
              "name": "Velour"
            },
            "priceListCategoryId": 117557,
            "amountInPackage": 1,
            "vendorCode": "8051403015902",
            "type": {
              "id": 304,
              "name": "Колготки"
            },
            "categoriesInstock": [
              {
                "id": 31,
                "name": "Колготки"
              }
            ],
            "numericCharacteristics": [
              {
                "attributeId": 12,
                "attributeName": "Плотность",
                "id": 1068,
                "type": "numeric",
                "adaptValue": "120DEN",
                "value": 120
              }
            ],
            "stringCharacteristics": [
              {
                "attributeId": 50,
                "attributeName": "Цвет",
                "id": 51092,
                "type": "string",
                "adaptValue": "черный",
                "value": 366
              },
              {
                "attributeId": 10,
                "attributeName": "Размер",
                "id": 1876,
                "type": "string",
                "adaptValue": "3",
                "value": 24
              }
            ],
            "boolCharacteristics": [
              {
                "attributeId": 11,
                "attributeName": "Фантазийные",
                "id": 1854,
                "type": "bool",
                "adaptValue": null,
                "value": false
              }
            ]
          }
        ],
        "totalCount": 387
      }
      ''';

      // Act & Assert - не должно быть исключения
      expect(() => service.parseProductApiResponse(realApiResponseJson), returnsNormally);

      final apiResponse = service.parseProductApiResponse(realApiResponseJson);

      // Assert
      expect(apiResponse.products.length, 1);
      expect(apiResponse.totalCount, 387);
      
      final product = apiResponse.products.first;
      expect(product.code, 117575);
      expect(product.title, 'Колготки Glamour Velour 120 Den цвет Nero размер 3');
      expect(product.canBuy, true); // По умолчанию true
      expect(product.stockItems, isEmpty); // В этом ответе нет stockItems
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