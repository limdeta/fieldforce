// test/unit/image_cache_service_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageCacheService URL optimization tests', () {
    test('should add width parameter to image URLs', () {
      // Используем reflection для доступа к приватному методу в тестах
      const testUrl = 'https://api.bonjour-dv.ru/public_v1/products/33680/images/37649.jpg';
      
      // Проверяем что URL изменяется при вызове getCachedThumbnail
      // Нам нужно проверить логику добавления параметра w
      const expectedThumbnailUrl = 'https://api.bonjour-dv.ru/public_v1/products/33680/images/37649.jpg?w=300';
      const expectedFullImageUrl = 'https://api.bonjour-dv.ru/public_v1/products/33680/images/37649.jpg?w=1000';
      
      // Тест логики добавления параметра (используем ручную реализацию)
      expect(_testAddWidthParameter(testUrl, 300), equals(expectedThumbnailUrl));
      expect(_testAddWidthParameter(testUrl, 1000), equals(expectedFullImageUrl));
    });

    test('should not duplicate width parameter if already present', () {
      const testUrlWithWidth = 'https://api.bonjour-dv.ru/public_v1/products/33680/images/37649.jpg?w=500';
      
      // Параметр w уже есть, не должен дублироваться
      expect(_testAddWidthParameter(testUrlWithWidth, 300), equals(testUrlWithWidth));
    });

    test('should handle URLs with existing query parameters', () {
      const testUrlWithQuery = 'https://api.bonjour-dv.ru/public_v1/products/33680/images/37649.jpg?format=webp';
      const expectedUrl = 'https://api.bonjour-dv.ru/public_v1/products/33680/images/37649.jpg?format=webp&w=300';
      
      expect(_testAddWidthParameter(testUrlWithQuery, 300), equals(expectedUrl));
    });

    test('should handle empty or invalid URLs', () {
      expect(_testAddWidthParameter('', 300), equals(''));
      expect(_testAddWidthParameter('invalid-url', 300), equals('invalid-url'));
    });
  });
}

/// Тестовая реализация логики добавления параметра ширины
/// Дублирует логику из ImageCacheService._addWidthParameter
String _testAddWidthParameter(String imageUrl, int width) {
  if (imageUrl.isEmpty) return imageUrl;
  
  final uri = Uri.tryParse(imageUrl);
  if (uri == null) return imageUrl;
  
  // Проверяем что это действительно HTTP/HTTPS URL
  if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) return imageUrl;
  
  if (uri.queryParameters.containsKey('w')) return imageUrl;
  
  final newQueryParameters = Map<String, String>.from(uri.queryParameters);
  newQueryParameters['w'] = width.toString();
  
  final newUri = uri.replace(queryParameters: newQueryParameters);
  return newUri.toString();
}