import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/product_repository_drift.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query_result.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  late AppDatabase database;
  late DriftProductRepository repository;

  setUp(() async {
    await getIt.reset();
    database = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    getIt.registerSingleton<AppDatabase>(database);
    getIt.registerSingleton<WarehouseFilterService>(
      _WarehouseFilterServiceStub(),
    );

    repository = DriftProductRepository();

    final productJson = {
      'title': 'Test product',
      'barcodes': ['123'],
      'code': 170094,
      'bcode': 170094,
      'catalogId': 110142,
      'novelty': false,
      'popular': false,
      'isMarked': false,
      'canBuy': true,
      'category': {
        'id': 99,
        'name': 'Child',
      },
      'categoriesInstock': [
        {
          'id': 99,
          'name': 'Child',
        }
      ],
      'numericCharacteristics': [],
      'stringCharacteristics': [],
      'boolCharacteristics': [],
      'images': [],
    };

    await database.into(database.products).insert(
      ProductsCompanion(
        catalogId: const Value(110142),
        code: const Value(170094),
        bcode: const Value(170094),
        title: const Value('Test product'),
        description: const Value(null),
        vendorCode: const Value(null),
        amountInPackage: const Value(null),
        novelty: const Value(false),
        popular: const Value(false),
        isMarked: const Value(false),
        canBuy: const Value(true),
        categoryId: const Value(99),
        typeId: const Value(null),
        priceListCategoryId: const Value(null),
        defaultImageJson: const Value(null),
        imagesJson: Value(jsonEncode(const [])),
        barcodesJson: Value(jsonEncode(const ['123'])),
        howToUse: const Value(null),
        ingredients: const Value(null),
        rawJson: Value(jsonEncode(productJson)),
      ),
    );

    await database.into(database.stockItems).insert(
      StockItemsCompanion(
        id: const Value.absent(),
        productCode: const Value(170094),
        warehouseId: const Value(1),
        warehouseName: const Value('WH'),
        warehouseVendorId: const Value('VENDOR-1'),
        isPickUpPoint: const Value(false),
        stock: const Value(10),
        multiplicity: const Value(1),
        publicStock: const Value('10 шт.'),
        defaultPrice: const Value(1000),
        discountValue: const Value(0),
        availablePrice: const Value(1000),
        offerPrice: const Value(900),
        currency: const Value('RUB'),
        promotionJson: const Value(null),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await getIt.reset();
  });

  test('returns products for descendant categories', () async {
    final query = ProductQuery(
      baseCategoryId: 94,
      scopedCategoryIds: const [94, 99],
    );

    final result = await repository.getProducts(query);

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(
      () => ProductQueryResult<ProductWithStock>.empty(query),
    );
    expect(products.items, isNotEmpty);
    expect(products.items.first.product.code, 170094);
  });

  test('filters out products without positive stock', () async {
    final productJson = {
      'title': 'Zero stock product',
      'barcodes': ['456'],
      'code': 170095,
      'bcode': 170095,
      'catalogId': 110143,
      'novelty': false,
      'popular': false,
      'isMarked': false,
      'canBuy': true,
      'category': {
        'id': 99,
        'name': 'Child',
      },
      'categoriesInstock': [
        {
          'id': 99,
          'name': 'Child',
        }
      ],
      'numericCharacteristics': [],
      'stringCharacteristics': [],
      'boolCharacteristics': [],
      'images': [],
    };

    await database.into(database.products).insert(
      ProductsCompanion(
        catalogId: const Value(110143),
        code: const Value(170095),
        bcode: const Value(170095),
        title: const Value('Zero stock product'),
        description: const Value(null),
        vendorCode: const Value(null),
        amountInPackage: const Value(null),
        novelty: const Value(false),
        popular: const Value(false),
        isMarked: const Value(false),
        canBuy: const Value(true),
        categoryId: const Value(99),
        typeId: const Value(null),
        priceListCategoryId: const Value(null),
        defaultImageJson: const Value(null),
        imagesJson: Value(jsonEncode(const [])),
        barcodesJson: Value(jsonEncode(const ['456'])),
        howToUse: const Value(null),
        ingredients: const Value(null),
        rawJson: Value(jsonEncode(productJson)),
      ),
    );

    await database.into(database.stockItems).insert(
      StockItemsCompanion(
        id: const Value.absent(),
        productCode: const Value(170095),
        warehouseId: const Value(2),
        warehouseName: const Value('WH-2'),
        warehouseVendorId: const Value('VENDOR-1'),
        isPickUpPoint: const Value(false),
        stock: const Value(0),
        multiplicity: const Value(1),
        publicStock: const Value('0 шт.'),
        defaultPrice: const Value(1500),
        discountValue: const Value(0),
        availablePrice: const Value(1500),
        offerPrice: const Value(1500),
        currency: const Value('RUB'),
        promotionJson: const Value(null),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final query = ProductQuery(
      baseCategoryId: 94,
      scopedCategoryIds: const [94, 99],
    );

    final result = await repository.getProducts(query);

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(
      () => ProductQueryResult<ProductWithStock>.empty(query),
    );
    expect(products.items, hasLength(1));
    expect(products.items.first.product.code, 170094);
  });

  test('returns empty list for vendor without stock', () async {
    final query = ProductQuery(
      baseCategoryId: 94,
      scopedCategoryIds: const [94, 99],
      allowedProductCodes: const [999999],
    );

    final result = await repository.getProducts(query);

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(
      () => ProductQueryResult<ProductWithStock>.empty(query),
    );
    expect(products.items, isEmpty);
  });

  test('returns products when only allowed codes provided', () async {
    final query = const ProductQuery(
      allowedProductCodes: [170094],
      requireStock: false,
      limit: 20,
      offset: 0,
    );

    final result = await repository.getProducts(query);

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(
      () => ProductQueryResult<ProductWithStock>.empty(query),
    );
    expect(products.items, hasLength(1));
    expect(products.items.first.product.code, 170094);
  });
}

class _WarehouseFilterServiceStub extends WarehouseFilterService {
  _WarehouseFilterServiceStub() : super(warehouseRepository: _FakeWarehouseRepository());

  @override
  Future<WarehouseFilterResult> resolveForCurrentSession({bool bypassInDev = true}) async {
    return WarehouseFilterResult(
      regionCode: 'TEST',
      warehouses: [
        Warehouse(
          id: 1,
          name: 'Test Warehouse',
          vendorId: 'VENDOR-1',
          regionCode: 'TEST',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        ),
      ],
    );
  }
}

class _FakeWarehouseRepository implements WarehouseRepository {
  @override
  Future<Either<Failure, void>> clearWarehouses() async => const Right(null);

  @override
  Future<Either<Failure, void>> clearWarehousesByRegion(String regionCode) async => const Right(null);

  @override
  Future<Either<Failure, List<Warehouse>>> getAllWarehouses() async => const Right(<Warehouse>[]);

  @override
  Future<Either<Failure, Warehouse?>> getWarehouseById(int id) async => const Right(null);

  @override
  Future<Either<Failure, Warehouse?>> getWarehouseByVendorId(String vendorId) async => const Right(null);

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehousesByRegion(String regionCode) async => const Right(<Warehouse>[]);

  @override
  Future<Either<Failure, void>> saveWarehouses(List<Warehouse> warehouses) async => const Right(null);
}
