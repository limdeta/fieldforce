import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query_result.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Use case that prepares a [ProductQuery] for category listings (descendants,
/// pagination) and delegates execution to the repository pipeline.
class GetCategoryProductsUseCase {
  static final Logger _logger = Logger('GetCategoryProductsUseCase');

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  GetCategoryProductsUseCase(this._productRepository, this._categoryRepository);

  Future<Either<Failure, ProductQueryResult<ProductWithStock>>> call(
    ProductQuery query,
  ) async {
    if (query.baseCategoryId == null && query.scopedCategoryIds.isEmpty) {
      _logger.warning('Category query выполнен без категории — возвращаем пустой результат');
      return Right(ProductQueryResult<ProductWithStock>.empty(query));
    }

    final normalizedQuery = await _expandCategoryScope(query);
    return _productRepository.getProducts(normalizedQuery);
  }

  Future<ProductQuery> _expandCategoryScope(ProductQuery query) async {
    if (query.scopedCategoryIds.isNotEmpty || query.baseCategoryId == null) {
      return query;
    }

    final descendantsResult = await _categoryRepository.getAllDescendants(query.baseCategoryId!);
    if (descendantsResult.isLeft()) {
      _logger.warning('Не удалось получить потомков категории ${query.baseCategoryId}, используем только её значения');
      return query.copyWith(scopedCategoryIds: <int>[query.baseCategoryId!]);
    }

    final descendants = descendantsResult.getOrElse(() => <Category>[]);
    final scoped = <int>{query.baseCategoryId!};
    scoped.addAll(descendants.map((c) => c.id));
    return query.copyWith(scopedCategoryIds: scoped.toList(growable: false));
  }
}
