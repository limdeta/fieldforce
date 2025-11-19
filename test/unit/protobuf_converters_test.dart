import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/data/sync/models/product_protobuf_converter.dart';
import 'package:fieldforce/features/shop/data/sync/models/stock_item_protobuf_converter.dart';
import 'package:fieldforce/features/shop/data/sync/generated/product.pb.dart' as pb;
import 'package:fieldforce/features/shop/data/sync/generated/stockitem.pb.dart' as stock_pb;

void main() {
  group('Protobuf Converters', () {
    test('ProductProtobufConverter преобразует protobuf Product в domain Product', () {
      // Arrange
      final pbProduct = pb.Product(
        code: 12345,
        bcode: 67890,
        title: 'Тестовый продукт',
        vendorCode: 'TEST001',
        barcodes: ['1234567890123'],
        isMarked: true,
        novelty: true,
        popular: false,
        catalogId: 555,
        priceListCategoryId: 100,
        canBuy: true,
        description: 'Описание тестового продукта',
      );

      // Act
      final domainProduct = ProductProtobufConverter.fromProtobuf(pbProduct);

      // Assert
      expect(domainProduct.title, equals('Тестовый продукт'));
      expect(domainProduct.code, equals(12345));
      expect(domainProduct.bcode, equals(67890));
      expect(domainProduct.vendorCode, equals('TEST001'));
      expect(domainProduct.barcodes, contains('1234567890123'));
      expect(domainProduct.isMarked, isTrue);
      expect(domainProduct.novelty, isTrue);
      expect(domainProduct.popular, isFalse);
      expect(domainProduct.catalogId, equals(555));
      expect(domainProduct.priceListCategoryId, equals(100));
      expect(domainProduct.canBuy, isTrue);
      expect(domainProduct.description, equals('Описание тестового продукта'));
    });

    test('ProductProtobufConverter treats missing canBuy flag as purchasable', () {
      // Arrange
      final pbProduct = pb.Product(
        code: 555,
        bcode: 777,
        title: 'Без canBuy',
      );
      expect(pbProduct.hasCanBuy(), isFalse);

      // Act
      final domainProduct = ProductProtobufConverter.fromProtobuf(pbProduct);

      // Assert
      expect(domainProduct.canBuy, isTrue);
    });

    test('StockItemProtobufConverter преобразует protobuf RegionalStockItem в domain StockItem', () {
      // Arrange
      final pbWarehouse = stock_pb.Warehouse(
        id: 1,
        name: 'Центральный склад',
        vendorId: 'vendor123',
        isPickUpPoint: false,
      );

      final pbStockItem = stock_pb.RegionalStockItem(
        id: 555,
        productCode: 12345,
        stock: 9999,
        warehouse: pbWarehouse,
        publicStock: 'available',
        multiplicity: 10,
        regionalBasePrice: 199900, // 1999.00 рублей в копейках
      );

      // Act
      final domainStockItem = StockItemProtobufConverter.fromProtobuf(pbStockItem);

      // Assert
      expect(domainStockItem.id, equals(555));
      expect(domainStockItem.productCode, equals(12345));
      expect(domainStockItem.warehouseId, equals(1));
      expect(domainStockItem.warehouseName, equals('Центральный склад'));
      expect(domainStockItem.warehouseVendorId, equals('vendor123'));
      expect(domainStockItem.isPickUpPoint, isFalse);
      expect(domainStockItem.stock, equals(9999));
      expect(domainStockItem.multiplicity, equals(10));
      expect(domainStockItem.publicStock, equals('available'));
      expect(domainStockItem.defaultPrice, equals(199900));
      expect(domainStockItem.availablePrice, equals(199900));
      expect(domainStockItem.currency, equals('RUB'));
    });

    test('ProductProtobufConverter обрабатывает список продуктов', () {
      // Arrange
      final pbProducts = [
        pb.Product(code: 1, title: 'Продукт 1', priceListCategoryId: 10, canBuy: true),
        pb.Product(code: 2, title: 'Продукт 2', priceListCategoryId: 20, canBuy: false),
      ];

      // Act
      final domainProducts = ProductProtobufConverter.fromProtobufList(pbProducts);

      // Assert
      expect(domainProducts, hasLength(2));
      expect(domainProducts.first.title, equals('Продукт 1'));
      expect(domainProducts.first.code, equals(1));
      expect(domainProducts.first.canBuy, isTrue);
      expect(domainProducts.last.title, equals('Продукт 2'));
      expect(domainProducts.last.code, equals(2));
      expect(domainProducts.last.canBuy, isFalse);
    });

    test('StockItemProtobufConverter сохраняет numeric stock независимо от publicStock', () {
      final cases = [
        {'label': 'available', 'stock': 9999},
        {'label': 'limited', 'stock': 5},
        {'label': '42', 'stock': 42},
        {'label': '', 'stock': 0},
        {'label': 'invalid', 'stock': 13},
      ];

      for (final testCase in cases) {
        final stockItem = StockItemProtobufConverter.fromProtobuf(
          stock_pb.RegionalStockItem(
            productCode: 1,
            stock: testCase['stock'] as int,
            publicStock: testCase['label'] as String,
            regionalBasePrice: 1000,
          ),
        );
        expect(stockItem.stock, equals(testCase['stock']));
        expect(stockItem.publicStock, equals(testCase['label']));
      }
    });
  });
}