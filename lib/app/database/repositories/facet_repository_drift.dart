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

      // Phase 3.1: Динамические bool характеристики
      if (filter.hasFilteringContext) {
        final boolCharGroups = await _fetchBoolCharacteristics(parts, filter);
        groups.addAll(boolCharGroups);
      }

      return Right(groups);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка при расчёте фасетов', e, stackTrace);
      return Left(DatabaseFailure('Не удалось получить фасеты: $e'));
    }
  }

  Future<_WarehouseConstraint> _resolveWarehouseConstraint() async {
    try {
      final filterResult = await _warehouseFilterService.resolveForCurrentSession();

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

      // Phase 3.1: добавляем фильтрацию по характеристикам
      final charJoins = StringBuffer();
      final charVariables = <Variable>[];
      
      if (filter.selectedCharacteristics.isNotEmpty) {
        var charIndex = 0;
        for (final entry in filter.selectedCharacteristics.entries) {
          final attrId = entry.key;
          final values = entry.value;
          if (values.isEmpty) continue;
          
          final alias = 'pcf_char_$charIndex';
          charJoins.write('''
            INNER JOIN product_characteristic_facets $alias 
              ON $alias.product_code = pf.product_code 
              AND $alias.attribute_id = ? 
              AND $alias.char_type = 'bool' 
              AND $alias.bool_value IN (${_placeholders(values.length)})
          ''');
          charVariables.add(Variable.withInt(attrId));
          charVariables.addAll(values.map((v) => Variable.withInt(v == true ? 1 : 0)));
          charIndex++;
        }
      }

      // ВАЖНО: порядок переменных должен соответствовать порядку плейсхолдеров в SQL!
      // parts.arguments содержит: [warehouseIds..., categoryIds..., otherFilters...]
      // Нам нужно вставить charVariables между warehouseIds и остальными
      final partsVars = parts.buildVariables();
      final List<Variable> allVariables;
      
      if (charVariables.isEmpty) {
        allVariables = partsVars;
      } else {
        // Определяем сколько переменных для складов (если они есть)
        final warehouseCount = warehouseConstraint.warehouseIds?.length ?? 0;
        
        if (warehouseCount > 0) {
          // Переменные: [warehouse1, warehouse2, ..., <ВСТАВИТЬ CHAR>, category1, category2, ...]
          allVariables = [
            ...partsVars.sublist(0, warehouseCount),
            ...charVariables,
            ...partsVars.sublist(warehouseCount),
          ];
        } else {
          // Нет переменных для складов, вставляем char переменные в начало
          allVariables = [
            ...charVariables,
            ...partsVars,
          ];
        }
      }

      final sql = '''
        SELECT DISTINCT pf.product_code AS product_code
        FROM product_facets pf
        ${parts.stockFilterJoin}
        $joinClause
        $charJoins
        ${parts.whereClause}
        ORDER BY pf.product_code ASC
        '''.trim();

      _logger.info('resolveProductCodes SQL:\n$sql');
      _logger.info('resolveProductCodes variables: ${allVariables.map((v) => v.value).toList()}');
      _logger.info('resolveProductCodes selectedCharacteristics: ${filter.selectedCharacteristics}');

      final rows = await _database.customSelect(
        sql,
        variables: allVariables,
        readsFrom: {
          _database.productFacets,
          if (parts.requiresCategoryJoin) _database.productCategoryFacets,
          if (parts.requiresStockJoin) _database.stockItems,
          if (filter.selectedCharacteristics.isNotEmpty) _database.productCharacteristicFacets,
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

  /// Phase 3.1: Агрегация булевых характеристик для фасетов
  Future<List<FacetGroup>> _fetchBoolCharacteristics(
    _FacetSqlParts parts,
    FacetFilter filter,
  ) async {
    final sql = '''
      SELECT 
        pcf_char.attribute_id,
        pcf_char.attribute_name,
        pcf_char.bool_value,
        pcf_char.adapt_value,
        COUNT(*) AS value_count
      FROM product_characteristic_facets pcf_char
      INNER JOIN product_facets pf ON pf.product_code = pcf_char.product_code
      ${parts.stockFilterJoin}
      ${parts.categoryFilterJoin}
      ${parts.whereClause}
        AND pcf_char.char_type = 'bool'
      GROUP BY pcf_char.attribute_id, pcf_char.attribute_name, pcf_char.bool_value
      ORDER BY pcf_char.attribute_name, pcf_char.bool_value DESC
    '''.trim();

    final rows = await _database.customSelect(
      sql,
      variables: parts.buildVariables(),
      readsFrom: {
        _database.productCharacteristicFacets,
        _database.productFacets,
        if (parts.requiresCategoryJoin) _database.productCategoryFacets,
        if (parts.requiresStockJoin) _database.stockItems,
      },
    ).get();

    // Группируем по attributeId
    final Map<int, _CharacteristicAgg> grouped = {};
    for (final row in rows) {
      final attrId = row.data['attribute_id'] as int;
      final attrName = row.data['attribute_name'] as String;
      final boolValue = (row.data['bool_value'] as int?) == 1;
      final adaptValue = row.data['adapt_value'] as String?;
      final count = row.data['value_count'] as int;
      
      grouped.putIfAbsent(attrId, () => _CharacteristicAgg(attrId, attrName));
      grouped[attrId]!.values[boolValue] = _CharValue(
        boolValue ? (adaptValue ?? 'Да') : (adaptValue ?? 'Нет'),
        boolValue,
        count,
      );
    }

    // Преобразуем в FacetGroup
    final groups = <FacetGroup>[];
    for (final agg in grouped.values) {
      if (agg.values.isEmpty) continue;
      
      final selected = filter.selectedCharacteristics[agg.attributeId] ?? [];
      final values = agg.values.entries.map((e) {
        return FacetValue(
          value: e.key,
          label: e.value.label,
          count: e.value.count,
          selected: selected.contains(e.key),
        );
      }).toList();
      
      groups.add(FacetGroup(
        key: 'attr[${agg.attributeId}]',
        title: agg.attributeName,
        type: FacetGroupType.toggle,
        values: values,
      ));
    }

    return groups;
  }
}

/// Вспомогательный класс для группировки характеристик
class _CharacteristicAgg {
  final int attributeId;
  final String attributeName;
  final Map<bool, _CharValue> values = {};
  
  _CharacteristicAgg(this.attributeId, this.attributeName);
}

/// Вспомогательный класс для значения характеристики
class _CharValue {
  final String label;
  final bool value;
  final int count;
  
  _CharValue(this.label, this.value, this.count);
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
    final where = StringBuffer('WHERE 1 = 1');
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
