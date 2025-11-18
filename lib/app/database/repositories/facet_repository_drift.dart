// lib/app/database/repositories/facet_repository_drift.dart

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/domain/repositories/facet_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

class DriftFacetRepository implements FacetRepository {
  DriftFacetRepository();

  final AppDatabase _database = GetIt.instance<AppDatabase>();
  final WarehouseFilterService _warehouseFilterService =
      GetIt.instance<WarehouseFilterService>();
  static final Logger _logger = Logger('DriftFacetRepository');

  @override
  Future<Either<Failure, List<FacetGroup>>> getFacetGroups(FacetFilter filter) async {
    try {
      final warehouseConstraint = await _resolveWarehouseConstraint();
      if (warehouseConstraint.shouldReturnEmpty) {
        _logger.info('Facet groups: нет складов для региона — возвращаем пустой список');
        return const Right(<FacetGroup>[]);
      }

      final parts = _FacetSqlBuilder.fromFilter(
        filter,
        warehouseIds: warehouseConstraint.warehouseIds,
      );
      if (parts.isEmptyResult) {
        return const Right([]);
      }

      final groups = <FacetGroup>[];

      final brandValues = await _fetchIntFacet(
        sql: '''
          SELECT 
            pf.brand_id AS value_id,
            pf.brand_name AS value_name,
            MAX(pf.brand_search_priority) AS priority,
            COUNT(*) AS value_count
          FROM product_facets pf
          ${parts.stockFilterJoin}
          ${parts.categoryFilterJoin}
          ${parts.whereClause}
            AND pf.brand_id IS NOT NULL
          GROUP BY pf.brand_id, pf.brand_name
          ORDER BY priority DESC, value_name ASC
        '''.trim(),
        parts: parts,
        selected: filter.brandIds,
      );
      if (brandValues.isNotEmpty) {
        groups.add(FacetGroup(
          key: 'brands',
          title: 'Бренды',
          type: FacetGroupType.list,
          values: brandValues,
        ));
      }

      final manufacturerValues = await _fetchIntFacet(
        sql: '''
          SELECT 
            pf.manufacturer_id AS value_id,
            pf.manufacturer_name AS value_name,
            COUNT(*) AS value_count
          FROM product_facets pf
          ${parts.stockFilterJoin}
          ${parts.categoryFilterJoin}
          ${parts.whereClause}
            AND pf.manufacturer_id IS NOT NULL
          GROUP BY pf.manufacturer_id, pf.manufacturer_name
          ORDER BY value_name ASC
        '''.trim(),
        parts: parts,
        selected: filter.manufacturerIds,
      );
      if (manufacturerValues.isNotEmpty) {
        groups.add(FacetGroup(
          key: 'manufacturers',
          title: 'Производители',
          type: FacetGroupType.list,
          values: manufacturerValues,
        ));
      }

      final seriesValues = await _fetchIntFacet(
        sql: '''
          SELECT 
            pf.series_id AS value_id,
            pf.series_name AS value_name,
            COUNT(*) AS value_count
          FROM product_facets pf
          ${parts.stockFilterJoin}
          ${parts.categoryFilterJoin}
          ${parts.whereClause}
            AND pf.series_id IS NOT NULL
          GROUP BY pf.series_id, pf.series_name
          ORDER BY value_name ASC
        '''.trim(),
        parts: parts,
        selected: filter.seriesIds,
      );
      if (seriesValues.isNotEmpty) {
        groups.add(FacetGroup(
          key: 'series',
          title: 'Серии',
          type: FacetGroupType.list,
          values: seriesValues,
        ));
      }

      final typeValues = await _fetchIntFacet(
        sql: '''
          SELECT 
            pf.type_id AS value_id,
            pf.type_name AS value_name,
            COUNT(*) AS value_count
          FROM product_facets pf
          ${parts.stockFilterJoin}
          ${parts.categoryFilterJoin}
          ${parts.whereClause}
            AND pf.type_id IS NOT NULL
          GROUP BY pf.type_id, pf.type_name
          ORDER BY value_name ASC
        '''.trim(),
        parts: parts,
        selected: filter.typeIds,
      );
      if (typeValues.isNotEmpty) {
        groups.add(FacetGroup(
          key: 'types',
          title: 'Тип товара',
          type: FacetGroupType.list,
          values: typeValues,
        ));
      }


      final noveltyCount = await _countFlag('novelty', parts);
      if (noveltyCount > 0) {
        groups.add(FacetGroup(
          key: 'novelty',
          title: 'Новинки',
          type: FacetGroupType.toggle,
          values: [
            FacetValue(
              value: true,
              label: 'Да',
              count: noveltyCount,
              selected: filter.onlyNovelty,
            ),
          ],
        ));
      }

      final popularCount = await _countFlag('popular', parts);
      if (popularCount > 0) {
        groups.add(FacetGroup(
          key: 'popular',
          title: 'Популярные',
          type: FacetGroupType.toggle,
          values: [
            FacetValue(
              value: true,
              label: 'Да',
              count: popularCount,
              selected: filter.onlyPopular,
            ),
          ],
        ));
      }

      return Right(groups);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка при расчёте фасетов', e, stackTrace);
      return Left(DatabaseFailure('Не удалось получить фасеты: $e'));
    }
  }

