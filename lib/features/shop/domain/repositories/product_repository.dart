// lib/features/shop/domain/repositories/product_repository.dart

import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/product.dart';
import '../entities/product_with_stock.dart';

abstract class ProductRepository {
  /// Получить все продукты
  Future<Either<Failure, List<Product>>> getAllProducts();

  /// Получить продукт по ID
  Future<Either<Failure, Product?>> getProductById(int id);

  /// Получить продукт по catalogId (ID из бекенда)  
  Future<Either<Failure, Product?>> getProductByCatalogId(int catalogId);

  /// Получить продукт по коду товара
  Future<Either<Failure, Product?>> getProductByCode(int code);

  /// Получить продукт с информацией о складских остатках по коду товара
  Future<Either<Failure, ProductWithStock?>> getProductWithStockByCode(int code, String vendorId);

  /// Получить продукты по категории с пагинацией
  Future<Either<Failure, List<Product>>> getProductsByCategoryPaginated(int categoryId, {int offset = 0, int limit = 20});

  /// Получить продукты по категории с информацией об остатках
  Future<Either<Failure, List<ProductWithStock>>> getProductsWithStockByCategoryPaginated(
    int categoryId, {
    String? vendorId,
    int offset = 0,
    int limit = 20,
  });

  /// Получить продукты по типу с пагинацией
  Future<Either<Failure, List<Product>>> getProductsByTypePaginated(int typeId, {int offset = 0, int limit = 20});

  /// Поиск продуктов с пагинацией
  Future<Either<Failure, List<Product>>> searchProductsPaginated(String query, {int offset = 0, int limit = 20});

  /// Полнотекстовый поиск продуктов с FTS5 и ранжированием
  /// Поддерживает поиск по: title, code, barcode, vendorCode, brand
  /// Приоритеты: точное совпадение code/barcode > начало title > содержит title
  /// 
  /// [query] - поисковый запрос
  /// [categoryId] - опциональный ID категории для фильтрации (null = поиск везде)
  /// [offset] - смещение для пагинации
  /// [limit] - лимит результатов
  Future<Either<Failure, List<Product>>> searchProductsWithFts(
    String query, {
    int? categoryId,
    int offset = 0,
    int limit = 20,
  });

  /// Сохранить продукты
  Future<Either<Failure, void>> saveProducts(List<Product> products);

  /// Обновить продукт
  Future<Either<Failure, void>> updateProduct(Product product);

  /// Удалить продукт
  Future<Either<Failure, void>> deleteProduct(int catalogId);

  /// Удалить все продукты
  Future<Either<Failure, void>> deleteAllProducts();

  /// Получить продукты с акциями
  Future<Either<Failure, List<Product>>> getProductsWithPromotions();

  /// Получить популярные продукты
  Future<Either<Failure, List<Product>>> getPopularProducts();

  /// Получить новинки
  Future<Either<Failure, List<Product>>> getNoveltyProducts();

  /// Получить количество продуктов
  Future<Either<Failure, int>> getProductsCount();

  /// Получить количество продуктов в категории
  Future<Either<Failure, int>> getProductsCountByCategory(int categoryId);
}