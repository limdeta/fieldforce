import 'dart:convert';

import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductParsingService', () {
    test('captures vendorId when converting StockItem', () {
      final apiResponse = {
        'data': [
          {
            'code': 11,
            'title': 'Sample',
            'barcodes': [],
            'bcode': 11,
            'catalogId': 11,
            'novelty': false,
            'popular': false,
            'isMarked': false,
            'canBuy': true,
            'images': [],
            'numericCharacteristics': [],
            'stringCharacteristics': [],
            'boolCharacteristics': [],
            'stockItems': [
              {
                'warehouse': {
                  'id': 1,
                  'name': 'Main',
                  'vendorId': '010000031',
                },
                'price': 1234,
                'stock': 5,
              }
            ],
          }
        ],
      };

      final parsingService = ProductParsingService();
      final response = parsingService.parseProductApiResponse(jsonEncode(apiResponse));
      final first = response.products.first;
      final result = parsingService.convertApiItemToProduct(first, null);

      expect(result.stockItems, hasLength(1));
      expect(result.stockItems.first.warehouseVendorId, equals('010000031'));
    });
  });
}
