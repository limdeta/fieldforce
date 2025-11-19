// lib/features/shop/data/fixtures/product_fixture_service.dart

import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/data/fixtures/fixture_warehouses.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';



/// Тип фикстуры для загрузки продуктов
enum ProductFixtureType {
  /// Сокращенная фикстура для тестов (2-3 продукта)
  compact,
  /// Полная фикстура из product_example*.json для dev режима
  full,
}

class ProductFixtureService {
  static final Logger _logger = Logger('ProductFixtureService');
  final ProductParsingService _parsingService = ProductParsingService();

  ProductFixtureService();

  /// Загружает продукты в зависимости от типа фикстуры
  Future<Either<Failure, List<Product>>> loadProducts(ProductFixtureType fixtureType) async {
    try {
      _logger.info('Начинаем загрузку продуктов типа $fixtureType');
      
      final products = switch (fixtureType) {
        ProductFixtureType.compact => _loadCompactProducts(),
        ProductFixtureType.full => await _loadFullProducts(),
      };
      
      _logger.info('Загружено ${products.length} продуктов из JSON файлов');
      
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
    "defaultImage": {
      "uri": "https://via.placeholder.com/300x300/FF6B35/FFFFFF?text=TEST1",
      "description": "Тестовое изображение продукта 1"
    },
    "images": [
      {
        "uri": "https://via.placeholder.com/300x300/FF6B35/FFFFFF?text=TEST1",
        "description": "Тестовое изображение продукта 1"
      }
    ],
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
    "amountInPackage": 12,
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
    "amountInPackage": 6,
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


    for (final assetPath in assetFiles) {
      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final product = _parsingService.parseProduct(jsonString);
        products.add(product);
      } catch (e) {
        // Игнорируем ошибки загрузки отдельных файлов
        continue;
      }
    }

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
  Future<void> createStockItemsForProducts(List<Product> products) async {
    try {
      _logger.info('🏭 Создаем остатки для ${products.length} продуктов: ${products.map((p) => p.code).join(', ')}');
      
      // Временно отключаем foreign key constraints для фикстур
      final database = GetIt.instance<AppDatabase>();
      await database.customStatement('PRAGMA foreign_keys = OFF');

      await _ensureFixtureWarehouses();
      
      final stockItems = <StockItem>[];
      
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        final productStockItems = _createStockForProduct(product, forceInStock: i == 0);
        stockItems.addAll(productStockItems);
      }

      _logger.info('💾 Сохраняем ${stockItems.length} StockItem записей');
      
      final stockItemRepository = GetIt.instance<StockItemRepository>();
      final result = await stockItemRepository.saveStockItems(stockItems);
      
      // Включаем обратно foreign key constraints
      await database.customStatement('PRAGMA foreign_keys = ON');
      
      result.fold(
        (failure) => _logger.warning('❌ Ошибка сохранения StockItems: ${failure.message}'),
        (_) => _logger.info('✅ StockItems успешно сохранены'),
      );
    } catch (e, st) {
      _logger.severe('💥 Ошибка создания StockItems для продуктов', e, st);
    }
  }

  /// Создает остатки для конкретного продукта
  List<StockItem> _createStockForProduct(Product product, {bool forceInStock = false}) {
    final stockItems = <StockItem>[];
    
    switch (product.code) {
      case 170094: // Туалетная бумага YOKO
        stockItems.addAll([
          _createStockItem(product, fixtureWarehouseById(1), 25, 12000), // 120 руб
        ]);
        break;
        
      case 102969: // Нитроэмаль золотисто-желтая  
        stockItems.addAll([
          _createStockItem(product, fixtureWarehouseById(1), 15, 8500),  // 85 руб
          _createStockItem(product, fixtureWarehouseById(2), 3, 9000),   // 90 руб (дороже в ПВЗ)
        ]);
        break;
        
      case 102970: // Нитроэмаль синяя
        stockItems.addAll([
          _createStockItem(product, fixtureWarehouseById(1), 22, 8500),  // 85 руб
          _createStockItem(product, fixtureWarehouseById(2), 12, 8800),  // 88 руб
          _createStockItem(product, fixtureWarehouseById(3), 5, 8200),   // 82 руб (дешевле на южном складе)
        ]);
        break;
        
      case 102971: // Нитроэмаль красная
        stockItems.addAll([
          _createStockItem(product, fixtureWarehouseById(1), 18, 8500),  // 85 руб
          _createStockItem(product, fixtureWarehouseById(3), 7, 8200),   // 82 руб
          // НЕТ в ПВЗ Центральный - для тестирования разных складов
        ]);
        break;
        
      default:
        // Для неизвестных товаров - простая схема
        stockItems.addAll([
          _createStockItem(product, fixtureWarehouseById(1), 10, 10000), // 100 руб
        ]);
    }

    _ensureRegionalCoverage(product, stockItems, forceInStock: forceInStock);

    return stockItems;
  }
  
  /// Вспомогательный метод для создания StockItem
  StockItem _createStockItem(
    Product product,
    FixtureWarehouseData warehouse,
    int stock,
    int price,
  ) {
    return StockItem(
      id: 0, // Автоинкремент в БД
      productCode: product.code,
      warehouseId: warehouse.id,
      warehouseName: warehouse.name,
      warehouseVendorId: warehouse.vendorId,
      isPickUpPoint: warehouse.isPickUpPoint,
      stock: stock,
      multiplicity: 1,
      publicStock: stock > 0 ? '$stock шт.' : 'Нет в наличии',
      defaultPrice: price,
      discountValue: 0,
      availablePrice: price,
      offerPrice: price,
      currency: 'RUB',
      promotionJson: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
    void _ensureRegionalCoverage(
      Product product,
      List<StockItem> stockItems, {
      required bool forceInStock,
    }) {
      if (stockItems.isEmpty) {
        final fallbackWarehouse = fixtureWarehouseByRegion('P3V');
        stockItems.add(
          _createStockItem(
            product,
            fallbackWarehouse,
            forceInStock ? 15 : 8,
            10000,
          ),
        );
      }

      var basePrice = stockItems.first.defaultPrice;
      if (basePrice <= 0) {
        basePrice = 10000;
      }

      for (final region in const ['P3V', 'K3V', 'M3V']) {
        final warehouse = fixtureWarehouseByRegion(region);
        final hasRegion = stockItems.any((item) => item.warehouseId == warehouse.id);

        if (!hasRegion) {
          final stockValue = forceInStock ? 14 : 6;
          stockItems.add(
            _createStockItem(
              product,
              warehouse,
              stockValue,
              _regionalPrice(basePrice, region),
            ),
          );
        }
      }
    }

    int _regionalPrice(int basePrice, String regionCode) {
      switch (regionCode) {
        case 'K3V':
          return basePrice + 400;
        case 'M3V':
          return basePrice + 250;
        default:
          return basePrice;
      }
    }


  Future<void> _ensureFixtureWarehouses() async {
    final warehouseRepository = GetIt.instance<WarehouseRepository>();
    final warehouses = buildFixtureWarehouses();

    final result = await warehouseRepository.saveWarehouses(warehouses);
    result.fold(
      (failure) => _logger.warning('❌ Не удалось сохранить фикстурные склады: ${failure.message}'),
      (_) => _logger.info('🏭 Сохранены ${warehouses.length} фикстурных складов'),
    );
  }

}