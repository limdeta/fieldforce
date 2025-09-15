import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getAllCategories();
  Future<Either<Failure, Category?>> getCategoryById(int id);
  Future<Either<Failure, void>> saveCategories(List<Category> categories);
  Future<Either<Failure, void>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(int id);
  Future<Either<Failure, List<Category>>> searchCategories(String query);
  Future<Either<Failure, List<Category>>> getSubcategories(int parentId);
  Future<Either<Failure, List<Category>>> getAllDescendants(int categoryId);
  Future<Either<Failure, List<Category>>> getAllAncestors(int categoryId);
}