  Future<_WarehouseConstraint> _resolveWarehouseConstraint() async {
    try {
      final filterResult = await _warehouseFilterService.resolveForCurrentSession(
        bypassInDev: false,
      );

      if (filterResult.devBypass) {
        _logger.fine('Facets: dev режим — пропускаем фильтр складов');
        return const _WarehouseConstraint(warehouseIds: null);
      }

      if (filterResult.failure != null) {
        _logger.warning(
          'Facets: ошибка фильтра складов: ${filterResult.failure!.message}. Продолжаем без фильтрации.',
        );
        return const _WarehouseConstraint(warehouseIds: null);
      }

      if (!filterResult.hasWarehouses) {
        _logger.warning(
          'Facets: для региона ${filterResult.regionCode} не найдено складов. Возвращаем пустой набор.',
        );
        return const _WarehouseConstraint(warehouseIds: const <int>[], shouldReturnEmpty: true);
      }

      return _WarehouseConstraint(
        warehouseIds: List<int>.from(filterResult.warehouseIds),
      );
    } catch (error, stackTrace) {
      _logger.severe('Facets: ошибка определения фильтра складов', error, stackTrace);
      return const _WarehouseConstraint(warehouseIds: null);
    }
  }

  @override
  Future<Either<Failure, List<int>>> resolveProductCodes(FacetFilter filter) async {
    try {
      final warehouseConstraint = await _resolveWarehouseConstraint();
      if (warehouseConstraint.shouldReturnEmpty) {
        _logger.info('Facet codes: нет складов для региона — пустой список');
        return const Right(<int>[]);
      }

      final parts = _FacetSqlBuilder.fromFilter(
        filter,
        warehouseIds: warehouseConstraint.warehouseIds,
      );
      if (parts.isEmptyResult) {
        return const Right([]);
      }

      final joinClause = parts.requiresCategoryJoin
          ? 'INNER JOIN product_category_facets pcf ON pcf.product_code = pf.product_code'
          : '';

      final rows = await _database.customSelect(
        '''
        SELECT DISTINCT pf.product_code AS product_code
        FROM product_facets pf
        ${parts.stockFilterJoin}
        $joinClause
        ${parts.whereClause}
        ORDER BY pf.product_code ASC
        '''.trim(),
        variables: parts.buildVariables(),
        readsFrom: {
          _database.productFacets,
          if (parts.requiresCategoryJoin) _database.productCategoryFacets,
          if (parts.requiresStockJoin) _database.stockItems,
        },
      ).get();

      final codes = <int>[];
      for (final row in rows) {
        final code = row.data['product_code'] as int?;
        if (code != null) {
          codes.add(code);
        }
      }

      return Right(codes);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка вычисления кодов продуктов по фасетам', e, stackTrace);
      return Left(DatabaseFailure('Не удалось получить список товаров: $e'));
    }
  }

  Future<List<FacetValue>> _fetchIntFacet({
    required String sql,
    required _FacetSqlParts parts,
    required List<int> selected,
  }) async {
    final rows = await _database.customSelect(
      sql,
      variables: parts.buildVariables(),
      readsFrom: {
        _database.productFacets,
        if (parts.requiresCategoryJoin) _database.productCategoryFacets,
        if (parts.requiresStockJoin) _database.stockItems,
      },
    ).get();

    final values = <FacetValue>[];
    for (final row in rows) {
      final id = row.data['value_id'] as int?;
      final dynamic rawName = row.data['value_name'];
      final name = rawName?.toString();
      final count = (row.data['value_count'] as num?)?.toInt() ?? 0;
      if (id == null || name == null || count == 0) continue;

      values.add(FacetValue(
        value: id,
        label: name,
        count: count,
        selected: selected.contains(id),
      ));
    }
    return values;
  }


  Future<int> _countFlag(String column, _FacetSqlParts parts) async {
    final rows = await _database.customSelect(
      '''
      SELECT COUNT(*) AS cnt
      FROM product_facets pf
      ${parts.stockFilterJoin}
      ${parts.categoryFilterJoin}
      ${parts.whereClause}
        AND pf.$column = 1
      '''.trim(),
      variables: parts.buildVariables(),
      readsFrom: {
        _database.productFacets,
        if (parts.requiresCategoryJoin) _database.productCategoryFacets,
        if (parts.requiresStockJoin) _database.stockItems,
      },
    ).get();

    if (rows.isEmpty) return 0;
    return (rows.first.data['cnt'] as num?)?.toInt() ?? 0;
  }
}

