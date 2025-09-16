// lib/app/database/repositories/product_repository_drift.dart

import 'dart:convert';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';

/// Drift реализация репозитория продуктов
class DriftProductRepository implements ProductRepository {
  final AppDatabase _database = GetIt.instance<AppDatabase>();

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final entities = await _database.select(_database.products).get();

      final products = <Product>[];

      for (final entity in entities) {
        final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        final product = Product.fromJson(productJson);
        products.add(product);
      }

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

      final productJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final product = Product.fromJson(productJson);
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
  Future<Either<Failure, List<Product>>> getProductsByCategoryPaginated(int categoryId, {int offset = 0, int limit = 20}) async {
    try {
      // Получаем все категории в иерархии (родитель + все потомки)
      final categoryRepository = GetIt.instance<CategoryRepository>();
      final descendantsResult = await categoryRepository.getAllDescendants(categoryId);
      final ancestorsResult = await categoryRepository.getAllAncestors(categoryId);

      if (descendantsResult.isLeft() || ancestorsResult.isLeft()) {
        print('🎭 ProductRepository: Ошибка получения иерархии категорий');
        return Left(DatabaseFailure('Ошибка получения иерархии категорий'));
      }

      final descendants = descendantsResult.getOrElse(() => []);
      final ancestors = ancestorsResult.getOrElse(() => []);

      // Создаем множество всех релевантных ID категорий
      final relevantCategoryIds = {categoryId};
      relevantCategoryIds.addAll(descendants.map((c) => c.id));
      relevantCategoryIds.addAll(ancestors.map((c) => c.id));

      // print('🎭 ProductRepository: Ищем в категориях: $relevantCategoryIds');

      // Сначала ищем по точному совпадению categoryId
      final directMatches = await (_database.select(_database.products)
        ..where((tbl) => tbl.categoryId.equals(categoryId))
      ).get();

      // print('🎭 ProductRepository: Найдено ${directMatches.length} прямых совпадений для категории $categoryId');

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
          continue;
        }
      }

      // print('🎭 ProductRepository: Найдено ${instockMatches.length} совпадений в categoriesInstock для иерархии категории $categoryId');

      // Объединяем результаты
      final allMatches = [...directMatches, ...instockMatches];

      // Применяем пагинацию
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
      print('🎭 ProductRepository: Ошибка сохранения продуктов: $e');
      return Left(DatabaseFailure('Ошибка сохранения продуктов: $e'));
    }
  }

  Future<void> _saveProduct(Product product) async {
    final companion = ProductsCompanion(
      catalogId: Value(product.catalogId),
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

    await _database.into(_database.products).insertOnConflictUpdate(companion);
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
        ..where((tbl) => tbl.catalogId.equals(product.catalogId))
      ).write(companion);

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка обновления продукта: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int catalogId) async {
    try {
      await (_database.delete(_database.products)
        ..where((tbl) => tbl.catalogId.equals(catalogId))
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
      }).where((product) =>
        product.stockItems.any((stock) => stock.promotion != null)
      ).toList();

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
      // print('🎭 ProductRepository: Всего продуктов в категории $categoryId: $totalCount');

      return Right(totalCount);
    } catch (e) {
      // print('🎭 ProductRepository: Ошибка подсчета продуктов в категории $categoryId: $e');
      return Left(DatabaseFailure('Ошибка получения количества продуктов в категории: $e'));
    }
  }
}