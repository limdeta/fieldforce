// lib/app/database/repositories/product_repository_drift.dart

import 'dart:convert';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/mappers/product_mapper.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

class DriftProductRepository implements ProductRepository {
  final AppDatabase _database = GetIt.instance<AppDatabase>();
  final WarehouseFilterService _warehouseFilterService = GetIt.instance<WarehouseFilterService>();
  
  static final Logger _logger = Logger('DriftProductRepository');

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final entities = await _database.select(_database.products).get();
      final products = ProductMapper.fromDataList(entities);

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продуктов: $e'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(int id) async {
    try {
      final entity = await (_database.select(_database.products)
        ..where((tbl) => tbl.id.equals(id))
      ).getSingleOrNull();

      if (entity == null) return const Right(null);

      final product = ProductMapper.fromData(entity);
      return Right(product);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продукта: $e'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductByCatalogId(int catalogId) async {
    try {
      final entity = await (_database.select(_database.products)
        ..where((tbl) => tbl.catalogId.equals(catalogId))
      ).getSingleOrNull();

      if (entity == null) return const Right(null);

      final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);
      return Right(product);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продукта: $e'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductByCode(int code) async {
    try {
      final entity = await (_database.select(_database.products)
        ..where((tbl) => tbl.code.equals(code))
      ).getSingleOrNull();

      if (entity == null) return const Right(null);

      final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);
      return Right(product);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продукта по коду: $e'));
    }
  }

  @override
  Future<Either<Failure, ProductWithStock?>> getProductWithStockByCode(int code, String vendorId) async {
    try {
      // Выполняем JOIN между products и stock_items по коду товара
      final query = _database.select(_database.products).join([
        leftOuterJoin(
          _database.stockItems, 
          _database.stockItems.productCode.equalsExp(_database.products.code) &
          _database.stockItems.warehouseVendorId.equals(vendorId)
        )
      ])..where(_database.products.code.equals(code));

      final results = await query.get();
      
      if (results.isEmpty) return const Right(null);

      final productEntity = results.first.readTable(_database.products);
      final productJson = jsonDecode(productEntity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);

      // Собираем все StockItem для этого товара
      final stockItems = results
          .map((row) => row.readTableOrNull(_database.stockItems))
          .where((item) => item != null)
          .cast<StockItemData>()
          .toList();

      // Вычисляем складские данные
      final totalStock = stockItems.fold<int>(0, (sum, item) => sum + item.stock);
      final prices = stockItems
          .where((item) => item.defaultPrice > 0)
          .map((item) => item.defaultPrice.toDouble())
          .toList();
      final hasDiscounts = stockItems.any((item) => 
          item.offerPrice != null && item.offerPrice! > 0 && item.offerPrice! < item.defaultPrice);

      final productWithStock = ProductWithStock(
        product: product,
        totalStock: totalStock,
        maxPrice: prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b).toInt() : 0,
        minPrice: prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b).toInt() : 0,
        hasDiscounts: hasDiscounts,
      );

      return Right(productWithStock);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения товара со складскими данными: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategoryPaginated(int categoryId, {int offset = 0, int limit = 20}) async {
    try {
      // Получаем все категории в иерархии (родитель + все потомки)
      final categoryRepository = GetIt.instance<CategoryRepository>();
      final descendantsResult = await categoryRepository.getAllDescendants(categoryId);
      final ancestorsResult = await categoryRepository.getAllAncestors(categoryId);

      if (descendantsResult.isLeft() || ancestorsResult.isLeft()) {
        return Left(DatabaseFailure('Ошибка получения иерархии категорий'));
      }

      final descendants = descendantsResult.getOrElse(() => []);
      final ancestors = ancestorsResult.getOrElse(() => []);

      // Создаем множество всех релевантных ID категорий
      final relevantCategoryIds = {categoryId};
      relevantCategoryIds.addAll(descendants.map((c) => c.id));
      relevantCategoryIds.addAll(ancestors.map((c) => c.id));

      // Сначала ищем по точному совпадению categoryId
      final relevantCategoryIdList = relevantCategoryIds.toList();

      _logger.fine('📚 Поиск прямых совпадений по категориям: $relevantCategoryIdList');

      final directMatchesQuery = _database.select(_database.products);

      if (relevantCategoryIdList.isNotEmpty) {
        directMatchesQuery.where(
          (tbl) => tbl.categoryId.isIn(relevantCategoryIdList),
        );
      } else {
        // Защитный сценарий — fallback на исходное поведение
        directMatchesQuery.where((tbl) => tbl.categoryId.equals(categoryId));
      }

      final directMatches = await directMatchesQuery.get();

      // Затем ищем продукты, у которых categoryId есть в массиве categoriesInstock
      final allEntities = await _database.select(_database.products).get();
      final instockMatches = <ProductData>[];

      for (final entity in allEntities) {
        try {
          final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
          final categoriesInstock = productJson['categoriesInstock'] as List<dynamic>?;

          if (categoriesInstock != null) {
            final hasRelevantCategory = categoriesInstock.any((cat) {
              final catMap = cat as Map<String, dynamic>;
              final catId = catMap['id'] as int;
              return relevantCategoryIds.contains(catId);
            });

            if (hasRelevantCategory && !directMatches.contains(entity)) {
              instockMatches.add(entity);
            }
          }
        } catch (e) {
          // Игнорируем ошибки парсинга отдельных продуктов
          // TODO вывести эти ошибки в отдельный лог
          continue;
        }
      }

      final allMatches = [...directMatches, ...instockMatches];

      final paginatedEntities = allMatches.skip(offset).take(limit).toList();

      final products = paginatedEntities.map((entity) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        final product = Product.fromJson(productJson);
        return product;
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продуктов по категории с пагинацией: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductWithStock>>> getProductsWithStockByCategoryPaginated(
    int categoryId, {
    String? vendorId,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      _logger.info('🚀 getProductsWithStockByCategoryPaginated: categoryId=$categoryId, vendorId=${vendorId ?? 'ALL'}, offset=$offset, limit=$limit');
      
      // Получаем иерархию категорий как в обычном методе
      final categoryRepository = GetIt.instance<CategoryRepository>();
      final descendantsResult = await categoryRepository.getAllDescendants(categoryId);
      final ancestorsResult = await categoryRepository.getAllAncestors(categoryId);

      if (descendantsResult.isLeft() || ancestorsResult.isLeft()) {
        return Left(DatabaseFailure('Ошибка получения иерархии категорий'));
      }

      final descendants = descendantsResult.getOrElse(() => []);
      final ancestors = ancestorsResult.getOrElse(() => []);
      final relevantCategoryIds = {categoryId};
      relevantCategoryIds.addAll(descendants.map((c) => c.id));
      relevantCategoryIds.addAll(ancestors.map((c) => c.id));

      _logger.info('Relevant category IDs: $relevantCategoryIds');
      _logger.info('  - Descendants: ${descendants.map((c) => '${c.id}:${c.name}').join(', ')}');
      _logger.info('  - Ancestors: ${ancestors.map((c) => '${c.id}:${c.name}').join(', ')}');
      
      final directMatches = await (_database.select(_database.products)
        ..where((tbl) => tbl.categoryId.equals(categoryId))
      ).get();

      _logger.info('🔍 Прямые совпадения по categoryId=$categoryId: ${directMatches.length} продуктов');
      
      final allProductEntities = await (_database.select(_database.products)).get();
      
      _logger.info('🔍 Всего продуктов в БД: ${allProductEntities.length}');
      
      final matchingProductsMap = <int, ProductData>{};

      for (final entity in directMatches) {
        matchingProductsMap[entity.code] = entity;
      }
      
      for (final productEntity in allProductEntities) {
        try {
          final productJson = jsonDecode(productEntity.rawJson) as Map<String, dynamic>;
          final categoriesInstock = productJson['categoriesInstock'] as List<dynamic>? ?? [];
          
          // Проверяем есть ли пересечение с нужными категориями
          final productCategoryIds = categoriesInstock
              .cast<Map<String, dynamic>>()
              .map((cat) => cat['id'] as int?)
              .where((id) => id != null)
              .cast<int>()
              .toSet();
          
          if (productCategoryIds.intersection(relevantCategoryIds).isNotEmpty) {
            matchingProductsMap[productEntity.code] = productEntity;
            _logger.fine('🔍 Продукт ${productEntity.code} найден через categoriesInstock: ${productCategoryIds.intersection(relevantCategoryIds)}');
          }
        } catch (e) {
          _logger.warning('Ошибка парсинга categoriesInstock для продукта ${productEntity.code}: $e');
        }
      }

      final matchingProducts = matchingProductsMap.values.toList();
  _logger.info('🔍 Продукты в категориях $relevantCategoryIds: ${matchingProducts.length} найдено');

      if (matchingProducts.isNotEmpty) {
        final sampleProducts = matchingProducts.take(3).map((p) => 'code=${p.code}, title=${p.title}').join('; ');
        _logger.info('🔍 Примеры продуктов: $sampleProducts');
      }

      if (matchingProducts.isEmpty) {
        _logger.info('✅ Возвращаем 0 ProductWithStock для категории $categoryId (нет продуктов)');
        return Right([]);
      }

      final sortedProducts = List<ProductData>.from(matchingProducts)
        ..sort((a, b) => a.title.compareTo(b.title));

      if (sortedProducts.isEmpty) {
        _logger.info('✅ После сортировки нет продуктов для категории $categoryId');
        return Right([]);
      }

      final productCodes = sortedProducts.map((p) => p.code).toList();

  final filterResult = await _warehouseFilterService.resolveForCurrentSession(bypassInDev: false);
      List<int>? allowedWarehouseIds;

      if (filterResult.devBypass) {
        _logger.fine('getProductsWithStockByCategoryPaginated: dev режим — пропускаем фильтрацию складов');
      } else if (filterResult.failure != null) {
        _logger.warning(
          'getProductsWithStockByCategoryPaginated: ошибка фильтра складов: ${filterResult.failure!.message}. Продолжаем без фильтрации.',
        );
      } else if (!filterResult.hasWarehouses) {
        _logger.warning(
          'getProductsWithStockByCategoryPaginated: для региона ${filterResult.regionCode} не найдено складов. Возвращаем пустой список.',
        );
        return Right([]);
      } else {
        final warehouses = filterResult.warehouseIds;
        allowedWarehouseIds = warehouses;
        _logger.fine('Применяем фильтр по складам (${warehouses.length}) для региона ${filterResult.regionCode}');
      }

      final stockQuery = _database.select(_database.stockItems)
        ..where((tbl) => tbl.productCode.isIn(productCodes))
        ..where((tbl) => tbl.stock.isBiggerThanValue(0));

      if (vendorId != null) {
        stockQuery.where((tbl) => tbl.warehouseVendorId.equals(vendorId));
      }

      if (allowedWarehouseIds != null) {
        stockQuery.where((tbl) => tbl.warehouseId.isIn(allowedWarehouseIds!));
      }

      final stockEntities = await stockQuery.get();
      _logger.info('� Найдено ${stockEntities.length} stock_items (stock>0) для выбранных продуктов (vendor=${vendorId ?? 'ALL'})');

      final stockByProduct = <int, List<StockItemData>>{};
      for (final entity in stockEntities) {
        stockByProduct.putIfAbsent(entity.productCode, () => []).add(entity);
      }

    final availableProducts = sortedProducts
        .where((product) => (stockByProduct[product.code]?.isNotEmpty ?? false))
        .toList();

      _logger.info('🔍 После фильтрации по остаткам: ${availableProducts.length} из ${sortedProducts.length} продуктов');

      if (availableProducts.isEmpty) {
        _logger.info('✅ Возвращаем 0 ProductWithStock для категории $categoryId (нет продуктов с остатками)');
        return Right([]);
      }

      final paginatedAvailableProducts = availableProducts.skip(offset).take(limit).toList();
      _logger.info('🔍 После пагинации: ${paginatedAvailableProducts.length} продуктов (offset=$offset, limit=$limit)');

      if (paginatedAvailableProducts.isEmpty) {
        _logger.info('✅ Возвращаем 0 ProductWithStock для категории $categoryId (пагинация)');
        return Right([]);
      }

      final productWithStockList = <ProductWithStock>[];

      for (final productEntity in paginatedAvailableProducts) {
        final productJson = jsonDecode(productEntity.rawJson) as Map<String, dynamic>;
        final product = Product.fromJson(productJson);
        final stockItems = stockByProduct[productEntity.code] ?? <StockItemData>[];

        if (stockItems.isEmpty) {
          _logger.fine('Пропускаем продукт ${productEntity.code} — нет доступных stockItems после фильтрации');
          continue;
        }

        final totalStock = stockItems.fold<int>(0, (sum, item) => sum + item.stock);
        final prices = stockItems
            .map((item) => item.defaultPrice)
            .where((price) => price > 0)
            .toList();
        final hasDiscounts = stockItems.any((item) =>
            item.offerPrice != null && item.offerPrice! > 0 && item.offerPrice! < item.defaultPrice);

        final minPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
        final maxPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a > b ? a : b);

        productWithStockList.add(ProductWithStock(
          product: product,
          totalStock: totalStock,
          maxPrice: maxPrice,
          minPrice: minPrice,
          hasDiscounts: hasDiscounts,
        ));
      }

      _logger.info('✅ Возвращаем ${productWithStockList.length} ProductWithStock с остатками для категории $categoryId');
      return Right(productWithStockList);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продуктов с остатками: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByTypePaginated(int typeId, {int offset = 0, int limit = 20}) async {
    try {
      final entities = await (_database.select(_database.products)
        ..where((tbl) => tbl.typeId.equals(typeId))
        ..limit(limit, offset: offset)
      ).get();

      final products = entities.map((entity) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Product.fromJson(productJson);
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продуктов по типу с пагинацией: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProductsPaginated(String query, {int offset = 0, int limit = 20}) async {
    try {
      final entities = await (_database.select(_database.products)
        ..where((tbl) => tbl.title.contains(query))
        ..limit(limit, offset: offset)
      ).get();

      final products = entities.map((entity) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Product.fromJson(productJson);
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка поиска продуктов с пагинацией: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProducts(List<Product> products) async {
    try {
      await _database.transaction(() async {
        for (final product in products) {
          await _saveProduct(product);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка сохранения продуктов: $e'));
    }
  }

  Future<void> _saveProduct(Product product) async {
    final existing = await (_database.select(_database.products)
      ..where((tbl) => tbl.code.equals(product.code))
    ).getSingleOrNull();

    final companion = ProductMapper.toCompanion(product);

    if (existing != null) {
      // Обновляем существующий продукт
      await (_database.update(_database.products)
        ..where((tbl) => tbl.code.equals(product.code))
      ).write(companion);
    } else {
      // Создаем новый продукт
      await _database.into(_database.products).insert(companion);
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final companion = ProductsCompanion(
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
        rawJson: Value(jsonEncode(product.toJson())),
      );

      await (_database.update(_database.products)
        ..where((tbl) => tbl.code.equals(product.code))
      ).write(companion);

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка обновления продукта: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int code) async {
    try {
      await (_database.delete(_database.products)
        ..where((tbl) => tbl.code.equals(code))
      ).go();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка удаления продукта: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllProducts() async {
    try {
      await _database.delete(_database.products).go();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка удаления всех продуктов: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsWithPromotions() async {
    try {
      final entities = await _database.select(_database.products).get();

      final products = entities.map((entity) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Product.fromJson(productJson);
      }).toList();
      // TODO: Фильтровать по акциям из отдельной таблицы StockItem

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения продуктов с акциями: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getPopularProducts() async {
    try {
      final entities = await (_database.select(_database.products)
        ..where((tbl) => tbl.popular.equals(true))
      ).get();

      final products = entities.map((entity) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Product.fromJson(productJson);
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения популярных продуктов: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getNoveltyProducts() async {
    try {
      final entities = await (_database.select(_database.products)
        ..where((tbl) => tbl.novelty.equals(true))
      ).get();

      final products = entities.map((entity) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Product.fromJson(productJson);
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения новинок: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getProductsCount() async {
    try {
      final count = _database.selectOnly(_database.products)
        ..addColumns([_database.products.id.count()]);
      final result = await count.map((row) => row.read(_database.products.id.count())).getSingle();
      return Right(result ?? 0);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения количества продуктов: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getProductsCountByCategory(int categoryId) async {
    try {

      // Считаем прямые совпадения
      final directCount = await (_database.selectOnly(_database.products)
        ..addColumns([_database.products.id.count()])
        ..where(_database.products.categoryId.equals(categoryId))
      ).map((row) => row.read(_database.products.id.count())).getSingle();

      // Считаем совпадения в categoriesInstock
      final allEntities = await _database.select(_database.products).get();
      int instockCount = 0;

      for (final entity in allEntities) {
        try {
          final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
          final categoriesInstock = productJson['categoriesInstock'] as List<dynamic>?;

          if (categoriesInstock != null) {
            final hasCategory = categoriesInstock.any((cat) {
              final catMap = cat as Map<String, dynamic>;
              return catMap['id'] == categoryId;
            });

            if (hasCategory && entity.categoryId != categoryId) {
              instockCount++;
            }
          }
        } catch (e) {
          // Игнорируем ошибки парсинга отдельных продуктов
          continue;
        }
      }


      final totalCount = (directCount ?? 0) + instockCount;

      return Right(totalCount);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения количества продуктов в категории: $e'));
    }
  }
}