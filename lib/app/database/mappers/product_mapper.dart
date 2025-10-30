// lib/app/database/mappers/product_mapper.dart

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/app/database/app_database.dart';

class ProductMapper {
  static final Logger _logger = Logger('ProductMapper');
  static Product fromData(ProductData data) {
    final productJson = jsonDecode(data.rawJson) as Map<String, dynamic>;
    
    final product = Product.fromJson(productJson);
    
    return Product(
      title: data.title,
      code: data.code,
      bcode: data.bcode,
      catalogId: data.catalogId,
      novelty: data.novelty,
      popular: data.popular,
      isMarked: data.isMarked,
      canBuy: data.canBuy,
      description: data.description,
      howToUse: data.howToUse,
      ingredients: data.ingredients,
      amountInPackage: data.amountInPackage,
      vendorCode: data.vendorCode,
      
      images: () {
        final parsedImages = _parseImagesFromData(data);
        return parsedImages.isNotEmpty ? parsedImages : product.images;
      }(),
      defaultImage: () {
        final parsedDefault = _parseDefaultImageFromData(data);
        return parsedDefault ?? product.defaultImage;
      }(),
      barcodes: () {
        final parsedBarcodes = _parseBarcodesFromData(data);
        return parsedBarcodes.isNotEmpty ? parsedBarcodes : product.barcodes;
      }(),
      
      priceListCategoryId: data.priceListCategoryId ?? product.priceListCategoryId,
      
      brand: product.brand,
      manufacturer: product.manufacturer,
      colorImage: product.colorImage,
      series: product.series,
      category: product.category,
      type: product.type,
      categoriesInstock: product.categoriesInstock,
      numericCharacteristics: product.numericCharacteristics,
      stringCharacteristics: product.stringCharacteristics,
      boolCharacteristics: product.boolCharacteristics,
    );
  }
  
  static List<ImageData> _parseImagesFromData(ProductData data) {
    if (data.imagesJson == null || data.imagesJson!.isEmpty) return [];
    
    try {
      final imagesJsonList = jsonDecode(data.imagesJson!) as List<dynamic>;
      return imagesJsonList
          .map((imgJson) => ImageData.fromJson(imgJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Создает defaultImage из defaultImageJson
  static ImageData? _parseDefaultImageFromData(ProductData data) {
    if (data.defaultImageJson != null && data.defaultImageJson!.isNotEmpty) {
      try {
        final defaultImageJson = jsonDecode(data.defaultImageJson!) as Map<String, dynamic>;
        final imageData = ImageData.fromJson(defaultImageJson);
        return imageData;
      } catch (e) {
        _logger.warning('ProductMapper: Ошибка парсинга defaultImageJson: $e');
      }
    } else {
      // _logger.fine('ProductMapper: defaultImageJson пуст или null для продукта ${data.catalogId}');
    }
    
    final images = _parseImagesFromData(data);
    if (images.isNotEmpty) {
      _logger.fine('ProductMapper: Fallback на первое изображение из JSON: URI=${images.first.uri}, WebP=${images.first.webp}');
      return images.first;
    }
    
    _logger.fine('ProductMapper: Не найдено ни одного изображения для продукта ${data.catalogId}');
    return null;
  }
  
  static List<String> _parseBarcodesFromData(ProductData data) {
    if (data.barcodesJson == null || data.barcodesJson!.isEmpty) return [];
    
    try {
      final barcodesJsonList = jsonDecode(data.barcodesJson!) as List<dynamic>;
      return barcodesJsonList.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  static ProductsCompanion toCompanion(Product product, {bool excludeId = false}) {
    return ProductsCompanion(
      id: excludeId ? const Value.absent() : const Value.absent(), // ID всегда автогенерируемый
      catalogId: Value(product.catalogId),
      code: Value(product.code),
      bcode: Value(product.bcode),
      title: Value(product.title),
      description: Value(product.description),
      vendorCode: Value(product.vendorCode),
      amountInPackage: Value(product.amountInPackage),
      novelty: Value(product.novelty),
      popular: Value(product.popular),
      isMarked: Value(product.isMarked),
      canBuy: Value(product.canBuy),
      categoryId: Value(product.category?.id),
      typeId: Value(product.type?.id),
      priceListCategoryId: Value(product.priceListCategoryId),
      defaultImageJson: Value(product.defaultImage != null ? jsonEncode(product.defaultImage!.toJson()) : null),
      imagesJson: Value(jsonEncode(product.images.map((img) => img.toJson()).toList())),
      barcodesJson: Value(jsonEncode(product.barcodes)),
      howToUse: Value(product.howToUse),
      ingredients: Value(product.ingredients),
      rawJson: Value(jsonEncode(product.toJson())), // Только для отладки
      createdAt: const Value.absent(), // Будет установлено автоматически
      updatedAt: Value(DateTime.now()),
    );
  }

  static ProductsCompanion toUpdateCompanion(Product product) {
    return ProductsCompanion(
      title: Value(product.title),
      description: Value(product.description),
      vendorCode: Value(product.vendorCode),
      amountInPackage: Value(product.amountInPackage),
      novelty: Value(product.novelty),
      popular: Value(product.popular),
      isMarked: Value(product.isMarked),
      canBuy: Value(product.canBuy),
      categoryId: Value(product.category?.id),
      typeId: Value(product.type?.id),
      priceListCategoryId: Value(product.priceListCategoryId),
      defaultImageJson: Value(product.defaultImage != null ? jsonEncode(product.defaultImage!.toJson()) : null),
      imagesJson: Value(jsonEncode(product.images.map((img) => img.toJson()).toList())),
      barcodesJson: Value(jsonEncode(product.barcodes)),
      howToUse: Value(product.howToUse),
      ingredients: Value(product.ingredients),
      rawJson: Value(jsonEncode(product.toJson())), // Только для отладки
      updatedAt: Value(DateTime.now()),
    );
  }

  static ProductsCompanion toStatusUpdateCompanion({
    bool? novelty,
    bool? popular,
    bool? canBuy,
  }) {
    return ProductsCompanion(
      novelty: novelty != null ? Value(novelty) : const Value.absent(),
      popular: popular != null ? Value(popular) : const Value.absent(),
      canBuy: canBuy != null ? Value(canBuy) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }

  static List<Product> fromDataList(List<ProductData> dataList) {
    return dataList.map(fromData).toList();
  }

  static List<ProductsCompanion> toCompanionList(List<Product> products) {
    return products.map(toCompanion).toList();
  }

  static ProductSearchInfo extractSearchInfo(ProductData data) {
    return ProductSearchInfo(
      id: data.id,
      catalogId: data.catalogId,
      code: data.code,
      title: data.title,
      description: data.description,
      vendorCode: data.vendorCode,
      categoryId: data.categoryId,
      novelty: data.novelty,
      popular: data.popular,
      canBuy: data.canBuy,
    );
  }
}

/// Облегченная модель для поиска без полного парсинга JSON
class ProductSearchInfo {
  final int id;
  final int catalogId;
  final int code;
  final String title;
  final String? description;
  final String? vendorCode;
  final int? categoryId;
  final bool novelty;
  final bool popular;
  final bool canBuy;

  ProductSearchInfo({
    required this.id,
    required this.catalogId,
    required this.code,
    required this.title,
    this.description,
    this.vendorCode,
    this.categoryId,
    required this.novelty,
    required this.popular,
    required this.canBuy,
  });
}