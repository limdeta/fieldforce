// test/unit/product_database_debug_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/mappers/product_mapper.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'dart:convert';

void main() {
  group('Product Database Debug Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(DatabaseConnection.fromExecutor(NativeDatabase.memory()));
    });

    tearDown(() async {
      await database.close();
    });

    test('should diagnose empty URLs issue', () async {
      // Создаем тестовый продукт с изображениями
      final testProduct = Product(
        catalogId: 123,
        code: 456,
        bcode: 789,
        title: 'Test Product with Images',
        description: 'Test Description',
        vendorCode: 'TEST001',
        amountInPackage: 1,
        novelty: false,
        popular: false,
        isMarked: false,
        canBuy: true,
        defaultImage: ImageData(
          id: 1,
          height: 800,
          width: 600,
          uri: 'https://example.com/default.jpg',
          webp: 'https://example.com/default.webp',
        ),
        images: [
          ImageData(
            id: 2,
            height: 1000,
            width: 1000,
            uri: 'https://example.com/image1.jpg',
            webp: 'https://example.com/image1.webp',
          ),
          ImageData(
            id: 3,
            height: 800,
            width: 600,
            uri: 'https://example.com/image2.jpg',
            webp: 'https://example.com/image2.webp',
          ),
        ],
        barcodes: ['123456789'],
        howToUse: 'Test usage',
        ingredients: 'Test ingredients',
        brand: null,
        manufacturer: null,
        colorImage: null,
        series: null,
        category: null,
        type: null,
        priceListCategoryId: 1,
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
      );

      // Конвертируем в Companion и сохраняем
      final companion = ProductMapper.toCompanion(testProduct);
      await database.into(database.products).insert(companion);

      // Читаем обратно из БД
      final productData = await database.select(database.products).getSingle();

      // Парсим обратно в Product
      final restoredProduct = ProductMapper.fromData(productData);

      // Проверяем что URL-адреса сохранились
      expect(restoredProduct.defaultImage, isNotNull);
      expect(restoredProduct.defaultImage!.uri, equals('https://example.com/default.jpg'));
      expect(restoredProduct.defaultImage!.webp, equals('https://example.com/default.webp'));
      
      expect(restoredProduct.images.length, equals(2));
      expect(restoredProduct.images[0].uri, equals('https://example.com/image1.jpg'));
      expect(restoredProduct.images[0].webp, equals('https://example.com/image1.webp'));
      expect(restoredProduct.images[1].uri, equals('https://example.com/image2.jpg'));
      expect(restoredProduct.images[1].webp, equals('https://example.com/image2.webp'));
    });

    test('should check what happens with real API data structure', () async {
      // Симулируем данные как они приходят из API
      const apiProductJson = '''
      {
        "id": 45391,
        "code": 6001,
        "bcode": 4607010252014,
        "title": "Тестовый продукт",
        "defaultImage": {
          "id": 1,
          "height": 800,
          "width": 600,
          "uri": "https://api.example.com/image.jpg",
          "webp": "https://api.example.com/image.webp"
        },
        "images": [
          {
            "id": 2,
            "height": 1000,
            "width": 1000,  
            "uri": "https://api.example.com/img1.jpg",
            "webp": "https://api.example.com/img1.webp"
          }
        ]
      }''';

      // Парсим продукт из JSON (как делает ProductParsingService)
      final productFromJson = Product.fromJson(jsonDecode(apiProductJson));
      
      // Сохраняем в БД
      final companion = ProductMapper.toCompanion(productFromJson);
      await database.into(database.products).insert(companion);
      
      // Читаем обратно
      final productData = await database.select(database.products).getSingle();
      final restoredProduct = ProductMapper.fromData(productData);
      
      expect(restoredProduct.defaultImage?.uri, equals(productFromJson.defaultImage?.uri));
    });
  });
}