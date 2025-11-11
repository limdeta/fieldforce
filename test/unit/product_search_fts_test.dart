// test/unit/product_search_fts_test.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/product_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/warehouse_repository_drift.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

void main() {
  late AppDatabase database;
  late ProductRepository repository;
  final getIt = GetIt.instance;

  setUp(() async {
    // Включаем логирование для отладки
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });

    // Создаём in-memory базу данных для тестов
    database = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    
    // Регистрируем зависимости для теста
    await getIt.reset();
    getIt.registerSingleton<AppDatabase>(database);
    getIt.registerLazySingleton<WarehouseRepository>(
      () => DriftWarehouseRepository(),
    );
    getIt.registerLazySingleton(
      () => WarehouseFilterService(
        warehouseRepository: getIt(),
      ),
    );
    getIt.registerLazySingleton<ProductRepository>(
      () => DriftProductRepository(),
    );
    
    repository = getIt<ProductRepository>();
  });

  tearDown(() async {
    await database.close();
  });

  group('FTS5 полнотекстовый поиск продуктов', () {
    test('Поиск по полному названию', () async {
      // Arrange - создаём тестовые продукты
      final testProducts = [
        Product(
          title: 'Шампунь Head & Shoulders',
          barcodes: ['4607086564738'],
          code: 1001,
          bcode: 1001,
          catalogId: 1001,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
          vendorCode: 'SHA-001',
        ),
        Product(
          title: 'Гель для душа Dove',
          barcodes: ['4607086564745'],
          code: 1002,
          bcode: 1002,
          catalogId: 1002,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
          vendorCode: 'DOV-001',
        ),
        Product(
          title: 'Мыло туалетное Palmolive',
          barcodes: ['4607086564752'],
          code: 1003,
          bcode: 1003,
          catalogId: 1003,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
          vendorCode: 'PAL-001',
        ),
      ];

      await repository.saveProducts(testProducts);

      // Act - поиск по слову "шампунь"
      final result = await repository.searchProductsWithFts('шампунь');

      // Assert
      expect(result.isRight(), true);
      final products = result.getOrElse(() => []);
      expect(products.length, 1);
      expect(products.first.title, contains('Шампунь'));
    });

    test('Поиск по частичному названию (начало)', () async {
      // Arrange
      final testProduct = Product(
        title: 'Дезодорант Rexona',
        barcodes: [],
        code: 2001,
        bcode: 2001,
        catalogId: 2001,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      await repository.saveProducts([testProduct]);

      // Act - поиск по началу слова "дезод"
      final result = await repository.searchProductsWithFts('дезод');

      // Assert
      expect(result.isRight(), true);
      final products = result.getOrElse(() => []);
      expect(products.length, 1);
      expect(products.first.title, contains('Дезодорант'));
    });

    test('Поиск по коду продукта (точное совпадение)', () async {
      // Arrange
      final testProduct = Product(
        title: 'Тестовый продукт',
        barcodes: [],
        code: 12345,
        bcode: 12345,
        catalogId: 12345,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      await repository.saveProducts([testProduct]);

      // Act - поиск по коду
      final result = await repository.searchProductsWithFts('12345');

      // Assert
      expect(result.isRight(), true);
      final products = result.getOrElse(() => []);
      expect(products.length, 1);
      expect(products.first.code, 12345);
    });

    test('Поиск по штрихкоду (barcode)', () async {
      // Arrange
      final testProduct = Product(
        title: 'Продукт со штрихкодом',
        barcodes: ['9876543210123', '1234567890123'],
        code: 3001,
        bcode: 3001,
        catalogId: 3001,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      await repository.saveProducts([testProduct]);

      // Act - поиск по штрихкоду
      final result = await repository.searchProductsWithFts('9876543210123');

      // Assert
      expect(result.isRight(), true);
      final products = result.getOrElse(() => []);
      expect(products.length, 1);
      expect(products.first.barcodes, contains('9876543210123'));
    });

    test('Поиск по артикулу (vendorCode)', () async {
      // Arrange
      final testProduct = Product(
        title: 'Продукт с артикулом',
        barcodes: [],
        code: 4001,
        bcode: 4001,
        catalogId: 4001,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
        vendorCode: 'ART-XYZ-789',
      );

      await repository.saveProducts([testProduct]);

      // Act - поиск по артикулу
      final result = await repository.searchProductsWithFts('ART-XYZ');

      // Assert
      expect(result.isRight(), true);
      final products = result.getOrElse(() => []);
      expect(products.length, 1);
      expect(products.first.vendorCode, 'ART-XYZ-789');
    });

    test('Ранжирование: точное совпадение code выше чем title', () async {
      // Arrange
      final products = [
        Product(
          title: 'Продукт 5000 мл',
          barcodes: [],
          code: 9999,
          bcode: 9999,
          catalogId: 9999,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
        ),
        Product(
          title: 'Другой продукт',
          barcodes: [],
          code: 5000,
          bcode: 5000,
          catalogId: 5000,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
        ),
      ];

      await repository.saveProducts(products);

      // Act - поиск по "5000"
      final result = await repository.searchProductsWithFts('5000');

      // Assert
      expect(result.isRight(), true);
      final found = result.getOrElse(() => []);
      expect(found.length, 2);
      // Первым должен быть продукт с code=5000 (приоритет 1000)
      expect(found.first.code, 5000);
      // Вторым - продукт где "5000" в title (приоритет 50)
      expect(found.last.code, 9999);
    });

    test('Пустой запрос возвращает пустой список', () async {
      // Arrange
      final testProduct = Product(
        title: 'Любой продукт',
        barcodes: [],
        code: 6001,
        bcode: 6001,
        catalogId: 6001,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      await repository.saveProducts([testProduct]);

      // Act
      final result = await repository.searchProductsWithFts('');

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []).length, 0);
    });

    test('Поиск без результатов', () async {
      // Arrange
      final testProduct = Product(
        title: 'Продукт А',
        barcodes: [],
        code: 7001,
        bcode: 7001,
        catalogId: 7001,
        novelty: false,
        popular: false,
        isMarked: false,
        images: [],
        categoriesInstock: [],
        numericCharacteristics: [],
        stringCharacteristics: [],
        boolCharacteristics: [],
        canBuy: true,
      );

      await repository.saveProducts([testProduct]);

      // Act - поиск несуществующего
      final result = await repository.searchProductsWithFts('зззнесуществует');

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []).length, 0);
    });

    test('Пагинация работает корректно', () async {
      // Arrange - создаём 30 продуктов
      final products = List.generate(
        30,
        (i) => Product(
          title: 'Продукт тест $i',
          barcodes: [],
          code: 8000 + i,
          bcode: 8000 + i,
          catalogId: 8000 + i,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
        ),
      );

      await repository.saveProducts(products);

      // Act - первая страница
      final page1 = await repository.searchProductsWithFts(
        'продукт',
        offset: 0,
        limit: 10,
      );

      // Act - вторая страница
      final page2 = await repository.searchProductsWithFts(
        'продукт',
        offset: 10,
        limit: 10,
      );

      // Assert
      expect(page1.isRight(), true);
      expect(page2.isRight(), true);
      
      final items1 = page1.getOrElse(() => []);
      final items2 = page2.getOrElse(() => []);
      
      expect(items1.length, 10);
      expect(items2.length, 10);
      
      // Проверяем что не пересекаются
      final codes1 = items1.map((p) => p.code).toSet();
      final codes2 = items2.map((p) => p.code).toSet();
      expect(codes1.intersection(codes2).isEmpty, true);
    });

    test('Поиск с фильтрацией по категории', () async {
      // Arrange - создаём продукты с categoriesInstock
      // Category ID 100 и 200 в массиве categoriesInstock Product хранятся как Category объекты
      final category1Products = [
        Product(
          title: 'Шампунь категория 1',
          barcodes: [],
          code: 7001,
          bcode: 7001,
          catalogId: 7001,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [
            Category(id: 100, name: 'Категория 100'),
          ],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
        ),
        Product(
          title: 'Мыло категория 1',
          barcodes: [],
          code: 7002,
          bcode: 7002,
          catalogId: 7002,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [
            Category(id: 100, name: 'Категория 100'),
          ],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
        ),
      ];

      final category2Products = [
        Product(
          title: 'Шампунь категория 2',
          barcodes: [],
          code: 7003,
          bcode: 7003,
          catalogId: 7003,
          novelty: false,
          popular: false,
          isMarked: false,
          images: [],
          categoriesInstock: [
            Category(id: 200, name: 'Категория 200'),
          ],
          numericCharacteristics: [],
          stringCharacteristics: [],
          boolCharacteristics: [],
          canBuy: true,
        ),
      ];

      await repository.saveProducts([...category1Products, ...category2Products]);

      // Act - поиск "шампунь" только в категории 100
      final resultCat100 = await repository.searchProductsWithFts(
        'шампунь',
        categoryIds: [100],
      );

      // Act - поиск "шампунь" только в категории 200
      final resultCat200 = await repository.searchProductsWithFts(
        'шампунь',
        categoryIds: [200],
      );

      // Act - поиск "шампунь" везде (без категории)
      final resultAll = await repository.searchProductsWithFts('шампунь');

      // Assert
      expect(resultCat100.isRight(), true);
      expect(resultCat200.isRight(), true);
      expect(resultAll.isRight(), true);

      final productsCat100 = resultCat100.getOrElse(() => []);
      final productsCat200 = resultCat200.getOrElse(() => []);
      final productsAll = resultAll.getOrElse(() => []);

      // В категории 100 должен быть только один шампунь
      expect(productsCat100.length, 1);
      expect(productsCat100.first.code, 7001);

      // В категории 200 должен быть только один шампунь
      expect(productsCat200.length, 1);
      expect(productsCat200.first.code, 7003);

      // Без фильтра должно быть минимум 2 шампуня (могут быть ещё из других тестов)
      expect(productsAll.length, greaterThanOrEqualTo(2));
    });
  });
}
