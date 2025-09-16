// lib/features/shop/data/fixtures/product_fixture_service.dart

import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/shared/either.dart';

/// Тип фикстуры для загрузки продуктов
enum ProductFixtureType {
  /// Сокращенная фикстура для тестов (2-3 продукта)
  compact,
  /// Полная фикстура из product_example*.json для dev режима
  full,
}

class ProductFixtureService {
  final ProductParsingService _parsingService;

  ProductFixtureService(this._parsingService);

  /// Загружает продукты в зависимости от типа фикстуры
  Future<Either<Failure, List<Product>>> loadProducts(ProductFixtureType fixtureType) async {
    try {
      print('🎭 ProductFixtureService: Начинаем загрузку продуктов типа $fixtureType');
      switch (fixtureType) {
        case ProductFixtureType.compact:
          return Right(_loadCompactProducts());
        case ProductFixtureType.full:
          final products = await _loadFullProducts();
          print('🎭 ProductFixtureService: Загружено ${products.length} продуктов из JSON файлов');
          return Right(products);
      }
    } catch (e) {
      print('🎭 ProductFixtureService: Ошибка загрузки фикстуры продуктов: $e');
      return Left(GeneralFailure('Ошибка загрузки фикстуры продуктов: $e'));
    }
  }

  /// Сокращенная фикстура для тестов с 2-3 продуктами
  List<Product> _loadCompactProducts() {
    final compactJson = '''
[
  {
    "title": "Тестовый продукт 1",
    "barcodes": ["123456789"],
    "code": 1001,
    "bcode": 1001,
    "catalogId": 1001,
    "novelty": false,
    "popular": false,
    "isMarked": false,
    "brand": null,
    "manufacturer": null,
    "colorImage": null,
    "defaultImage": null,
    "images": [],
    "description": "Тестовый продукт для интеграционных тестов",
    "howToUse": null,
    "ingredients": null,
    "series": null,
    "category": {
      "id": 221,
      "name": "Эмали НЦ",
      "isPublish": true,
      "description": null,
      "query": "types=1163,1220"
    },
    "priceListCategoryId": null,
    "amountInPackage": 1,
    "vendorCode": "TEST001",
    "type": {
      "id": 1163,
      "name": "Нитроэмаль"
    },
    "categoriesInstock": [
      {
        "id": 221,
        "name": "Эмали НЦ"
      }
    ],
    "numericCharacteristics": [],
    "stringCharacteristics": [],
    "boolCharacteristics": [],
    "stockItems": [
      {
        "id": 1,
        "publicStock": "10 шт.",
        "warehouse": {
          "id": 1,
          "name": "Основной склад",
          "vendorId": "MAIN",
          "isPickUpPoint": false
        },
        "defaultPrice": 10000,
        "discountValue": 0,
        "availablePrice": null,
        "multiplicity": 1,
        "offerPrice": 10000,
        "promotion": null
      }
    ],
    "canBuy": true
  },
  {
    "title": "Тестовый продукт 2",
    "barcodes": ["987654321"],
    "code": 1002,
    "bcode": 1002,
    "catalogId": 1002,
    "novelty": false,
    "popular": false,
    "isMarked": false,
    "brand": null,
    "manufacturer": null,
    "colorImage": null,
    "defaultImage": null,
    "images": [],
    "description": "Второй тестовый продукт",
    "howToUse": null,
    "ingredients": null,
    "series": null,
    "category": {
      "id": 221,
      "name": "Эмали НЦ",
      "isPublish": true,
      "description": null,
      "query": "types=1163,1220"
    },
    "priceListCategoryId": null,
    "amountInPackage": 1,
    "vendorCode": "TEST002",
    "type": {
      "id": 1163,
      "name": "Нитроэмаль"
    },
    "categoriesInstock": [
      {
        "id": 221,
        "name": "Эмали НЦ"
      }
    ],
    "numericCharacteristics": [],
    "stringCharacteristics": [],
    "boolCharacteristics": [],
    "stockItems": [
      {
        "id": 2,
        "publicStock": "5 шт.",
        "warehouse": {
          "id": 1,
          "name": "Основной склад",
          "vendorId": "MAIN",
          "isPickUpPoint": false
        },
        "defaultPrice": 15000,
        "discountValue": 0,
        "availablePrice": null,
        "multiplicity": 1,
        "offerPrice": 15000,
        "promotion": null
      }
    ],
    "canBuy": true
  }
]
''';
    return _parsingService.parseProductsFromJsonArray(compactJson);
  }

  /// Загружает полные продукты из asset файлов
  Future<List<Product>> _loadFullProducts() async {
    final List<Product> products = [];

    // Загружаем все product_example*.json файлы
    final assetFiles = [
      'assets/fixtures/product_example.json',
      'assets/fixtures/product_example2.json',
      'assets/fixtures/product_example3.json',
      'assets/fixtures/product_example4.json',
    ];

    print('🎭 ProductFixtureService: Начинаем загрузку из ${assetFiles.length} файлов');

    for (final assetPath in assetFiles) {
      try {
        print('🎭 ProductFixtureService: Загружаем файл $assetPath');
        final jsonString = await rootBundle.loadString(assetPath);
        final product = _parsingService.parseProduct(jsonString);
        products.add(product);
        print('🎭 ProductFixtureService: Загружен продукт ${product.title} (код: ${product.code}) из $assetPath');
      } catch (e) {
        print('🎭 ProductFixtureService: Ошибка загрузки файла $assetPath: $e');
        // Игнорируем ошибки загрузки отдельных файлов
        continue;
      }
    }

    print('🎭 ProductFixtureService: Всего загружено ${products.length} продуктов из JSON файлов');
    return products;
  }

  /// Фильтрует продукты по категории
  List<Product> filterProductsByCategory(List<Product> products, int categoryId) {
    return products.where((product) {
      // Проверяем основную категорию
      if (product.category?.id == categoryId) {
        return true;
      }

      // Проверяем категории в списке categoriesInstock
      return product.categoriesInstock.any((category) => category.id == categoryId);
    }).toList();
  }

  /// Фильтрует продукты по типу
  List<Product> filterProductsByType(List<Product> products, int typeId) {
    return products.where((product) => product.type?.id == typeId).toList();
  }
}