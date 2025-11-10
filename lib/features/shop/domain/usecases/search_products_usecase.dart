// lib/features/shop/domain/usecases/search_products_usecase.dart

import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// UseCase для полнотекстового поиска продуктов с FTS5
/// 
/// Использует FTS5 индекс для быстрого поиска по большим объёмам данных.
/// Поддерживает поиск по:
/// - title (название)
/// - code (внутренний код)
/// - barcodes (штрих-коды)
/// - vendorCode (артикул)
/// - brand.name (бренд)
/// 
/// Приоритеты ранжирования:
/// - 1000: Точное совпадение code или barcode
/// - 100: Title начинается с запроса
/// - 50: Title содержит запрос
/// - 30: VendorCode совпадает
/// - 20: Brand совпадает
/// - 10: FTS полнотекстовое совпадение
class SearchProductsUseCase {
  final ProductRepository _productRepository;

  SearchProductsUseCase(this._productRepository);

  /// Выполняет поиск продуктов
  /// 
  /// [query] - поисковый запрос (минимум 1 символ)
  /// [categoryId] - опциональный ID категории для фильтрации (null = поиск везде)
  /// [offset] - смещение для пагинации (по умолчанию 0)
  /// [limit] - максимальное количество результатов (по умолчанию 20)
  /// 
  /// Возвращает список продуктов отсортированных по релевантности
  Future<Either<Failure, List<Product>>> call({
    required String query,
    int? categoryId,
    int offset = 0,
    int limit = 20,
  }) async {
    // Проверка валидности запроса
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    // Выполняем FTS поиск через репозиторий
    return await _productRepository.searchProductsWithFts(
      query,
      categoryId: categoryId,
      offset: offset,
      limit: limit,
    );
  }
}
