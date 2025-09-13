import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';
import '../../../features/shop/domain/entities/category.dart';
import '../../../features/shop/domain/repositories/category_repository.dart';

/// Drift реализация репозитория категорий
class DriftCategoryRepository implements CategoryRepository {
  final AppDatabase _database = GetIt.instance<AppDatabase>();

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final entities = await _database.select(_database.categories).get();
      final categories = <Category>[];

      for (final entity in entities) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        final category = Category.fromJson(categoryJson);
        categories.add(category);
      }

      // Построить дерево из плоского списка
      final rootCategories = categories.where((c) => c.lvl == 1).toList();
      return Right(rootCategories);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения категорий: $e'));
    }
  }

  @override
  Future<Either<Failure, Category?>> getCategoryById(int id) async {
    try {
      final entity = await (_database.select(_database.categories)
        ..where((tbl) => tbl.categoryId.equals(id))
      ).getSingleOrNull();

      if (entity == null) return const Right(null);

      final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
      final category = Category.fromJson(categoryJson);
      return Right(category);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения категории: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCategories(List<Category> categories) async {
    try {
      await _database.transaction(() async {
        // Очистить существующие категории
        await _database.delete(_database.categories).go();

        // Сохранить новые
        for (final category in categories) {
          await _saveCategoryRecursive(category, null);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка сохранения категорий: $e'));
    }
  }

  Future<void> _saveCategoryRecursive(Category category, int? parentId) async {
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
      await _saveCategoryRecursive(child, insertedId);
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
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
  Future<Either<Failure, List<Category>>> searchCategories(String query) async {
    try {
      final entities = await (_database.select(_database.categories)
        ..where((tbl) => tbl.name.contains(query))
      ).get();

      final categories = entities.map((entity) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Category.fromJson(categoryJson);
      }).toList();

      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка поиска категорий: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getSubcategories(int parentId) async {
    try {
      final entities = await (_database.select(_database.categories)
        ..where((tbl) => tbl.parentId.equals(parentId))
      ).get();

      final categories = entities.map((entity) {
        final categoryJson = jsonDecode(entity.rawJson) as Map<String, dynamic>;
        return Category.fromJson(categoryJson);
      }).toList();

      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения подкатегорий: $e'));
    }
  }
}