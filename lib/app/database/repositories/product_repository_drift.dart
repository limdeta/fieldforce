// lib/app/database/repositories/product_repository_drift.dart

import 'dart:convert';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/mappers/product_mapper.dart';
import 'package:fieldforce/app/database/mappers/product_facet_mapper.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query_result.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
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
  Future<Either<Failure, ProductQueryResult<ProductWithStock>>> getProducts(
    ProductQuery query,
  ) async {
    try {
      if (query.limit <= 0) {
        _logger.fine('ProductQuery с limit<=0 — возвращаем пустой результат');
        return Right(ProductQueryResult<ProductWithStock>.empty(query));
      }

      if (query.allowedProductCodes != null && query.allowedProductCodes!.isEmpty) {
        _logger.fine('ProductQuery ограничен пустым набором allowedProductCodes — пустой результат');
        return Right(ProductQueryResult<ProductWithStock>.empty(query));
      }

      if (query.hasSearchText) {
        return _runSearchQuery(query);
      }

      final scope = _resolveCategoryScope(query);
      final hasAllowedCodes = query.allowedProductCodes != null;
      final filterByCategory = scope.isNotEmpty;

      if (!filterByCategory && !hasAllowedCodes) {
        _logger.fine('ProductQuery без категории и allowedProductCodes — возвращаем пустой результат');
        return Right(ProductQueryResult<ProductWithStock>.empty(query));
      }

      final matchingProducts = await _loadProductsForScope(
        scope,
        query,
        filterByCategory: filterByCategory,
      );
      if (matchingProducts.isEmpty) {
        return Right(ProductQueryResult<ProductWithStock>.empty(query));
      }

      if (query.requireStock) {
        final result = await _buildResultWithStock(matchingProducts, query);
        return Right(result);
      }

      final result = _buildResultWithoutStock(matchingProducts, query);
      return Right(result);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка выполнения ProductQuery: $query', e, stackTrace);
      return Left(DatabaseFailure('Ошибка выполнения ProductQuery: $e'));
    }
  }

  Future<Either<Failure, ProductQueryResult<ProductWithStock>>> _runSearchQuery(
    ProductQuery query,
  ) async {
    final searchResult = await searchProductsWithFts(
      query.searchText ?? '',
      categoryIds: query.scopedCategoryIds.isEmpty ? null : query.scopedCategoryIds,
      offset: _safeOffset(query),
      limit: query.limit,
      allowedProductCodes: query.allowedProductCodes,
    );

    return searchResult.fold(
      (failure) => Left(failure),
      (products) {
        final items = products
            .map(
              (product) => ProductWithStock(
                product: product,
                totalStock: 0,
                maxPrice: 0,
                minPrice: 0,
                hasDiscounts: false,
              ),
            )
            .toList(growable: false);

        final hasMore = products.length == query.limit;

        return Right(
          ProductQueryResult<ProductWithStock>(
            items: items,
            hasMore: hasMore,
            offset: query.offset,
            limit: query.limit,
            appliedQuery: query,
          ),
        );
      },
    );
  }

  Set<int> _resolveCategoryScope(ProductQuery query) {
    if (query.scopedCategoryIds.isNotEmpty) {
      return query.scopedCategoryIds.toSet();
    }
    if (query.baseCategoryId != null) {
      return {query.baseCategoryId!};
    }
    return const <int>{};
  }

  Future<List<ProductData>> _loadProductsForScope(
    Set<int> scopeCategoryIds,
    ProductQuery query, {
    required bool filterByCategory,
  }) async {
    final bool applyCategoryFilter = filterByCategory && scopeCategoryIds.isNotEmpty;
    final allProductEntities = await _database.select(_database.products).get();
    final allowedCodes = query.allowedProductCodes?.toSet();
    final matchingProducts = <int, ProductData>{};

    for (final entity in allProductEntities) {
      if (allowedCodes != null && !allowedCodes.contains(entity.code)) {
        continue;
      }

      try {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        final categoriesInstock =
            productJson['categoriesInstock'] as List<dynamic>? ?? const <dynamic>[];
        final productCategoryIds = categoriesInstock
            .cast<Map<String, dynamic>>()
            .map((cat) => cat['id'] as int?)
            .whereType<int>()
            .toSet();

        if (applyCategoryFilter && productCategoryIds.intersection(scopeCategoryIds).isEmpty) {
          continue;
        }

        matchingProducts[entity.code] = entity;
      } catch (error) {
        _logger.warning(
          'Ошибка парсинга categoriesInstock для продукта ${entity.code}: $error',
        );
      }
    }

    final sortedProducts = matchingProducts.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return sortedProducts;
  }

  ProductQueryResult<ProductWithStock> _buildResultWithoutStock(
    List<ProductData> products,
    ProductQuery query,
  ) {
    final paginated = _applyPagination(products, query);
    if (paginated.isEmpty) {
      return ProductQueryResult<ProductWithStock>.empty(query);
    }

    final items = paginated.map((entity) {
      final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);
      return ProductWithStock(
        product: product,
        totalStock: 0,
        maxPrice: 0,
        minPrice: 0,
        hasDiscounts: false,
      );
    }).toList(growable: false);

    final hasMore = _hasMore(products.length, query, items.length);

    return ProductQueryResult<ProductWithStock>(
      items: items,
      hasMore: hasMore,
      offset: query.offset,
      limit: query.limit,
      appliedQuery: query,
    );
  }

  Future<ProductQueryResult<ProductWithStock>> _buildResultWithStock(
    List<ProductData> products,
    ProductQuery query,
  ) async {
    if (products.isEmpty) {
      return ProductQueryResult<ProductWithStock>.empty(query);
    }

    final filterResult = await _warehouseFilterService.resolveForCurrentSession(
      bypassInDev: false,
    );
    List<int>? allowedWarehouseIds;

    if (filterResult.devBypass) {
      _logger.fine('ProductQuery: dev режим — пропускаем фильтрацию складов');
    } else if (filterResult.failure != null) {
      _logger.warning(
        'ProductQuery: ошибка фильтра складов: ${filterResult.failure!.message}. Продолжаем без фильтрации.',
      );
    } else if (!filterResult.hasWarehouses) {
      _logger.warning(
        'ProductQuery: для региона ${filterResult.regionCode} не найдено складов. Возвращаем пустой результат.',
      );
      return ProductQueryResult<ProductWithStock>.empty(query);
    } else {
      allowedWarehouseIds = filterResult.warehouseIds;
      _logger.fine(
        'ProductQuery: применяем фильтр по ${allowedWarehouseIds.length} складам для региона ${filterResult.regionCode}',
      );
    }

    final productCodes = products.map((p) => p.code).toList(growable: false);
    final stockQuery = _database.select(_database.stockItems)
      ..where((tbl) => tbl.productCode.isIn(productCodes))
      ..where((tbl) => tbl.stock.isBiggerThanValue(0));

    if (allowedWarehouseIds != null) {
      stockQuery.where((tbl) => tbl.warehouseId.isIn(allowedWarehouseIds!));
    }

    final stockEntities = await stockQuery.get();
    final stockByProduct = <int, List<StockItemData>>{};
    for (final entity in stockEntities) {
      stockByProduct.putIfAbsent(entity.productCode, () => <StockItemData>[])
          .add(entity);
    }

    final availableProducts = products
        .where((product) => (stockByProduct[product.code]?.isNotEmpty ?? false))
        .toList(growable: false);

    if (availableProducts.isEmpty) {
      return ProductQueryResult<ProductWithStock>.empty(query);
    }

    final paginated = _applyPagination(availableProducts, query);
    if (paginated.isEmpty) {
      return ProductQueryResult<ProductWithStock>.empty(query);
    }

    final items = paginated.map((productEntity) {
      final productJson = jsonDecode(productEntity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);
      final stockItems = stockByProduct[productEntity.code] ?? const <StockItemData>[];

      final totalStock = stockItems.fold<int>(0, (sum, item) => sum + item.stock);
      final prices = stockItems
          .map((item) => item.defaultPrice)
          .where((price) => price > 0)
          .toList(growable: false);
      final hasDiscounts = stockItems.any(
        (item) =>
            item.offerPrice != null && item.offerPrice! > 0 && item.offerPrice! < item.defaultPrice,
      );

      final minPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a > b ? a : b);

      return ProductWithStock(
        product: product,
        totalStock: totalStock,
        maxPrice: maxPrice,
        minPrice: minPrice,
        hasDiscounts: hasDiscounts,
      );
    }).toList(growable: false);

    final hasMore = _hasMore(availableProducts.length, query, items.length);

    return ProductQueryResult<ProductWithStock>(
      items: items,
      hasMore: hasMore,
      offset: query.offset,
      limit: query.limit,
      appliedQuery: query,
    );
  }

  List<ProductData> _applyPagination(List<ProductData> products, ProductQuery query) {
    final offset = _safeOffset(query);
    if (query.limit <= 0 || offset >= products.length) {
      return const <ProductData>[];
    }

    return products.skip(offset).take(query.limit).toList(growable: false);
  }

  int _safeOffset(ProductQuery query) => query.offset < 0 ? 0 : query.offset;

  bool _hasMore(int totalItems, ProductQuery query, int returnedItems) {
    if (returnedItems == 0) {
      return false;
    }
    final offset = _safeOffset(query);
    final consumed = offset + returnedItems;
    return consumed < totalItems;
  }

  @override
  Future<Either<Failure, List<Product>>> searchProductsWithFts(
    String query, {
    List<int>? categoryIds,
    int offset = 0,
    int limit = 20,
    List<int>? allowedProductCodes,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      if (allowedProductCodes != null && allowedProductCodes.isEmpty) {
        return const Right([]);
      }

      final sanitizedQuery = _sanitizeFtsQuery(query);
      final lowerQuery = query.trim().toLowerCase();

      String categoryFilter = '';
      if (categoryIds != null && categoryIds.isNotEmpty) {
        final placeholders = List.filled(categoryIds.length, '?').join(',');
        categoryFilter = '''
          AND EXISTS (
            SELECT 1 FROM json_each(json_extract(p.raw_json, '\$.categoriesInstock'))
            WHERE CAST(json_extract(value, '\$.id') AS INTEGER) IN ($placeholders)
          )
        ''';
      }

      String allowedFilter = '';
      if (allowedProductCodes != null && allowedProductCodes.isNotEmpty) {
        final placeholders = List.filled(allowedProductCodes.length, '?').join(',');
        allowedFilter = ' AND p.code IN ($placeholders)';
      }

      final results = await _database.customSelect(
        '''
        SELECT 
          p.code,
          p.raw_json,
          CASE
            WHEN CAST(p.code AS TEXT) = ? THEN 1000
            WHEN EXISTS (
              SELECT 1 FROM json_each(json_extract(p.raw_json, '\$.barcodes'))
              WHERE value = ?
            ) THEN 1000
            WHEN lower(p.title) LIKE ? || '%' THEN 100
            WHEN lower(p.title) LIKE '%' || ? || '%' THEN 50
            WHEN lower(COALESCE(json_extract(p.raw_json, '\$.vendorCode'), '')) LIKE '%' || ? || '%' THEN 30
            WHEN lower(COALESCE(json_extract(p.raw_json, '\$.brand.name'), '')) LIKE '%' || ? || '%' THEN 20
            ELSE CAST(bm25(products_fts) * -10 AS INTEGER)
          END as relevance
        FROM products p
        INNER JOIN products_fts fts ON p.code = fts.product_code
        WHERE products_fts MATCH ?
        $categoryFilter
        $allowedFilter
        ORDER BY relevance DESC, p.title ASC
        LIMIT ? OFFSET ?
        ''',
        variables: [
          Variable.withString(lowerQuery),
          Variable.withString(query),
          Variable.withString(lowerQuery),
          Variable.withString(lowerQuery),
          Variable.withString(lowerQuery),
          Variable.withString(lowerQuery),
          Variable.withString(sanitizedQuery),
          if (categoryIds != null) ...categoryIds.map((id) => Variable.withInt(id)),
          if (allowedProductCodes != null)
            ...allowedProductCodes.map((code) => Variable.withInt(code)),
          Variable.withInt(limit),
          Variable.withInt(offset),
        ],
        readsFrom: {_database.products},
      ).get();

      final productList = results.map((row) {
        final json = jsonDecode(row.data['raw_json'] as String) as Map<String, dynamic>;
        return Product.fromJson(json);
      }).toList();

      final categoryInfo = categoryIds != null
          ? ' в категориях [${categoryIds.join(', ')}] (${categoryIds.length} шт)'
          : '';
      final allowedInfo = allowedProductCodes != null
          ? ' по ${allowedProductCodes.length} кодам'
          : '';
      _logger.fine('FTS поиск "$query"$categoryInfo$allowedInfo: найдено ${productList.length} продуктов');
      return Right(productList);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка FTS поиска продуктов', e, stackTrace);
      return Left(DatabaseFailure('Ошибка поиска: $e'));
    }
  }

  /// Санитизация запроса для FTS5 - удаляет спецсимволы и добавляет prefix matching
  String _sanitizeFtsQuery(String query) {
    // Убираем спецсимволы FTS5 которые могут вызвать синтаксические ошибки
    final sanitized = query
        .replaceAll('"', '')
        .replaceAll('*', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(':', '')
        .replaceAll('^', '')
        .trim();
    
    if (sanitized.isEmpty) {
      return '';
    }
    
    // Разбиваем на токены по пробелам И дефисам (чтобы соответствовать FTS tokenizer)
    final tokens = sanitized.split(RegExp(r'[\s\-]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    
    if (tokens.isEmpty) {
      return '';
    }
    
    // Для FTS5: каждый токен с * для частичного совпадения
    return tokens.map((token) => '$token*').join(' ');
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

    await _upsertFacetData(product);
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

      await _upsertFacetData(product);

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

      await (_database.delete(_database.productFacets)
        ..where((tbl) => tbl.productCode.equals(code))
      ).go();

      await (_database.delete(_database.productCategoryFacets)
        ..where((tbl) => tbl.productCode.equals(code))
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
      await _database.delete(_database.productFacets).go();
      await _database.delete(_database.productCategoryFacets).go();
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
      // НЕ используем categoryId - это legacy поле! Считаем ТОЛЬКО по categoriesInstock
      final allEntities = await _database.select(_database.products).get();
      int count = 0;

      for (final entity in allEntities) {
        try {
          final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
          final categoriesInstock = productJson['categoriesInstock'] as List<dynamic>? ?? [];

          final hasCategory = categoriesInstock.any((cat) {
            final catMap = cat as Map<String, dynamic>;
            return catMap['id'] == categoryId;
          });

          if (hasCategory) {
            count++;
          }
        } catch (e) {
          // Игнорируем ошибки парсинга отдельных продуктов
          _logger.warning('Ошибка парсинга categoriesInstock для продукта ${entity.code}: $e');
          continue;
        }
      }

      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения количества продуктов в категории: $e'));
    }
  }

  Future<void> _upsertFacetData(Product product) async {
    final facetCompanion = ProductFacetMapper.toFacetCompanion(product);
    await _database.into(_database.productFacets).insertOnConflictUpdate(facetCompanion);

    await (_database.delete(_database.productCategoryFacets)
          ..where((tbl) => tbl.productCode.equals(product.code)))
        .go();

    final categoryCompanions = ProductFacetMapper.toCategoryCompanions(product);
    if (categoryCompanions.isEmpty) {
      return;
    }

    await _database.batch((batch) {
      batch.insertAll(
        _database.productCategoryFacets,
        categoryCompanions,
      );
    });
  }
}