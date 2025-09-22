// test/unit/product_fixture_parsing_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';

void main() {
  group('Product Fixture Parsing Tests', () {
    test('should correctly parse product_example.json and maintain image URLs', () async {
      // Загружаем реальную фикстуру
      final fixtureJson = await rootBundle.loadString('assets/fixtures/product_example.json');
      
      // Парсим через ProductParsingService
      final parsingService = ProductParsingService();
      final parsedProduct = parsingService.parseProduct(fixtureJson);
  
      // Проверяем что URL-адреса сохранились
      expect(parsedProduct.defaultImage, isNotNull);
      expect(parsedProduct.defaultImage!.uri, isNotEmpty);
      expect(parsedProduct.defaultImage!.webp, isNotEmpty);
      expect(parsedProduct.defaultImage!.uri, contains('https://api.bonjour-dv.ru'));
      
      expect(parsedProduct.images, isNotEmpty);
      expect(parsedProduct.images.first.uri, isNotEmpty);
      expect(parsedProduct.images.first.webp, isNotEmpty);
      expect(parsedProduct.images.first.uri, contains('https://api.bonjour-dv.ru'));
    });
  });
}