class _FacetSqlParts {
  const _FacetSqlParts({
    required this.whereClause,
    required this.categoryFilterJoin,
    required this.stockFilterJoin,
    required this.arguments,
    required this.requiresCategoryJoin,
    required this.requiresStockJoin,
    required this.isEmptyResult,
  });

  final String whereClause;
  final String categoryFilterJoin;
  final String stockFilterJoin;
  final List<dynamic> arguments;
  final bool requiresCategoryJoin;
  final bool requiresStockJoin;
  final bool isEmptyResult;

  List<Variable> buildVariables() {
    return arguments.map((value) {
      if (value is int) return Variable<int>(value);
      if (value is bool) return Variable<bool>(value);
      if (value is String) return Variable<String>(value);
      if (value is num) return Variable<int>(value.toInt());
      throw UnsupportedError('Unsupported variable type: $value');
    }).toList();
  }
}

class _FacetSqlBuilder {
  static _FacetSqlParts fromFilter(
    FacetFilter filter, {
    List<int>? warehouseIds,
  }) {
    final where = StringBuffer('WHERE pf.can_buy = 1');
    final args = <dynamic>[];
    var requiresCategoryJoin = false;
    var requiresStockJoin = false;
    var stockJoinClause = '';

    if (warehouseIds != null) {
      if (warehouseIds.isEmpty) {
        return const _FacetSqlParts(
          whereClause: 'WHERE 1 = 0',
          categoryFilterJoin: '',
          stockFilterJoin: '',
          arguments: [],
          requiresCategoryJoin: false,
          requiresStockJoin: false,
          isEmptyResult: true,
        );
      }
      requiresStockJoin = true;
      stockJoinClause = '''
INNER JOIN (
  SELECT DISTINCT product_code
  FROM stock_items
  WHERE stock > 0 AND warehouse_id IN (${_placeholders(warehouseIds.length)})
) pf_stock ON pf_stock.product_code = pf.product_code
''';
      args.addAll(warehouseIds);
    }

    if (filter.restrictedProductCodes != null) {
      final codes = filter.restrictedProductCodes!;
      if (codes.isEmpty) {
        return _FacetSqlParts(
          whereClause: 'WHERE 1 = 0',
          categoryFilterJoin: '',
          stockFilterJoin: stockJoinClause,
          arguments: const [],
          requiresCategoryJoin: false,
          requiresStockJoin: requiresStockJoin,
          isEmptyResult: true,
        );
      }
      where.write(' AND pf.product_code IN (${_placeholders(codes.length)})');
      args.addAll(codes);
    }

    final categoryIds = filter.selectedCategoryIds.isNotEmpty
        ? filter.selectedCategoryIds
        : filter.scopeCategoryIds;
    if (categoryIds.isNotEmpty) {
      requiresCategoryJoin = true;
      where.write(' AND pcf.category_id IN (${_placeholders(categoryIds.length)})');
      args.addAll(categoryIds);
    }

    void addIntFilter(String column, List<int> values) {
      if (values.isEmpty) return;
      where.write(' AND $column IN (${_placeholders(values.length)})');
      args.addAll(values);
    }

    addIntFilter('pf.brand_id', filter.brandIds);
    addIntFilter('pf.manufacturer_id', filter.manufacturerIds);
    addIntFilter('pf.series_id', filter.seriesIds);
    addIntFilter('pf.type_id', filter.typeIds);

    if (filter.onlyNovelty) {
      where.write(' AND pf.novelty = 1');
    }
    if (filter.onlyPopular) {
      where.write(' AND pf.popular = 1');
    }

    final joinClause = requiresCategoryJoin
        ? 'INNER JOIN product_category_facets pcf ON pcf.product_code = pf.product_code'
        : '';

    return _FacetSqlParts(
      whereClause: where.toString(),
      categoryFilterJoin: joinClause,
      stockFilterJoin: stockJoinClause,
      arguments: args,
      requiresCategoryJoin: requiresCategoryJoin,
      requiresStockJoin: requiresStockJoin,
      isEmptyResult: false,
    );
  }
}

String _placeholders(int length) => List.filled(length, '?').join(', ');

class _WarehouseConstraint {
  const _WarehouseConstraint({
    required this.warehouseIds,
    this.shouldReturnEmpty = false,
  });

  final List<int>? warehouseIds;
  final bool shouldReturnEmpty;
}
