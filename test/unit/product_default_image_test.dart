// test/unit/product_default_image_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/app/database/mappers/product_mapper.dart';
import 'dart:convert';

void main() {

  group('Product defaultImage mapping tests', () {
    test('should correctly store and retrieve defaultImage in defaultImageJson', () {
      // Создаем тестовый продукт с defaultImage
      final product = Product(
        catalogId: 123,
        code: 456,
        bcode: 789,
        title: 'Test Product',
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
          uri: 'https://example.com/image.jpg',
          webp: 'https://example.com/image.webp',
        ),
        images: [],
        barcodes: [],
        howToUse: null,
        ingredients: null,
        brand: null,
        manufacturer: null,
        colorImage: null,
        series: null,
        category: null,
        type: null,
        priceListCategoryId: null,
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
      );

      // Конвертируем в Companion для сохранения в БД
      final companion = ProductMapper.toCompanion(product);
      
      // Проверяем что defaultImageJson содержит правильные данные
      expect(companion.defaultImageJson.present, isTrue);
      
      final defaultImageJsonString = companion.defaultImageJson.value!;
      final defaultImageData = jsonDecode(defaultImageJsonString) as Map<String, dynamic>;
      
      expect(defaultImageData['id'], equals(1));
      expect(defaultImageData['height'], equals(800));
      expect(defaultImageData['width'], equals(600));
      expect(defaultImageData['uri'], equals('https://example.com/image.jpg'));
      expect(defaultImageData['webp'], equals('https://example.com/image.webp'));
    });

    test('should handle null defaultImage correctly', () {
      // Создаем тестовый продукт без defaultImage
      final product = Product(
        catalogId: 123,
        code: 456,
        bcode: 789,
        title: 'Test Product',
        description: 'Test Description',
        vendorCode: 'TEST001',
        amountInPackage: 1,
        novelty: false,
        popular: false,
        isMarked: false,
        canBuy: true,
        defaultImage: null, // Нет defaultImage
        images: [],
        barcodes: [],
        howToUse: null,
        ingredients: null,
        brand: null,
        manufacturer: null,
        colorImage: null,
        series: null,
        category: null,
        type: null,
        priceListCategoryId: null,
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
      );

      // Конвертируем в Companion для сохранения в БД
      final companion = ProductMapper.toCompanion(product);
      
      // Проверяем что defaultImageJson равен null
      expect(companion.defaultImageJson.present, isTrue);
      expect(companion.defaultImageJson.value, isNull);
    });
  });
}