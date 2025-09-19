// lib/features/shop/data/services/product_parsing_service.dart

import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/data/mappers/product_api_models.dart';

/// Сервис для парсинга JSON продуктов из API
class ProductParsingService {
  /// Парсит JSON строку в объект Product
  Product parseProduct(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Product.fromJson(json);
  }

  /// Парсит список JSON строк в список Product
  List<Product> parseProducts(List<String> jsonStrings) {
    return jsonStrings.map(parseProduct).toList();
  }

  /// Парсит JSON массив в список Product
  List<Product> parseProductsFromJsonArray(String jsonArrayString) {
    final List<dynamic> jsonArray = jsonDecode(jsonArrayString);
    return jsonArray.map((json) => Product.fromJson(json)).toList();
  }

  /// Создает компактное представление продукта для списков
  ProductCompactView createCompactView(Product product) {
    return ProductCompactView(
      id: product.catalogId,
      title: product.title,
      code: product.code,
      imageUrl: product.defaultImage?.uri ?? product.images.firstOrNull?.uri,
      weight: _extractWeight(product),
      amountInPackage: product.amountInPackage,
      price: _extractPrice(product),
      discountPrice: _extractDiscountPrice(product),
      hasPromotion: false, // TODO: Определять из отдельной таблицы StockItem
      canBuy: product.canBuy,
    );
  }

  /// Создает компактные представления для списка продуктов
  List<ProductCompactView> createCompactViews(List<Product> products) {
    return products.map(createCompactView).toList();
  }

  String? _extractWeight(Product product) {
    try {
      final weightCharacteristic = product.numericCharacteristics
          .firstWhere((char) => char.attributeName.toLowerCase().contains('вес'));
      return weightCharacteristic.adaptValue;
    } catch (e) {
      return null;
    }
  }

  int? _extractPrice(Product product) {
    // TODO: Цена должна извлекаться из StockItem репозитория по productCode
    return null;
  }

  int? _extractDiscountPrice(Product product) {
    // TODO: Скидочная цена должна извлекаться из StockItem репозитория по productCode
    return null;
  }  /// Парсит API ответ с продуктами и пагинацией
  ProductApiResponse parseProductApiResponse(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ProductApiResponse.fromJson(json);
  }

  /// Конвертирует ProductApiItem в Product и список StockItem
  ({Product product, List<StockItem> stockItems}) convertApiItemToProduct(ProductApiItem apiItem) {
    final logger = Logger('ProductParsingService');
    
    try {
      logger.info('Начало конвертации продукта ${apiItem.code}: ${apiItem.title}');
      logger.info('StockItems count: ${apiItem.stockItems.length}');
      
      // Создаем JSON для Product.fromJson без stockItems
      logger.info('Создание Product JSON...');
      final productJson = _convertApiItemToProductJson(apiItem);
      logger.info('Product JSON создан, содержит ${productJson.length} полей');
      
      // Проверяем ключевые поля
      logger.info('Проверка ключевых полей: code=${productJson['code']}, title=${productJson['title']}, canBuy=${productJson['canBuy']}');
      
      logger.info('Создание Product объекта из JSON...');
      final product = Product.fromJson(productJson);
      logger.info('Product объект создан: ${product.title}');
      
      // Конвертируем StockItemApi в StockItem
      logger.info('Начинаем конвертацию ${apiItem.stockItems.length} stock items');
      final stockItems = apiItem.stockItems.map((stockApi) => 
        _convertApiStockToStockItem(stockApi, apiItem.code)
      ).toList();
      
      logger.info('Всего конвертировано ${stockItems.length} stock items');
      return (product: product, stockItems: stockItems);
      
    } catch (e, st) {
      logger.severe('Ошибка конвертации продукта ${apiItem.code}: ${apiItem.title}', e, st);
      logger.severe('Stack trace: $st');
      rethrow;
    }
  }

  /// Конвертирует список ProductApiItem в продукты и stock items
  List<({Product product, List<StockItem> stockItems})> convertApiItemsToProducts(List<ProductApiItem> apiItems) {
    final logger = Logger('ProductParsingService');
    
    return apiItems.map((apiItem) {
      try {
        return convertApiItemToProduct(apiItem);
      } catch (e, st) {
        logger.severe('Ошибка конвертации продукта ${apiItem.code}: ${apiItem.title}', e, st);
        rethrow;
      }
    }).toList();
  }

