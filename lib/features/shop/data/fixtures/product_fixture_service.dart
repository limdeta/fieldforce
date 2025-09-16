// lib/features/shop/data/fixtures/product_fixture_service.dart

import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'dart:math';

/// Тип фикстуры для загрузки продуктов
enum ProductFixtureType {
  /// Сокращенная фикстура для тестов (2-3 продукта)
  compact,
  /// Полная фикстура из product_example*.json для dev режима
  full,
}

class ProductFixtureService {
  static final Logger _logger = Logger('ProductFixtureService');
  final ProductParsingService _parsingService;
  final Random _random = Random();

  ProductFixtureService(this._parsingService);

  /// Загружает продукты в зависимости от типа фикстуры
  Future<Either<Failure, List<Product>>> loadProducts(ProductFixtureType fixtureType) async {
    try {
      _logger.info('Начинаем загрузку продуктов типа $fixtureType');
      
      final products = switch (fixtureType) {
        ProductFixtureType.compact => _loadCompactProducts(),
        ProductFixtureType.full => await _loadFullProducts(),
      };
      
      _logger.info('Загружено ${products.length} продуктов из JSON файлов');
      
      // Создаем StockItems для загруженных продуктов
      await _createStockItemsForProducts(products);
      
      return Right(products);
    } catch (e, st) {
      _logger.severe('Ошибка загрузки фикстуры продуктов', e, st);
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

  /// Создает StockItems для списка продуктов
  Future<void> _createStockItemsForProducts(List<Product> products) async {
    try {
      final stockItemRepository = GetIt.instance<StockItemRepository>();
      final stockItems = <StockItem>[];

      for (final product in products) {
        final productStockItems = _generateStockItemsForProduct(product.code);
        stockItems.addAll(productStockItems);
      }

      _logger.info('Создаем ${stockItems.length} StockItem записей для ${products.length} продуктов');
      
      final result = await stockItemRepository.saveStockItems(stockItems);
      result.fold(
        (failure) => _logger.warning('Ошибка сохранения StockItems: ${failure.message}'),
        (_) => _logger.info('StockItems успешно сохранены'),
      );
    } catch (e, st) {
      _logger.severe('Ошибка создания StockItems для продуктов', e, st);
    }
  }

  /// Генерирует StockItems для конкретного продукта
  List<StockItem> _generateStockItemsForProduct(int productCode) {
    final stockItems = <StockItem>[];
    
    // Тестовые регионы/продавцы
    const vendorIds = ['vendor_moscow', 'vendor_spb', 'vendor_nsk'];
    
    // Тестовые склады по регионам
    const warehousesByVendor = {
      'vendor_moscow': [
        (1, 'Склад Москва Центр', false),
        (2, 'ПВЗ Москва Арбат', true),
      ],
      'vendor_spb': [
        (4, 'Склад СПб Север', false),
        (5, 'ПВЗ СПб Невский', true),
      ],
      'vendor_nsk': [
        (6, 'Склад Новосибирск', false),
      ],
    };

    // Создаем остатки для случайных регионов (1-2 из 3)
    final selectedVendors = vendorIds.take(1 + _random.nextInt(2)).toList();
    
    for (final vendorId in selectedVendors) {
      final warehouses = warehousesByVendor[vendorId] ?? [];
      
      for (final warehouse in warehouses) {
        // С вероятностью 80% создаем StockItem для склада
        if (_random.nextDouble() < 0.8) {
          final stockItem = _generateStockItem(
            productCode, 
            warehouse.$1, // warehouseId
            warehouse.$2, // warehouseName
            warehouse.$3, // isPickUpPoint
            vendorId,
          );
          stockItems.add(stockItem);
        }
      }
    }

    return stockItems;
  }

  /// Генерирует один StockItem
  StockItem _generateStockItem(
    int productCode,
    int warehouseId, 
    String warehouseName,
    bool isPickUpPoint,
    String vendorId,
  ) {
    final basePrice = _generateBasePrice();
    final hasDiscount = _random.nextDouble() < 0.25; // 25% товаров со скидкой
    
    final stock = _generateStock(isPickUpPoint);
    
    return StockItem(
      id: _generateId(),
      productCode: productCode,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      warehouseVendorId: vendorId,
      isPickUpPoint: isPickUpPoint,
      stock: stock,
      publicStock: '${stock} шт.',
      defaultPrice: basePrice,
      discountValue: hasDiscount ? ((basePrice - _generateDiscountPrice(basePrice)) / basePrice * 100).round() : 0,
      offerPrice: hasDiscount ? _generateDiscountPrice(basePrice) : null,
      currency: 'RUB',
      promotionJson: hasDiscount ? _generatePromotionJson() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Генерирует базовую цену товара (в копейках)
  int _generateBasePrice() {
    final priceRanges = [
      (5000, 15000),   // 50-150 руб
      (15000, 50000),  // 150-500 руб
      (50000, 150000), // 500-1500 руб
    ];
    
    final range = priceRanges[_random.nextInt(priceRanges.length)];
    return range.$1 + _random.nextInt(range.$2 - range.$1);
  }

  /// Генерирует количество товара на складе
  int _generateStock(bool isPickUpPoint) {
    if (isPickUpPoint) {
      // ПВЗ: 0-20 штук
      return _random.nextInt(21);
    } else {
      // Склад: 0-500 штук, с акцентом на наличие
      final stockTypes = [0, 5, 15, 50, 100, 250];
      return stockTypes[_random.nextInt(stockTypes.length)];
    }
  }

  /// Генерирует цену со скидкой
  int _generateDiscountPrice(int basePrice) {
    final discountPercent = 0.05 + _random.nextDouble() * 0.35; // Скидка 5-40%
    return (basePrice * (1 - discountPercent)).round();
  }

  /// Генерирует JSON промоакции
  String _generatePromotionJson() {
    final promotions = [
      '{"type": "discount", "title": "Скидка недели", "percent": 15}',
      '{"type": "cashback", "title": "Кэшбэк 10%", "percent": 10}',
      '{"type": "bundle", "title": "При покупке от 3000 руб", "threshold": 300000}',
    ];
    
    return promotions[_random.nextInt(promotions.length)];
  }

  /// Генерирует уникальный ID (в реальности будет автоинкремент в БД)
  int _generateId() {
    return DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000);
  }
}