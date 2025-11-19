// lib/app/database/repositories/product_repository_drift.dart

import 'dart:convert';
import 'package:fieldforce/app/config/app_config.dart';
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
  static const bool _logQueryPlanFlag = bool.fromEnvironment('CATALOG_LOG_PLAN', defaultValue: false);

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
      final totalStopwatch = Stopwatch()..start();

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
      final normalizedScope = scope.toList(growable: false);
      final normalizedQuery = query.copyWith(scopedCategoryIds: normalizedScope);
      final hasAllowedCodes = normalizedQuery.allowedProductCodes != null;
      final filterByCategory = normalizedScope.isNotEmpty;

      if (!filterByCategory && !hasAllowedCodes) {
        _logger.fine('ProductQuery без категории и allowedProductCodes — возвращаем пустой результат');
        return Right(ProductQueryResult<ProductWithStock>.empty(normalizedQuery));
      }

      final _WarehouseConstraint warehouseConstraint;
      if (normalizedQuery.requireStock) {
        warehouseConstraint = await _resolveWarehouseConstraint();
        if (warehouseConstraint.shouldReturnEmpty) {
          _logger.fine('Фильтр складов вернул пустой набор — пустой результат');
          return Right(ProductQueryResult<ProductWithStock>.empty(normalizedQuery));
        }
      } else {
        warehouseConstraint = const _WarehouseConstraint(warehouseIds: null);
      }

      final sqlBuilder = _ProductQuerySqlBuilder(
        query: normalizedQuery,
        warehouseIds: normalizedQuery.requireStock ? warehouseConstraint.warehouseIds : null,
      );

      if (sqlBuilder.isEmptyResult) {
        return Right(ProductQueryResult<ProductWithStock>.empty(normalizedQuery));
      }

      if (_logger.isLoggable(Level.INFO)) {
        _logger.info(
          'ProductQuery debug: scoped=${normalizedScope.take(8).toList()} '
          'allowedCount=${normalizedQuery.allowedProductCodes?.length ?? 0} '
          'requireStock=${normalizedQuery.requireStock} '
          'warehouses=${warehouseConstraint.warehouseIds ?? 'ALL'} '
          'where="${sqlBuilder.whereClause}" '
          'args=${_formatSqlArguments(sqlBuilder.arguments)}',
        );
      }

      if (_logger.isLoggable(Level.FINER)) {
        _logger.finer('ProductQuery SQL builder for $normalizedQuery => ${sqlBuilder.debugDescription()}');
      }

      final codesStopwatch = Stopwatch()..start();
      final _PagedProductCodes pageCodes = await _fetchPagedProductCodes(
        sqlBuilder,
        normalizedQuery,
      );
      _logger.info(
        'ProductQuery: кодов=${pageCodes.codes.length} hasMore=${pageCodes.hasMore} time=${codesStopwatch.elapsedMilliseconds}ms query=${_summarizeQuery(normalizedQuery)}',
      );

      if (pageCodes.codes.isEmpty) {
        return Right(ProductQueryResult<ProductWithStock>.empty(normalizedQuery));
      }

      final productStopwatch = Stopwatch()..start();
      final productEntities = await _loadProductsByCodes(pageCodes.codes);
      if (productEntities.isEmpty) {
        return Right(ProductQueryResult<ProductWithStock>.empty(normalizedQuery));
      }
      _logger.info(
        'ProductQuery: загрузка products=${productEntities.length} заняла ${productStopwatch.elapsedMilliseconds}ms query=${_summarizeQuery(normalizedQuery)}',
      );

      final Map<int, List<StockItemData>> stockByCode;
      if (normalizedQuery.requireStock) {
        final stockStopwatch = Stopwatch()..start();
        stockByCode = await _loadStocksByCodes(
          pageCodes.codes,
          warehouseConstraint.warehouseIds,
        );
        _logger.info(
          'ProductQuery: загрузка stock для ${stockByCode.length} товаров заняла ${stockStopwatch.elapsedMilliseconds}ms query=${_summarizeQuery(normalizedQuery)}',
        );
      } else {
        stockByCode = const <int, List<StockItemData>>{};
      }

      final items = _buildProductWithStockList(
        productEntities,
        stockByCode,
        normalizedQuery.requireStock,
      );

      final result = ProductQueryResult<ProductWithStock>(
        items: items,
        hasMore: pageCodes.hasMore,
        offset: pageCodes.offset,
        limit: pageCodes.limit,
        appliedQuery: normalizedQuery,
      );

      _logger.info(
        'ProductQuery: total=${totalStopwatch.elapsedMilliseconds}ms items=${items.length} hasMore=${result.hasMore} query=${_summarizeQuery(normalizedQuery)}',
      );

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

  int _safeOffset(ProductQuery query) => query.offset < 0 ? 0 : query.offset;

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

      String categoryJoin = '';
      String categoryCondition = '';
      var includeCategoryTable = false;
      if (categoryIds != null && categoryIds.isNotEmpty) {
        final placeholders = List.filled(categoryIds.length, '?').join(',');
        categoryJoin = 'INNER JOIN product_category_facets pcf ON pcf.product_code = p.code';
        categoryCondition = ' AND pcf.category_id IN ($placeholders)';
        includeCategoryTable = true;
      }

      String allowedFilter = '';
      if (allowedProductCodes != null && allowedProductCodes.isNotEmpty) {
        final placeholders = List.filled(allowedProductCodes.length, '?').join(',');
        allowedFilter = ' AND p.code IN ($placeholders)';
      }

      final results = await _database.customSelect(
        '''
        SELECT DISTINCT
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
        $categoryJoin
        INNER JOIN products_fts fts ON p.code = fts.product_code
        WHERE products_fts MATCH ?
        $categoryCondition
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
        readsFrom: {
          _database.products,
          if (includeCategoryTable) _database.productCategoryFacets,
        },
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

  Future<_PagedProductCodes> _fetchPagedProductCodes(
    _ProductQuerySqlBuilder builder,
    ProductQuery query,
  ) async {
    final limit = query.limit;
    final offset = _safeOffset(query);
    final sql = builder.buildPagedCodesSql();
    final variables = <Variable>[
      ...builder.buildVariables(),
      Variable<int>(limit + 1),
      Variable<int>(offset),
    ];

    if (_shouldLogQueryPlan) {
      await _logQueryPlan(sql, variables, builder.readsFrom(_database));
    }

    final rows = await _database.customSelect(
      sql,
      variables: variables,
      readsFrom: builder.readsFrom(_database),
    ).get();

    final codes = rows
        .map((row) => row.data['product_code'] as int?)
        .whereType<int>()
        .toList(growable: false);

    if (codes.isEmpty && _logger.isLoggable(Level.INFO)) {
      _logger.info('ProductQuery SQL returned 0 product codes for where="${builder.whereClause}"');
    }

    final hasMore = codes.length > limit;
    final effectiveCodes = hasMore ? codes.sublist(0, limit) : codes;

    return _PagedProductCodes(
      codes: effectiveCodes,
      hasMore: hasMore,
      offset: offset,
      limit: limit,
    );
  }

  Future<List<ProductData>> _loadProductsByCodes(List<int> codes) async {
    if (codes.isEmpty) {
      return const <ProductData>[];
    }

    final query = _database.select(_database.products)
      ..where((tbl) => tbl.code.isIn(codes));
    final rows = await query.get();
    if (rows.isEmpty) {
      return const <ProductData>[];
    }

    final byCode = <int, ProductData>{
      for (final entity in rows) entity.code: entity,
    };

    final ordered = <ProductData>[];
    for (final code in codes) {
      final entity = byCode[code];
      if (entity != null) {
        ordered.add(entity);
      }
    }
    return ordered;
  }

  Future<Map<int, List<StockItemData>>> _loadStocksByCodes(
    List<int> productCodes,
    List<int>? warehouseIds,
  ) async {
    if (productCodes.isEmpty) {
      return const <int, List<StockItemData>>{};
    }

    final stockQuery = _database.select(_database.stockItems)
      ..where((tbl) => tbl.productCode.isIn(productCodes))
      ..where((tbl) => tbl.stock.isBiggerThanValue(0));

    if (warehouseIds != null) {
      stockQuery.where((tbl) => tbl.warehouseId.isIn(warehouseIds));
    }

    final stockEntities = await stockQuery.get();
    final result = <int, List<StockItemData>>{};
    for (final entity in stockEntities) {
      result.putIfAbsent(entity.productCode, () => <StockItemData>[]).add(entity);
    }
    return result;
  }

  List<ProductWithStock> _buildProductWithStockList(
    List<ProductData> products,
    Map<int, List<StockItemData>> stockByCode,
    bool includeStock,
  ) {
    return products.map((entity) {
      final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);

      if (!includeStock) {
        return ProductWithStock(
          product: product,
          totalStock: 0,
          maxPrice: 0,
          minPrice: 0,
          hasDiscounts: false,
        );
      }

      final stockItems = stockByCode[entity.code] ?? const <StockItemData>[];
      if (stockItems.isEmpty) {
        return ProductWithStock(
          product: product,
          totalStock: 0,
          maxPrice: 0,
          minPrice: 0,
          hasDiscounts: false,
        );
      }

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
  }

  Future<_WarehouseConstraint> _resolveWarehouseConstraint() async {
    try {
      final filterResult = await _warehouseFilterService.resolveForCurrentSession();

      if (filterResult.failure != null) {
        _logger.warning(
          'ProductQuery: ошибка фильтра складов: ${filterResult.failure!.message}. Продолжаем без фильтрации.',
        );
        return const _WarehouseConstraint(warehouseIds: null);
      }

      if (!filterResult.hasWarehouses) {
        _logger.warning(
          'ProductQuery: для региона ${filterResult.regionCode} не найдено складов. Возвращаем пустой результат.',
        );
        return const _WarehouseConstraint(
          warehouseIds: <int>[],
          shouldReturnEmpty: true,
        );
      }

      return _WarehouseConstraint(
        warehouseIds: List<int>.from(filterResult.warehouseIds),
      );
    } catch (error, stackTrace) {
      _logger.severe('ProductQuery: не удалось определить фильтр складов', error, stackTrace);
      return const _WarehouseConstraint(warehouseIds: null);
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

  bool get _shouldLogQueryPlan => _logQueryPlanFlag || AppConfig.enableDebugTools;

  Future<void> _logQueryPlan(
    String sql,
    List<Variable> variables,
    Set<TableInfo<Table, dynamic>> readsFrom,
  ) async {
    final normalizedSql = _stripTrailingSemicolon(sql);
    try {
      final planRows = await _database.customSelect(
        'EXPLAIN QUERY PLAN $normalizedSql',
        variables: variables,
        readsFrom: readsFrom,
      ).get();

      for (final row in planRows) {
        final selectId = row.data['selectid'];
        final fromIdx = row.data['from'];
        final detail = row.data['detail'];
        _logger.info('CATALOG PLAN: selectId=$selectId from=$fromIdx detail=$detail');
      }
    } catch (error, stackTrace) {
      _logger.warning('Не удалось получить план запроса каталога', error, stackTrace);
    }
  }
}

String _summarizeQuery(ProductQuery query) {
  final scope = query.scopedCategoryIds.isNotEmpty
      ? '[${query.scopedCategoryIds.take(3).join(',')}${query.scopedCategoryIds.length > 3 ? '…' : ''}]'
      : '[]';
  final allowed = query.allowedProductCodes == null
      ? 'null'
      : '[${query.allowedProductCodes!.take(3).join(',')}${query.allowedProductCodes!.length > 3 ? '…' : ''}]';
  return 'base=${query.baseCategoryId} scope=$scope allowed=$allowed limit=${query.limit} offset=${query.offset} stock=${query.requireStock}';
}

String _stripTrailingSemicolon(String sql) {
  var normalized = sql.trimRight();
  while (normalized.endsWith(';')) {
    normalized = normalized.substring(0, normalized.length - 1).trimRight();
  }
  return normalized;
}

class _PagedProductCodes {
  const _PagedProductCodes({
    required this.codes,
    required this.hasMore,
    required this.offset,
    required this.limit,
  });

  final List<int> codes;
  final bool hasMore;
  final int offset;
  final int limit;
}

class _ProductQuerySqlBuilder {
  _ProductQuerySqlBuilder({
    required ProductQuery query,
    List<int>? warehouseIds,
  }) : _parts = _buildParts(query, warehouseIds);

  final _ProductQuerySqlParts _parts;

  bool get isEmptyResult => _parts.isEmptyResult;
  String get whereClause => _parts.whereClause;
  List<dynamic> get arguments => List<dynamic>.unmodifiable(_parts.arguments);
  bool get requiresCategoryFilter => _parts.requiresCategoryFilter;
  bool get requiresStockFilter => _parts.requiresStockFilter;

  String buildPagedCodesSql() => '''
SELECT p.code AS product_code
FROM products p
JOIN product_facets pf ON pf.product_code = p.code
WHERE ${_parts.whereClause}
ORDER BY p.title COLLATE NOCASE, p.code
LIMIT ? OFFSET ?;
''';

  List<Variable> buildVariables() => _parts.buildVariables();

  String debugDescription() {
    return 'where="${_parts.whereClause}" categoryFilter=${_parts.requiresCategoryFilter} stockFilter=${_parts.requiresStockFilter} args=${_parts.arguments}';
  }

  Set<TableInfo<Table, dynamic>> readsFrom(AppDatabase db) {
    final tables = <TableInfo<Table, dynamic>>{db.productFacets, db.products};
    if (_parts.requiresCategoryFilter) {
      tables.add(db.productCategoryFacets);
    }
    if (_parts.requiresStockFilter) {
      tables.add(db.stockItems);
    }
    return tables;
  }

  static _ProductQuerySqlParts _buildParts(
    ProductQuery query,
    List<int>? warehouseIds,
  ) {
    final where = <String>[];
    final whereArguments = <dynamic>[];
    var requiresCategoryFilter = false;
    var requiresStockFilter = false;

    if (query.allowedProductCodes != null) {
      final codes = query.allowedProductCodes!;
      if (codes.isEmpty) {
        return _ProductQuerySqlParts.empty();
      }
      where.add('pf.product_code IN (${_placeholders(codes.length)})');
      whereArguments.addAll(codes);
    }

    final categoryIds = query.scopedCategoryIds;
    if (categoryIds.isNotEmpty) {
      requiresCategoryFilter = true;
      final placeholders = _placeholders(categoryIds.length);
      where.add(
        'EXISTS (SELECT 1 FROM product_category_facets pcf WHERE pcf.product_code = pf.product_code AND pcf.category_id IN ($placeholders))',
      );
      whereArguments.addAll(categoryIds);
    }

    void addIntFilter(String column, List<int> values) {
      if (values.isEmpty) return;
      where.add('$column IN (${_placeholders(values.length)})');
      whereArguments.addAll(values);
    }

    addIntFilter('pf.brand_id', query.brandIds);
    addIntFilter('pf.manufacturer_id', query.manufacturerIds);
    addIntFilter('pf.series_id', query.seriesIds);
    addIntFilter('pf.type_id', query.productTypeIds);

    if (query.onlyNovelty) {
      where.add('pf.novelty = 1');
    }
    if (query.onlyPopular) {
      where.add('pf.popular = 1');
    }

    if (query.requireStock) {
      requiresStockFilter = true;
      final buffer = StringBuffer()
        ..write('EXISTS (SELECT 1 FROM stock_items si WHERE si.product_code = pf.product_code AND si.stock > 0');
      if (warehouseIds != null) {
        if (warehouseIds.isEmpty) {
          return _ProductQuerySqlParts.empty();
        }
        buffer.write(' AND si.warehouse_id IN (${_placeholders(warehouseIds.length)})');
        whereArguments.addAll(warehouseIds);
      }
      buffer.write(')');
      where.add(buffer.toString());
    }

    if (where.isEmpty) {
      where.add('1 = 1');
    }

    return _ProductQuerySqlParts(
      whereClause: where.join(' AND '),
      arguments: [...whereArguments],
      requiresCategoryFilter: requiresCategoryFilter,
      requiresStockFilter: requiresStockFilter,
      isEmptyResult: false,
    );
  }
}

String _formatSqlArguments(List<dynamic> args) {
  if (args.isEmpty) return '[]';
  const maxItems = 10;
  final buffer = <String>[];
  for (var i = 0; i < args.length && i < maxItems; i++) {
    buffer.add(args[i].toString());
  }
  if (args.length > maxItems) {
    buffer.add('…(+${args.length - maxItems})');
  }
  return '[${buffer.join(', ')}]';
}

class _ProductQuerySqlParts {
  const _ProductQuerySqlParts({
    required this.whereClause,
    required this.arguments,
    required this.requiresCategoryFilter,
    required this.requiresStockFilter,
    required this.isEmptyResult,
  });

  final String whereClause;
  final List<dynamic> arguments;
  final bool requiresCategoryFilter;
  final bool requiresStockFilter;
  final bool isEmptyResult;

  List<Variable> buildVariables() {
    return arguments.map((value) {
      if (value is int) return Variable<int>(value);
      if (value is num) return Variable<int>(value.toInt());
      if (value is bool) return Variable<bool>(value);
      if (value is String) return Variable<String>(value);
      throw UnsupportedError('Unsupported SQL argument: $value');
    }).toList(growable: false);
  }

  factory _ProductQuerySqlParts.empty() => const _ProductQuerySqlParts(
        whereClause: '1 = 0',
        arguments: <dynamic>[],
        requiresCategoryFilter: false,
        requiresStockFilter: false,
        isEmptyResult: true,
      );
}

class _WarehouseConstraint {
  const _WarehouseConstraint({
    required this.warehouseIds,
    this.shouldReturnEmpty = false,
  });

  final List<int>? warehouseIds;
  final bool shouldReturnEmpty;
}

String _placeholders(int count) => List.filled(count, '?').join(', ');