  Map<String, dynamic> _convertApiItemToProductJson(ProductApiItem apiItem) {
    return {
      'title': apiItem.title,
      'barcodes': apiItem.barcodes,
      'code': apiItem.code,
      'bcode': apiItem.bcode,
      'catalogId': apiItem.catalogId,
      'novelty': apiItem.novelty,
      'popular': apiItem.popular,
      'isMarked': apiItem.isMarked,
      'canBuy': apiItem.canBuy,
      'brand': apiItem.brand != null ? {
        'search_priority': 100, // По умолчанию
        'id': apiItem.brand!.id,
        'name': apiItem.brand!.name,
        'adaptedName': apiItem.brand!.name, // Используем name как adaptedName
      } : null,
      'manufacturer': apiItem.manufacturer != null ? {
        'id': apiItem.manufacturer!.id,
        'name': apiItem.manufacturer!.name,
      } : null,
      'colorImage': apiItem.colorImage != null ? {
        'id': null,
        'height': 1000, // По умолчанию
        'width': 1000, // По умолчанию
        'uri': apiItem.colorImage!.url,
        'webp': apiItem.colorImage!.url, // Используем url как webp
      } : null,
      'defaultImage': apiItem.defaultImage != null ? {
        'id': null,
        'height': 1000, // По умолчанию
        'width': 1000, // По умолчанию
        'uri': apiItem.defaultImage!.url,
        'webp': apiItem.defaultImage!.url, // Используем url как webp
      } : null,
      'images': apiItem.images.map((img) => {
        'id': null,
        'height': 1000, // По умолчанию
        'width': 1000, // По умолчанию
        'uri': img.url,
        'webp': img.url, // Используем url как webp
      }).toList(),
      'description': apiItem.description,
      'howToUse': apiItem.howToUse,
      'ingredients': apiItem.ingredients,
      'series': apiItem.series != null ? {
        'id': apiItem.series!.id,
        'name': apiItem.series!.name,
      } : null,
      'category': apiItem.category != null ? {
        'id': apiItem.category!.id,
        'name': apiItem.category!.name,
        'isPublish': true, // По умолчанию
        'description': null,
        'query': null,
      } : null,
      'priceListCategoryId': apiItem.priceListCategoryId,
      'amountInPackage': apiItem.amountInPackage,
      'vendorCode': apiItem.vendorCode,
      'type': apiItem.type != null ? {
        'id': apiItem.type!.id,
        'name': apiItem.type!.name,
      } : null,
      'categoriesInstock': apiItem.categoriesInstock.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'isPublish': true, // По умолчанию
        'description': null,
        'query': null,
      }).toList(),
      'numericCharacteristics': apiItem.numericCharacteristics.map((char) => {
        'attributeId': 0, // По умолчанию
        'attributeName': char.name,
        'attributeValue': char.value?.toString(),
        'adaptValue': char.value?.toString(),
      }).toList(),
      'stringCharacteristics': apiItem.stringCharacteristics.map((char) => {
        'attributeId': 0, // По умолчанию
        'attributeName': char.name,
        'attributeValue': char.value?.toString(),
        'adaptValue': char.value?.toString(),
      }).toList(),
      'boolCharacteristics': apiItem.boolCharacteristics.map((char) => {
        'attributeId': 0, // По умолчанию
        'attributeName': char.name,
        'attributeValue': char.value?.toString(),
        'adaptValue': char.value?.toString(),
      }).toList(),
      // stockItems обрабатываются отдельно
    };
  }

  StockItem _convertApiStockToStockItem(StockItemApi apiStock, int productCode) {
    final logger = Logger('ProductParsingService');
    
    try {
      logger.info('Конвертация StockItemApi: warehouseId=${apiStock.warehouseId}, price=${apiStock.price}, stock=${apiStock.stock}');
      
      final stockItem = StockItem(
        id: 0, // Автоинкремент в БД
        productCode: productCode,
        warehouseId: apiStock.warehouseId,
        warehouseName: apiStock.warehouseName,
        warehouseVendorId: 'MAIN_VENDOR', // TODO: Определить из конфигурации
        isPickUpPoint: false, // TODO: Определить по типу склада
        stock: apiStock.stock,
        multiplicity: 1, // По умолчанию
        publicStock: apiStock.stock > 0 ? '${apiStock.stock} шт.' : 'Нет в наличии',
        defaultPrice: (apiStock.price * 100).round(), // Конвертируем в копейки
        discountValue: 0, // TODO: Добавить поддержку скидок
        availablePrice: (apiStock.price * 100).round(),
        offerPrice: (apiStock.price * 100).round(),
        currency: 'RUB',
        promotionJson: null, // TODO: Добавить поддержку акций
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      logger.info('StockItem успешно создан: ${stockItem.warehouseName}, price=${stockItem.defaultPrice}');
      return stockItem;
      
    } catch (e, st) {
      logger.severe('Ошибка конвертации StockItemApi для продукта $productCode', e, st);
      rethrow;
    }
  }
}

/// Компактное представление продукта для списков
class ProductCompactView {
  final int id;
  final String title;
  final int code;
  final String? imageUrl;
  final String? weight;
  final int? amountInPackage;
  final int? price;
  final int? discountPrice;
  final bool hasPromotion;
  final bool canBuy;

  ProductCompactView({
    required this.id,
    required this.title,
    required this.code,
    this.imageUrl,
    this.weight,
    this.amountInPackage,
    this.price,
    this.discountPrice,
    required this.hasPromotion,
    required this.canBuy,
  });

  /// Форматированная цена для отображения
  String get formattedPrice {
    if (price == null) return 'Цена не указана';
    return '${(price! / 100).toStringAsFixed(2)} ₽';
  }

  /// Форматированная скидочная цена для отображения
  String get formattedDiscountPrice {
    if (discountPrice == null) return '';
    return '${(discountPrice! / 100).toStringAsFixed(2)} ₽';
  }

  /// Есть ли скидка
  bool get hasDiscount => discountPrice != null && discountPrice! < (price ?? 0);
}