// lib/features/shop/domain/usecases/search_products_usecase.dart

import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../repositories/category_repository.dart';

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
/// 
/// При поиске в категории автоматически включает все дочерние категории (листья),
/// т.к. продукты привязаны только к листовым категориям через categoriesInstock.
class SearchProductsUseCase {
  static final Logger _logger = Logger('SearchProductsUseCase');
  
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  SearchProductsUseCase(this._productRepository, this._categoryRepository);

  /// Выполняет поиск продуктов
  /// 
  /// [query] - поисковый запрос (минимум 1 символ)
  /// [categoryId] - опциональный ID категории для фильтрации (null = поиск везде)
  ///                Если категория родительская, автоматически включаются все дочерние категории
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

    // Если категория указана, получаем все её дочерние категории (листья)
    // т.к. продукты привязаны только к листовым категориям через categoriesInstock
    List<int>? categoryIds;
    if (categoryId != null) {
      final descendantsResult = await _categoryRepository.getAllDescendants(categoryId);
      
      if (descendantsResult.isLeft()) {
        _logger.warning('Не удалось получить потомков категории $categoryId, поиск только в ней');
        categoryIds = [categoryId];
      } else {
        final descendants = descendantsResult.getOrElse(() => []);
        // Включаем саму категорию + все дочерние
        categoryIds = [categoryId, ...descendants.map((c) => c.id)];
        _logger.fine('Поиск в категории $categoryId + ${descendants.length} потомков (всего ${categoryIds.length} категорий)');
      }
    }

    // Выполняем FTS поиск через репозиторий
    return await _productRepository.searchProductsWithFts(
      query,
      categoryIds: categoryIds,
      offset: offset,
      limit: limit,
    );
  }
}
