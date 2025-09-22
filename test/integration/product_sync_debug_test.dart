 // test/integration/product_sync_debug_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';

void main() {
  group('Product Sync Debug Tests', () {
    late ProductParsingService service;

    setUp(() {
      service = ProductParsingService();
    });

    test('Debug: Parse real API response structure', () {
      // Имитируем структуру которая может приходить с API
      const mockApiResponse = '''
      {
        "data": [
          {
            "code": 187621,
            "title": "Test Product 187621",
            "barcodes": ["123456"],
            "bcode": 110142,
            "catalogId": 110142,
            "novelty": false,
            "popular": true,
            "isMarked": false,
            "canBuy": true,
            "stockItems": []
          }
        ],
        "totalCount": 1
      }
      ''';

      // Act
      final apiResponse = service.parseProductApiResponse(mockApiResponse);
      
      final apiItem = apiResponse.products.first;
      
      // Конвертируем используя тот же метод что в isolate
      final result = service.convertApiItemToProduct(apiItem, null);
      
      // Assert
      expect(result.product.code, 187621);
      expect(result.stockItems.length, 0); // Если API не возвращает stockItems
    });

    test('Debug: Parse API response with stockItems', () {
      const mockApiResponseWithStock = '''
      {
        "data": [
          {
            "code": 187621,
            "title": "Test Product with Stock",
            "barcodes": ["123456"],
            "bcode": 110142,
            "catalogId": 110142,
            "novelty": false,
            "popular": true,
            "isMarked": false,
            "canBuy": true,
            "stockItems": [
              {
                "warehouseId": 1,
                "warehouseName": "Test Warehouse",
                "price": 100.50,
                "stock": 25,
                "reserved": 0
              }
            ]
          }
        ],
        "totalCount": 1
      }
      ''';

      // Act
      final apiResponse = service.parseProductApiResponse(mockApiResponseWithStock);
      final result = service.convertApiItemToProduct(apiResponse.products.first, null);

      
      // Assert
      expect(result.stockItems.length, 1);
      expect(result.stockItems.first.stock, 25);
    });
  });
}