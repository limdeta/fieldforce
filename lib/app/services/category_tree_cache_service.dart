import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

class CategoryTreeCacheService {
  static final Logger _logger = Logger('CategoryTreeCacheService');

  final CategoryRepository _categoryRepository;
  final WarehouseFilterService _warehouseFilterService;
  final Duration _cacheDuration;

  final Map<String, _CategoryCacheEntry> _cache = {};

  CategoryTreeCacheService({
    CategoryRepository? categoryRepository,
    WarehouseFilterService? warehouseFilterService,
    Duration cacheDuration = const Duration(hours: 3),
  })  : _categoryRepository = categoryRepository ?? GetIt.instance<CategoryRepository>(),
        _warehouseFilterService = warehouseFilterService ?? GetIt.instance<WarehouseFilterService>(),
        _cacheDuration = cacheDuration;

  Future<Either<Failure, List<Category>>> getTreeForCurrentRegion({bool forceRefresh = false}) async {
    final filterResult = await _warehouseFilterService.resolveForCurrentSession(bypassInDev: false);
    final regionCode = filterResult.regionCode.isNotEmpty
        ? filterResult.regionCode
        : AppConfig.defaultRegionCode;

    return getTreeForRegion(regionCode, forceRefresh: forceRefresh);
  }

  Future<Either<Failure, List<Category>>> getTreeForRegion(
    String regionCode, {
    bool forceRefresh = false,
  }) async {
    final normalizedRegion = regionCode.trim().toUpperCase();
    final now = DateTime.now();

    final cached = _cache[normalizedRegion];
    if (!forceRefresh && cached != null && cached.expiresAt.isAfter(now)) {
      _logger.fine('Возвращаем кэшированное дерево категорий для региона $normalizedRegion');
      return Right(_cloneCategories(cached.categories));
    }

    final categoriesResult = await _categoryRepository.getAllCategories();
    if (categoriesResult.isLeft()) {
      Failure? failure;
      categoriesResult.fold((f) {
        failure = f;
        return null;
      }, (_) => null);

      failure ??= GeneralFailure('Неизвестная ошибка получения категорий');
      _logger.warning('Не удалось загрузить категории для региона $normalizedRegion: ${failure!.message}');
      return Left(failure!);
    }

    final categories = categoriesResult.getOrElse(() => []);

    final countsResult = await _categoryRepository.updateCategoryCountsForRegion(
      categories,
      normalizedRegion,
    );

    if (countsResult.isLeft()) {
      Failure? failure;
      countsResult.fold((f) {
        failure = f;
        return null;
      }, (_) => null);

      failure ??= GeneralFailure('Неизвестная ошибка пересчета категорий');
      _logger.warning('Не удалось пересчитать дерево категорий для региона $normalizedRegion: ${failure!.message}');
      return Left(failure!);
    }

    final cachedCopy = _cloneCategories(categories);
    _cache[normalizedRegion] = _CategoryCacheEntry(
      categories: cachedCopy,
      expiresAt: now.add(_cacheDuration),
    );

    return Right(_cloneCategories(categories));
  }

  Future<Either<Failure, List<Category>>> refreshRegion(String regionCode) {
    return getTreeForRegion(regionCode, forceRefresh: true);
  }

  Future<Either<Failure, List<Category>>> refreshCurrentRegion() async {
    return getTreeForCurrentRegion(forceRefresh: true);
  }

  /// Фоновое прогревание кеша категорий для текущего региона
  /// 
  /// В отличие от `getTreeForCurrentRegion()`, этот метод:
  /// - Выполняется асинхронно (fire-and-forget)
  /// - Не выбрасывает ошибки в UI
  /// - Просто логирует результат
  /// 
  /// Использовать при старте приложения и после импорта остатков.
  Future<void> warmupCache() async {
    _logger.info('Начинаем фоновое прогревание кеша категорий...');
    
    try {
      final result = await getTreeForCurrentRegion(forceRefresh: true);
      
      result.fold(
        (failure) {
          _logger.warning('Прогрев кеша категорий не удался: ${failure.message}');
        },
        (categories) {
          final totalCount = categories.fold<int>(0, (sum, cat) => sum + cat.count);
          _logger.info('Кеш категорий прогрет: ${categories.length} корневых категорий, $totalCount товаров с остатками');
        },
      );
    } catch (e, st) {
      _logger.warning('Исключение при прогреве кеша категорий', e, st);
    }
  }

  void invalidateRegion(String regionCode) {
    final normalizedRegion = regionCode.trim().toUpperCase();
    _cache.remove(normalizedRegion);
  }

  void clear() {
    _cache.clear();
  }

  List<Category> _cloneCategories(List<Category> categories) {
    return categories.map(_cloneCategory).toList();
  }

  Category _cloneCategory(Category category) {
    return Category(
      id: category.id,
      name: category.name,
      lft: category.lft,
      lvl: category.lvl,
      rgt: category.rgt,
      description: category.description,
      query: category.query,
      count: category.count,
      children: _cloneCategories(category.children),
    );
  }
}

class _CategoryCacheEntry {
  final List<Category> categories;
  final DateTime expiresAt;

  _CategoryCacheEntry({
    required this.categories,
    required this.expiresAt,
  });
}
