import 'dart:convert';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart' as tree_category;
import 'package:fieldforce/features/shop/domain/entities/product.dart' as product_entity;

/// Drift реализация репозитория категорий
class DriftCategoryRepository implements CategoryRepository {
  final AppDatabase _database = GetIt.instance<AppDatabase>();
  static final Logger _logger = Logger('DriftCategoryRepository');

  @override
  Future<Either<Failure, List<tree_category.Category>>> getAllCategories() async {
    try {
      final entities = await _database.select(_database.categories).get();
            final categories = <tree_category.Category>[];

      for (final entity in entities) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        final category = tree_category.Category.fromJson(categoryJson);
        categories.add(category);
      }

      // Построить дерево из плоского списка
      final tree = _buildCategoryTree(categories);
      return Right(tree);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения категорий: $e'));
    }
  }

  /// Строит дерево категорий из плоского списка
  List<tree_category.Category> _buildCategoryTree(List<tree_category.Category> categories) {
    final categoryMap = <int, tree_category.Category>{};
    final rootCategories = <tree_category.Category>[];
    final processedIds = <int>{}; // Отслеживаем обработанные категории

    // Сначала создаем карту всех категорий, удаляя дубликаты
    for (final category in categories) {
      if (!processedIds.contains(category.id)) {
        categoryMap[category.id] = category;
        processedIds.add(category.id);
      }
    }

    // Затем строим дерево
    for (final category in categoryMap.values) {
      if (category.lvl == 1) {
        // Корневая категория
        if (!rootCategories.any((root) => root.id == category.id)) {
          rootCategories.add(category);
        }
      } else {
        // Находим родителя и добавляем как ребенка
        // Используем nested set для определения родителя
        try {
          final parent = categoryMap.values.firstWhere(
            (c) => c.lft < category.lft && c.rgt > category.rgt && c.lvl == category.lvl - 1,
          );
          if (!parent.children.any((child) => child.id == category.id)) {
            parent.children.add(category);
          }
        } catch (e) {
          // Если не нашли родителя по nested set, попробуем по parentId если он есть
          // Но пока просто добавим как корневую
          if (!rootCategories.any((root) => root.id == category.id)) {
            rootCategories.add(category);
          }
        }
      }
    }

    // for (final root in rootCategories) {
    //   _printCategoryTree(root, 0);
    // }

    return rootCategories;
  }

  @override
  Future<Either<Failure, tree_category.Category?>> getCategoryById(int id) async {
    try {
      final entity = await (_database.select(_database.categories)
        ..where((tbl) => tbl.categoryId.equals(id))
      ).getSingleOrNull();

      if (entity == null) return const Right(null);

      final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final category = tree_category.Category.fromJson(categoryJson);
      return Right(category);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения категории: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCategories(List<tree_category.Category> categories) async {
    try {
      await _database.transaction(() async {
        // Очистить существующие категории
        await _database.delete(_database.categories).go();

        // Используем Set для отслеживания сохраненных ID и предотвращения дубликатов
        final savedIds = <int>{};

        // Сохранить новые, пропуская дубликаты
        for (final category in categories) {
          if (!savedIds.contains(category.id)) {
            await _saveCategoryRecursive(category, null, savedIds);
            savedIds.add(category.id);
          }
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка сохранения категорий: $e'));
    }
  }

  Future<void> _saveCategoryRecursive(tree_category.Category category, int? parentId, Set<int> savedIds) async {
    final companion = CategoriesCompanion(
      name: Value(category.name),
      categoryId: Value(category.id),
      lft: Value(category.lft),
      lvl: Value(category.lvl),
      rgt: Value(category.rgt),
      description: Value(category.description),
      query: Value(category.query),
      count: Value(category.count),
      parentId: Value(parentId),
      rawJson: Value(jsonEncode(category.toJson())),
    );

    final insertedId = await _database.into(_database.categories).insert(companion);

    for (final child in category.children) {
      if (!savedIds.contains(child.id)) {
        await _saveCategoryRecursive(child, insertedId, savedIds);
        savedIds.add(child.id);
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(tree_category.Category category) async {
    try {
      final companion = CategoriesCompanion(
        name: Value(category.name),
        lft: Value(category.lft),
        lvl: Value(category.lvl),
        rgt: Value(category.rgt),
        description: Value(category.description),
        query: Value(category.query),
        count: Value(category.count),
        rawJson: Value(jsonEncode(category.toJson())),
      );

      await (_database.update(_database.categories)
        ..where((tbl) => tbl.categoryId.equals(category.id))
      ).write(companion);

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка обновления категории: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    try {
      await (_database.delete(_database.categories)
        ..where((tbl) => tbl.categoryId.equals(id))
      ).go();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка удаления категории: $e'));
    }
  }

  @override
  Future<Either<Failure, List<tree_category.Category>>> searchCategories(String query) async {
    try {
      final entities = await (_database.select(_database.categories)
        ..where((tbl) => tbl.name.contains(query))
      ).get();

      final categories = entities.map((entity) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return tree_category.Category.fromJson(categoryJson);
      }).toList();

      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка поиска категорий: $e'));
    }
  }

  @override
  Future<Either<Failure, List<tree_category.Category>>> getSubcategories(int parentId) async {
    try {
      final entities = await (_database.select(_database.categories)
        ..where((tbl) => tbl.parentId.equals(parentId))
      ).get();

      final categories = entities.map((entity) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return tree_category.Category.fromJson(categoryJson);
      }).toList();

      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения подкатегорий: $e'));
    }
  }

  @override
  Future<Either<Failure, List<tree_category.Category>>> getAllDescendants(int categoryId) async {
    try {
      // Сначала получаем категорию, чтобы узнать её lft и rgt
      final parentEntity = await (_database.select(_database.categories)
        ..where((tbl) => tbl.categoryId.equals(categoryId))
      ).getSingleOrNull();

      if (parentEntity == null) {
        return Right([]);
      }

      final parentJson = jsonDecode(parentEntity.rawJson) as Map<String, dynamic>;
      final parentCategory = tree_category.Category.fromJson(parentJson);

      // Находим всех потомков по nested set: lft > parent.lft AND rgt < parent.rgt
      final entities = await (_database.select(_database.categories)
        ..where((tbl) => tbl.lft.isBiggerThanValue(parentCategory.lft) & tbl.rgt.isSmallerThanValue(parentCategory.rgt))
      ).get();

      final categories = entities.map((entity) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return tree_category.Category.fromJson(categoryJson);
      }).toList();

      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения потомков категории: $e'));
    }
  }

  @override
  Future<Either<Failure, List<tree_category.Category>>> getAllAncestors(int categoryId) async {
    try {
      final ancestors = <tree_category.Category>[];
      var currentId = categoryId;

      // Рекурсивно поднимаемся по иерархии
      while (true) {
        final entity = await (_database.select(_database.categories)
          ..where((tbl) => tbl.categoryId.equals(currentId))
        ).getSingleOrNull();

        if (entity == null) break;

        // Если это корневая категория (lvl == 1), прекращаем
        if (entity.lvl == 1) break;

        // Ищем родителя по parentId из базы данных
        if (entity.parentId == null) break;

        final parentEntity = await (_database.select(_database.categories)
          ..where((tbl) => tbl.categoryId.equals(entity.parentId!))
        ).getSingleOrNull();

        if (parentEntity == null) break;

        final parentJson = jsonDecode(parentEntity.rawJson) as Map<String, dynamic>;
        final parentCategory = tree_category.Category.fromJson(parentJson);

        ancestors.add(parentCategory);
        currentId = parentCategory.id;
      }

      return Right(ancestors);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения предков категории: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategoryCounts() async {
    try {
      _logger.info('Начинаем обновление count для всех категорий');

      // Получаем все категории в виде дерева
      final allCategoriesResult = await getAllCategories();
      if (allCategoriesResult.isLeft()) {
        return Left(DatabaseFailure('Ошибка получения всех категорий'));
      }

      final allCategories = allCategoriesResult.getOrElse(() => []);
      return await _updateCategoryCountsInternal(allCategories);
    } catch (e, st) {
      _logger.severe('Ошибка обновления count', e, st);
      return Left(DatabaseFailure('Ошибка обновления count категорий: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategoryCountsWithCategories(List<tree_category.Category> categories) async {
    try {
      _logger.info('Начинаем обновление count для переданных категорий');
      return await _updateCategoryCountsInternal(categories);
    } catch (e, st) {
      _logger.severe('Ошибка обновления count', e, st);
      return Left(DatabaseFailure('Ошибка обновления count категорий: $e'));
    }
  }

  Future<Either<Failure, void>> _updateCategoryCountsInternal(List<tree_category.Category> allCategories) async {
    final flatCategories = _flattenCategories(allCategories);
    _logger.info('Найдено ${flatCategories.length} уникальных категорий для обновления');

    // Получаем все продукты для расчета count
    final productRepository = GetIt.instance<ProductRepository>();
    final allProductsResult = await productRepository.getAllProducts();
    if (allProductsResult.isLeft()) {
      print('❌ Ошибка получения всех продуктов');
      return Left(DatabaseFailure('Ошибка получения всех продуктов'));
    }

    final allProducts = allProductsResult.getOrElse(() => []);
    _logger.info('Получено ${allProducts.length} продуктов для расчета count');

    // Рассчитываем count для каждой категории с учетом иерархии
    final categoryCounts = _calculateCategoryCounts(allCategories, allProducts);

    // Обновляем count в объектах категорий (для немедленного отображения в UI)
    _updateCategoriesCount(allCategories, categoryCounts);

    // Обновляем count в базе данных
    for (final category in flatCategories) {
      final count = categoryCounts[category.id] ?? 0;

      // Обновляем как поле count, так и rawJson с актуальным значением
      final updatedJson = category.toJson();
      updatedJson['count'] = count;

      await (_database.update(_database.categories)
        ..where((tbl) => tbl.categoryId.equals(category.id))
      ).write(CategoriesCompanion(
        count: Value(count),
        rawJson: Value(jsonEncode(updatedJson)),
      ));

      // _logger.info('✅ Категория ${category.name} (id: ${category.id}): обновлено count = $count');
    }

    _logger.info('Обновление count завершено');
    return const Right(null);
  }

  /// Обновляет count в объектах дерева категорий (синхронно и mutable)
  void _updateCategoriesCount(List<tree_category.Category> categories, Map<int, int> categoryCounts) {
    for (final category in categories) {
      _updateCategoryCountRecursive(category, categoryCounts);
    }
  }

  void _updateCategoryCountRecursive(tree_category.Category category, Map<int, int> categoryCounts) {
    // Обновляем count в существующем mutable объекте
    category.count = categoryCounts[category.id] ?? 0;

    // Рекурсивно обновляем всех потомков
    for (final child in category.children) {
      _updateCategoryCountRecursive(child, categoryCounts);
    }
  }

  /// Рассчитывает количество продуктов для каждой категории с учетом иерархии
  Map<int, int> _calculateCategoryCounts(List<tree_category.Category> categories, List<product_entity.Product> products) {
    final counts = <int, int>{};

    // Получаем все категории в плоском виде
    final allCategories = _flattenCategories(categories);

    // Для каждой категории рассчитываем количество продуктов
    for (final category in allCategories) {
      final categoryProducts = _findProductsInCategoryAndDescendants(products, category);
      counts[category.id] = categoryProducts.length;
    }

    return counts;
  }

  /// Находит продукты в категории и всех её потомках
  List<product_entity.Product> _findProductsInCategoryAndDescendants(List<product_entity.Product> products, tree_category.Category category) {
    final result = <product_entity.Product>[];
    final categoryIds = {category.id};

    // Добавляем ID всех потомков
    for (final descendant in category.getAllDescendants()) {
      categoryIds.add(descendant.id);
    }

    // Ищем продукты, у которых есть категории из нашего множества
    for (final product in products) {
      final productCategoryIds = product.categoriesInstock.map((c) => c.id).toSet();
      if (productCategoryIds.intersection(categoryIds).isNotEmpty) {
        result.add(product);
      }
    }

    return result;
  }

  /// Преобразует дерево категорий в плоский список
  List<tree_category.Category> _flattenCategories(List<tree_category.Category> categories) {
    final result = <tree_category.Category>[];
    final seenIds = <int>{};

    void traverse(tree_category.Category category) {
      if (!seenIds.contains(category.id)) {
        seenIds.add(category.id);
        result.add(category);
      }
      for (final child in category.children) {
        traverse(child);
      }
    }

    for (final category in categories) {
      traverse(category);
    }

    return result;
  }
}