// lib/features/shop/domain/repositories/product_repository.dart

import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/product.dart';
import '../entities/product_query.dart';
import '../entities/product_query_result.dart';
import '../entities/product_with_stock.dart';

abstract class ProductRepository {
  /// Получить все продукты
  Future<Either<Failure, List<Product>>> getAllProducts();

  /// Получить продукт по ID
  Future<Either<Failure, Product?>> getProductById(int id);

  /// Получить продукт по коду товара
  Future<Either<Failure, Product?>> getProductByCode(int code);

  /// Получить продукт с информацией о складских остатках по коду товара
  Future<Either<Failure, ProductWithStock?>> getProductWithStockByCode(int code, String vendorId);

  /// Универсальный вход для каталога/поиска. Поддерживает те же фильтры,
  /// что и backend FilterService, и возвращает пагинацию вместе с данными.
  Future<Either<Failure, ProductQueryResult<ProductWithStock>>> getProducts(ProductQuery query);

  /// Полнотекстовый поиск продуктов с FTS5 и ранжированием
  /// Поддерживает поиск по: title, code, barcode, vendorCode, brand
  /// Приоритеты: точное совпадение code/barcode > начало title > содержит title
  /// 
  /// [query] - поисковый запрос
  /// [categoryIds] - опциональный список ID категорий для фильтрации (null = поиск везде)
  ///                 Поддерживает поиск в нескольких категориях одновременно (для nested tree)
  /// [offset] - смещение для пагинации
  /// [limit] - лимит результатов
  Future<Either<Failure, List<Product>>> searchProductsWithFts(
    String query, {
    List<int>? categoryIds,
    int offset = 0,
    int limit = 20,
    List<int>? allowedProductCodes,
  });

  /// Сохранить продукты
  Future<Either<Failure, void>> saveProducts(List<Product> products);

  /// Обновить продукт
  Future<Either<Failure, void>> updateProduct(Product product);

  /// Удалить продукт по коду
  Future<Either<Failure, void>> deleteProduct(int code);

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