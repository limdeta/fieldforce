import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/product_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart' as domain;
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeCategoryRepository implements CategoryRepository {
  final Map<int, domain.Category> _categories;
  final Map<int, List<domain.Category>> _descendants;
  final Map<int, List<domain.Category>> _ancestors;

  _FakeCategoryRepository({
    required List<domain.Category> categories,
    Map<int, List<domain.Category>>? descendants,
    Map<int, List<domain.Category>>? ancestors,
  })  : _categories = {for (final c in categories) c.id: c},
        _descendants = descendants ?? const {},
        _ancestors = ancestors ?? const {};

  @override
  Future<Either<Failure, List<domain.Category>>> getAllCategories() async {
    return Right(_categories.values.toList());
  }

  @override
  Future<Either<Failure, domain.Category?>> getCategoryById(int id) async {
    return Right(_categories[id]);
  }

  @override
  Future<Either<Failure, void>> saveCategories(List<domain.Category> categories) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateCategory(domain.Category category) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<domain.Category>>> searchCategories(String query) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<domain.Category>>> getSubcategories(int parentId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<domain.Category>>> getAllDescendants(int categoryId) async {
    return Right(List<domain.Category>.from(_descendants[categoryId] ?? const []));
  }

  @override
  Future<Either<Failure, List<domain.Category>>> getAllAncestors(int categoryId) async {
    return Right(List<domain.Category>.from(_ancestors[categoryId] ?? const []));
  }

  @override
  Future<Either<Failure, void>> updateCategoryCounts() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateCategoryCountsWithCategories(List<domain.Category> categories) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateCategoryCountsForRegion(
    List<domain.Category> categories,
    String regionCode,
  ) async {
    return const Right(null);
  }
}

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

    final childCategory = domain.Category(
      id: 99,
      name: 'Child',
      lft: 0,
      lvl: 2,
      rgt: 0,
      description: null,
      query: null,
      count: 0,
      children: [],
    );
    final parentCategory = domain.Category(
      id: 94,
      name: 'Parent',
      lft: 0,
      lvl: 1,
      rgt: 0,
      description: null,
      query: null,
      count: 0,
      children: [childCategory],
    );

    getIt.registerSingleton<CategoryRepository>(
      _FakeCategoryRepository(
        categories: [parentCategory, childCategory],
        descendants: {
          94: [childCategory],
          99: const [],
        },
        ancestors: {
          99: [parentCategory],
          94: const [],
        },
      ),
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
    final result = await repository.getProductsWithStockByCategoryPaginated(
      94,
      vendorId: 'VENDOR-1',
    );

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(() => []);
    expect(products, isNotEmpty);
    expect(products.first.product.code, 170094);
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

    final result = await repository.getProductsWithStockByCategoryPaginated(94);

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(() => []);
    expect(products, hasLength(1));
    expect(products.first.product.code, 170094);
  });

  test('returns empty list for vendor without stock', () async {
    final result = await repository.getProductsWithStockByCategoryPaginated(
      94,
      vendorId: 'UNKNOWN_VENDOR',
    );

    expect(result.isRight(), isTrue);
    final products = result.getOrElse(() => []);
    expect(products, isEmpty);
  });
}
