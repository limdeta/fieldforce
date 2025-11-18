// lib/features/shop/domain/usecases/search_products_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query_result.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

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

  /// Выполняет поиск продуктов c использованием единого pipeline `ProductQuery`.
  Future<Either<Failure, ProductQueryResult<ProductWithStock>>> call(
    ProductQuery query,
  ) async {
    final bool hasFacetRestrictions = query.allowedProductCodes != null ||
        query.brandIds.isNotEmpty ||
        query.manufacturerIds.isNotEmpty ||
        query.seriesIds.isNotEmpty ||
        query.productTypeIds.isNotEmpty ||
        query.priceCategoryIds.isNotEmpty ||
        query.onlyNovelty ||
        query.onlyPopular;

    if (!query.hasSearchText && !hasFacetRestrictions) {
      return Right(ProductQueryResult<ProductWithStock>.empty(query));
    }

    final normalized = await _expandCategoryScope(query.copyWith(requireStock: false));
    return _productRepository.getProducts(normalized);
  }

  Future<ProductQuery> _expandCategoryScope(ProductQuery query) async {
    if (query.scopedCategoryIds.isNotEmpty || query.baseCategoryId == null) {
      return query;
    }

    final descendantsResult = await _categoryRepository.getAllDescendants(query.baseCategoryId!);

    if (descendantsResult.isLeft()) {
      _logger.warning('Не удалось получить потомков категории ${query.baseCategoryId}, поиск только в ней');
      return query.copyWith(scopedCategoryIds: <int>[query.baseCategoryId!]);
    }

    final descendants = descendantsResult.getOrElse(() => <Category>[]);
    final scoped = <int>{query.baseCategoryId!};
    scoped.addAll(descendants.map((c) => c.id));
    _logger.fine('Поиск в категории ${query.baseCategoryId} + ${descendants.length} потомков (всего ${scoped.length} категорий)');
    return query.copyWith(scopedCategoryIds: scoped.toList(growable: false));
  }
}
