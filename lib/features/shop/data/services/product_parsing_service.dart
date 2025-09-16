// lib/features/shop/data/services/product_parsing_service.dart

import 'dart:convert';
import 'package:fieldforce/features/shop/domain/entities/product.dart';

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
      hasPromotion: product.stockItems.any((stock) => stock.promotion != null),
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
    if (product.stockItems.isEmpty) return null;
    return product.stockItems.first.defaultPrice;
  }

  int? _extractDiscountPrice(Product product) {
    if (product.stockItems.isEmpty) return null;
    final stockItem = product.stockItems.first;
    return stockItem.availablePrice ?? stockItem.offerPrice;
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