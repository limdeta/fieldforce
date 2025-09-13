import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/category.dart';

/// Репозиторий для работы с категориями товаров
abstract class CategoryRepository {
  /// Получить все категории (дерево)
  Future<Either<Failure, List<Category>>> getAllCategories();

  /// Получить категорию по ID
  Future<Either<Failure, Category?>> getCategoryById(int id);

  /// Сохранить дерево категорий (из JSON)
  Future<Either<Failure, void>> saveCategories(List<Category> categories);

  /// Обновить категорию
  Future<Either<Failure, void>> updateCategory(Category category);

  /// Удалить категорию
  Future<Either<Failure, void>> deleteCategory(int id);

  /// Поиск категорий по имени
  Future<Either<Failure, List<Category>>> searchCategories(String query);

  /// Получить подкатегории для категории
  Future<Either<Failure, List<Category>>> getSubcategories(int parentId);
}