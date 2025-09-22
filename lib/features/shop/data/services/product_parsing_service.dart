// lib/features/shop/data/services/product_parsing_service.dart

import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/data/mappers/product_api_models.dart';

/// Сервис для парсинга JSON продуктов из API
class ProductParsingService {
  Product parseProduct(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Product.fromJson(json);
  }

  List<Product> parseProducts(List<String> jsonStrings) {
    return jsonStrings.map(parseProduct).toList();
  }

  List<Product> parseProductsFromJsonArray(String jsonArrayString) {
    final List<dynamic> jsonArray = jsonDecode(jsonArrayString);
    return jsonArray.map((json) => Product.fromJson(json)).toList();
  }

  ProductCompactView createCompactView(Product product) {
    return ProductCompactView(
      id: product.catalogId,
      title: product.title,
      code: product.code,
      imageUrl: product.defaultImage?.getOptimalUrl() ?? product.images.firstOrNull?.getOptimalUrl(),
      weight: _extractWeight(product),
      amountInPackage: product.amountInPackage,
      price: _extractPrice(product),
      discountPrice: _extractDiscountPrice(product),
      hasPromotion: false, // TODO: Определять из отдельной таблицы StockItem
      canBuy: product.canBuy,
    );
  }

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
    final logger = Logger('ProductParsingService');
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final response = ProductApiResponse.fromJson(json);
    
    // КРИТИЧНО: Проверяем что API вернул продукты с stockItems
    if (response.products.isNotEmpty) {
      final productsWithoutStock = response.products.where((p) => p.stockItems.isEmpty).toList();
      if (productsWithoutStock.isNotEmpty) {
        final error = 'КРИТИЧЕСКАЯ ОШИБКА: ${productsWithoutStock.length}/${response.products.length} продуктов без stockItems! '
            'Примеры: ${productsWithoutStock.take(3).map((p) => '${p.code}:${p.title}').join(', ')}. '
            'Проблема с PHP сессией или параметрами API!';
        logger.severe(error);
        throw Exception(error);
      }
    }
    
    return response;
  }

  /// Конвертирует ProductApiItem в Product и список StockItem
  ({Product product, List<StockItem> stockItems}) convertApiItemToProduct(
    ProductApiItem apiItem, 
    Map<String, dynamic>? rawJson,
  ) {
    final logger = Logger('ProductParsingService');
    
    // КРИТИЧНО: Если API не возвращает stockItems - это ошибка авторизации/сессии
    if (apiItem.stockItems.isEmpty) {
      final error = 'КРИТИЧЕСКАЯ ОШИБКА: API не вернул stockItems для продукта ${apiItem.code}: ${apiItem.title}. '
          'проблемы с PHP сессией или параметрами запроса!';
      logger.severe(error);
      throw Exception(error);
    }
    
    try {
      final productJson = _convertApiItemToProductJson(apiItem, rawJson);
      
      final product = Product.fromJson(productJson);
      
      // Конвертируем StockItemApi в StockItem
      final stockItems = apiItem.stockItems.map((stockApi) => 
        _convertApiStockToStockItem(stockApi, apiItem.code)
      ).toList();
      
      return (product: product, stockItems: stockItems);
      
    } catch (e, st) {
      logger.severe('Ошибка конвертации продукта ${apiItem.code}: ${apiItem.title}', e, st);
      rethrow;
    }
  }

  List<({Product product, List<StockItem> stockItems})> convertApiItemsToProducts(List<ProductApiItem> apiItems) {
    final logger = Logger('ProductParsingService');
    
    return apiItems.map((apiItem) {
      try {
        return convertApiItemToProduct(apiItem, null);
      } catch (e, st) {
        logger.severe('Ошибка конвертации продукта ${apiItem.code}: ${apiItem.title}', e, st);
        rethrow;
      }
    }).toList();
  }

  Map<String, dynamic> _convertApiItemToProductJson(ProductApiItem apiItem, Map<String, dynamic>? rawJson) {
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
      'colorImage': rawJson?['colorImage'],
      // Берем изображения прямо из rawJson чтобы сохранить все поля как есть
      'defaultImage': rawJson?['defaultImage'],
      'images': rawJson?['images'] ?? [],
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
        'isPublish': true,
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
        'isPublish': true,
        'description': null,
        'query': null,
      }).toList(),
      'numericCharacteristics': apiItem.numericCharacteristics.map((char) => {
        'attributeId': 0,
        'attributeName': char.name,
        'attributeValue': char.value?.toString(),
        'adaptValue': char.value?.toString(),
      }).toList(),
      'stringCharacteristics': apiItem.stringCharacteristics.map((char) => {
        'attributeId': 0,
        'attributeName': char.name,
        'attributeValue': char.value?.toString(),
        'adaptValue': char.value?.toString(),
      }).toList(),
      'boolCharacteristics': apiItem.boolCharacteristics.map((char) => {
        'attributeId': 0, 
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
      // logger.info('Конвертация StockItemApi: warehouseId=${apiStock.warehouseId}, price=${apiStock.price}, stock=${apiStock.stock}');
      
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
        defaultPrice: apiStock.price.round(), // API уже возвращает цены в копейках
        discountValue: 0, // TODO: Добавить поддержку скидок  
        availablePrice: apiStock.availablePrice?.round() ?? apiStock.price.round(),
        offerPrice: apiStock.offerPrice?.round() ?? apiStock.price.round(),
        currency: 'RUB',
        promotionJson: null, // TODO: Добавить поддержку акций
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // logger.info('StockItem успешно создан: ${stockItem.warehouseName}, price=${stockItem.defaultPrice}');
      return stockItem;
      
    } catch (e, st) {
      logger.severe('Ошибка конвертации StockItemApi для продукта $productCode', e, st);
      rethrow;
    }
  }
}

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

  String get formattedPrice {
    if (price == null) return 'Цена не указана';
    return '${(price! / 100).toStringAsFixed(2)} ₽';
  }

  String get formattedDiscountPrice {
    if (discountPrice == null) return '';
    return '${(discountPrice! / 100).toStringAsFixed(2)} ₽';
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < (price ?? 0);
}