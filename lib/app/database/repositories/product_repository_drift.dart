// lib/app/database/repositories/product_repository_drift.dart

import 'dart:convert';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/app/database/mappers/product_mapper.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:logging/logging.dart';

class DriftProductRepository implements ProductRepository {
  final AppDatabase _database = GetIt.instance<AppDatabase>();
  
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
      final directMatches = await (_database.select(_database.products)
        ..where((tbl) => tbl.categoryId.equals(categoryId))
      ).get();

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
    int categoryId, 
    String vendorId, {
    int offset = 0, 
    int limit = 20
  }) async {
    try {
      _logger.info('getProductsWithStockByCategoryPaginated: categoryId=$categoryId, vendorId=$vendorId, offset=$offset, limit=$limit');
      
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

      // Проверяем какие warehouseVendorId есть в базе
      final allStockItems = await _database.select(_database.stockItems).get();
      final uniqueVendorIds = allStockItems.map((s) => s.warehouseVendorId).toSet();
      _logger.info('Unique warehouseVendorId in stock_items: $uniqueVendorIds');
      
      final stockItemsForVendor = allStockItems.where((s) => s.warehouseVendorId == vendorId).toList();
      _logger.info('Stock items for vendorId=$vendorId: ${stockItemsForVendor.length} items');
      if (stockItemsForVendor.isNotEmpty) {
        _logger.info('Sample stock items: ${stockItemsForVendor.take(3).map((s) => 'productCode=${s.productCode}, warehouseVendorId=${s.warehouseVendorId}').join('; ')}');
      }

      // JOIN с stock_items для получения остатков
      final query = _database.select(_database.products).join([
        innerJoin(
          _database.stockItems, 
          _database.stockItems.productCode.equalsExp(_database.products.code)
        ),
      ]);

      final allProductsQuery = _database.select(_database.products);
      final allProductEntities = await allProductsQuery.get();
      
      _logger.info('🔍 Всего продуктов в БД: ${allProductEntities.length}');
      
      final matchingProducts = <ProductData>[];
      
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
            matchingProducts.add(productEntity);
          }
        } catch (e) {
          _logger.warning('Ошибка парсинга categoriesInstock для продукта ${productEntity.code}: $e');
        }
      }
      
      _logger.info('🔍 Продукты с categoriesInstock в категориях ${relevantCategoryIds}: ${matchingProducts.length} найдено');
      
      if (matchingProducts.isNotEmpty) {
        final sampleProducts = matchingProducts.take(3).map((p) => 'code=${p.code}, title=${p.title}').join('; ');
        _logger.info('🔍 Примеры продуктов: $sampleProducts');
        
        // Проверим есть ли StockItems для этих productCode
        final productCodes = matchingProducts.map((p) => p.code).toList();
        final matchingStockItems = await (_database.select(_database.stockItems)
          ..where((tbl) => tbl.productCode.isIn(productCodes) & tbl.warehouseVendorId.equals(vendorId))
        ).get();
        _logger.info('🔍 StockItems для этих продуктов: ${matchingStockItems.length} найдено');
      }

      // Теперь делаем JOIN только для найденных продуктов
      final matchingProductCodes = matchingProducts.map((p) => p.code).toList();
      
      if (matchingProductCodes.isEmpty) {
        // Если нет подходящих продуктов, возвращаем пустой результат
        _logger.info('📊 JOIN результат: 0 строк найдено (нет продуктов в категориях)');
        _logger.info('✅ Возвращаем 0 ProductWithStock для категории $categoryId');
        return Right([]);
      }

      // Фильтры по найденным продуктам и vendorId  
      query.where(
        _database.products.code.isIn(matchingProductCodes) &
        _database.stockItems.warehouseVendorId.equals(vendorId)
      );

      // Пагинация
      query.limit(limit, offset: offset);

      final result = await query.get();
      _logger.info('📊 JOIN результат: ${result.length} строк найдено');

      final productWithStockList = <ProductWithStock>[];
      final productStockMap = <int, List<StockItemData>>{};

      // Группируем остатки по продуктам
      for (final row in result) {
        final productEntity = row.readTable(_database.products);
        final stockEntity = row.readTable(_database.stockItems);
        
        if (!productStockMap.containsKey(productEntity.code)) {
          productStockMap[productEntity.code] = [];
        }
        
        productStockMap[productEntity.code]!.add(stockEntity);
      }

      // Создаём ProductWithStock для каждого продукта
      final processedProducts = <int>{};
      for (final row in result) {
        final productEntity = row.readTable(_database.products);
        
        if (processedProducts.contains(productEntity.code)) continue;
        processedProducts.add(productEntity.code);

        final productJson = jsonDecode(productEntity.rawJson) as Map<String, dynamic>;
        final product = Product.fromJson(productJson);
        
        final stockItems = productStockMap[productEntity.code] ?? [];
        
        // Вычисляем агрегированные данные по остаткам
        final totalStock = stockItems.fold<int>(0, (sum, item) => sum + item.stock);
        final prices = stockItems
            .map((item) => item.defaultPrice)
            .where((price) => price > 0)
            .toList();
        final hasDiscounts = stockItems.any((item) => item.offerPrice != null && item.offerPrice! > 0 && item.offerPrice! < item.defaultPrice);
        
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

      _logger.info('✅ Возвращаем ${productWithStockList.length} ProductWithStock для категории $categoryId');
      return Right(productWithStockList);
    } catch (e, st) {
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