# Phase 3.2 & 3.3 — String и Numeric Характеристики

## Статус Phase 3.1 (Bool Characteristics)
✅ **Завершено и протестировано**
- Database schema с `product_characteristic_facets`
- Sync логика для bool характеристик
- Repository агрегация с контекстом
- Фильтрация `resolveProductCodes`
- UI интеграция через `FacetFilterBloc`
- Багфиксы: SQL syntax, alias конфликты, порядок переменных, Apply button

## План дальнейшего развития

---

## Phase 3.2 — String Characteristics

### Что такое String Characteristics

```dart
// Пример: характеристика "Цвет"
Characteristic(
  attributeId: 25,           // ID атрибута "Цвет"
  attributeName: "Цвет",
  id: 1234,                  // ID конкретного значения "Красный"
  type: "string",
  value: 1234,               // int - ссылка на ID значения
  adaptValue: "Красный",     // человекочитаемое название
);
```

### Отличия от Bool

| Аспект | Bool | String |
|--------|------|--------|
| **Тип значения** | true/false | int (ID из справочника) |
| **Количество вариантов** | 2 (Да/Нет) | Может быть 10-100+ значений |
| **UI тип** | Toggle | List с чекбоксами |
| **Проблема производительности** | Нет | Да - нужна пагинация/поиск |

### Технические задачи

#### 1. Расширение sync логики

**Файл**: `lib/app/database/repositories/product_repository_drift.dart`

```dart
// В методе _upsertFacetData() добавить обработку stringCharacteristics
Future<void> _upsertFacetData(Product product) async {
  // ...existing bool logic...
  
  // String characteristics
  for (final char in product.stringCharacteristics) {
    companions.add(ProductCharacteristicFacetCompanion.insert(
      productCode: product.code,
      attributeId: char.attributeId,
      attributeName: char.attributeName,
      charType: 'string',
      stringValue: Value(char.value as int),  // ID значения
      adaptValue: Value(char.adaptValue),     // "Красный", "500 мл" и т.д.
    ));
  }
}
```

#### 2. Агрегация в Repository

**Файл**: `lib/app/database/repositories/facet_repository_drift.dart`

Добавить метод `_fetchStringCharacteristics()`:

```dart
Future<List<FacetGroup>> _fetchStringCharacteristics(
  _FacetSqlParts parts,
  FacetFilter filter,
) async {
  if (!filter.hasFilteringContext) return [];

  // ВАЖНО: может быть много значений (цвета, размеры)
  // Ограничиваем топ-20 значений на атрибут
  final sql = '''
    WITH ranked_values AS (
      SELECT 
        pcf.attribute_id,
        pcf.attribute_name,
        pcf.string_value,
        pcf.adapt_value,
        COUNT(*) AS value_count,
        ROW_NUMBER() OVER (
          PARTITION BY pcf.attribute_id 
          ORDER BY COUNT(*) DESC
        ) AS rn
      FROM product_characteristic_facets pcf
      INNER JOIN product_facets pf ON pf.product_code = pcf.product_code
      ${parts.stockFilterJoin}
      ${parts.categoryFilterJoin}
      ${parts.whereClause}
        AND pcf.char_type = 'string'
        AND pcf.string_value IS NOT NULL
      GROUP BY pcf.attribute_id, pcf.attribute_name, pcf.string_value, pcf.adapt_value
    )
    SELECT 
      attribute_id,
      attribute_name,
      string_value,
      adapt_value,
      value_count
    FROM ranked_values
    WHERE rn <= 20
    ORDER BY attribute_name, value_count DESC
  ''';

  final rows = await _database.customSelect(
    sql.trim(),
    variables: parts.buildVariables(),
    readsFrom: {
      _database.productCharacteristicFacets,
      _database.productFacets,
      if (parts.requiresCategoryJoin) _database.productCategoryFacets,
      if (parts.requiresStockJoin) _database.stockItems,
    },
  ).get();

  // Группируем по attributeId
  final Map<int, _StringCharacteristicAgg> grouped = {};
  for (final row in rows) {
    final attrId = row.data['attribute_id'] as int;
    final attrName = row.data['attribute_name'] as String;
    final stringValue = row.data['string_value'] as int;
    final adaptValue = row.data['adapt_value'] as String;
    final count = row.data['value_count'] as int;
    
    grouped.putIfAbsent(
      attrId, 
      () => _StringCharacteristicAgg(attrId, attrName),
    );
    grouped[attrId]!.addValue(stringValue, adaptValue, count);
  }

  // Преобразуем в FacetGroup
  final groups = <FacetGroup>[];
  for (final agg in grouped.values) {
    if (agg.values.isEmpty) continue;
    
    final selected = filter.selectedCharacteristics[agg.attributeId] ?? [];
    final values = agg.values.map((v) {
      return FacetValue(
        value: v.stringValue,
        label: v.adaptValue,
        count: v.count,
        selected: selected.contains(v.stringValue),
      );
    }).toList();
    
    groups.add(FacetGroup(
      key: 'attr[${agg.attributeId}]',
      title: agg.attributeName,
      type: FacetGroupType.list,  // ← мультивыбор как для brands
      values: values,
    ));
  }

  return groups;
}

class _StringCharacteristicAgg {
  final int attributeId;
  final String attributeName;
  final List<_StringCharValue> values = [];
  
  _StringCharacteristicAgg(this.attributeId, this.attributeName);
  
  void addValue(int stringValue, String adaptValue, int count) {
    values.add(_StringCharValue(stringValue, adaptValue, count));
  }
}

class _StringCharValue {
  final int stringValue;
  final String adaptValue;
  final int count;
  _StringCharValue(this.stringValue, this.adaptValue, this.count);
}
```

#### 3. Обновление getFacetGroups

```dart
@override
Future<Either<Failure, List<FacetGroup>>> getFacetGroups(FacetFilter filter) async {
  try {
    // ...existing static facets...
    
    // Dynamic characteristics
    if (filter.hasFilteringContext) {
      final boolCharGroups = await _fetchBoolCharacteristics(parts, filter);
      groups.addAll(boolCharGroups);
      
      // NEW: String characteristics
      final stringCharGroups = await _fetchStringCharacteristics(parts, filter);
      groups.addAll(stringCharGroups);
    }
    
    return Right(groups);
  } catch (e, stackTrace) {
    _logger.severe('Ошибка при расчёте фасетов', e, stackTrace);
    return Left(DatabaseFailure('Не удалось получить фасеты: $e'));
  }
}
```

#### 4. Фильтрация в resolveProductCodes

В методе `resolveProductCodes()` уже есть обработка `selectedCharacteristics`. Нужно расширить логику для string:

```dart
// В цикле по filter.selectedCharacteristics.entries
if (filter.selectedCharacteristics.isNotEmpty) {
  var charIndex = 0;
  for (final entry in filter.selectedCharacteristics.entries) {
    final attrId = entry.key;
    final values = entry.value;
    if (values.isEmpty) continue;
    
    final alias = 'pcf_char_$charIndex';
    
    // Определяем тип характеристики по значениям
    final isBool = values.first is bool;
    final isString = values.first is int;
    
    if (isBool) {
      charJoins.write('''
        INNER JOIN product_characteristic_facets $alias 
          ON $alias.product_code = pf.product_code 
          AND $alias.attribute_id = ? 
          AND $alias.char_type = 'bool' 
          AND $alias.bool_value IN (${_placeholders(values.length)})
      ''');
      charVariables.add(Variable.withInt(attrId));
      charVariables.addAll(values.map((v) => Variable.withInt(v == true ? 1 : 0)));
    } else if (isString) {
      // NEW: обработка string характеристик
      charJoins.write('''
        INNER JOIN product_characteristic_facets $alias 
          ON $alias.product_code = pf.product_code 
          AND $alias.attribute_id = ? 
          AND $alias.char_type = 'string' 
          AND $alias.string_value IN (${_placeholders(values.length)})
      ''');
      charVariables.add(Variable.withInt(attrId));
      charVariables.addAll(values.map((v) => Variable.withInt(v as int)));
    }
    
    charIndex++;
  }
}
```

#### 5. UI изменения

**Минимальны!** `FacetGroupType.list` уже существует и используется для brands/categories.

Потенциальное улучшение для будущего:
```dart
// Если значений > 20, показать кнопку "Показать ещё"
if (group.values.length >= 20) {
  // UI hint что показаны не все значения
  return Column(
    children: [
      ...group.values.map((v) => CheckboxListTile(...)),
      TextButton(
        onPressed: () => _showAllValues(context, group),
        child: Text('Показать все значения'),
      ),
    ],
  );
}
```

#### 6. Тестовые данные

**Файл**: `lib/features/shop/data/fixtures/product_fixture_service.dart`

```dart
// Добавить в _createTestProducts():
{
  'code': 1001,
  // ...existing fields...
  'stringCharacteristics': [
    {
      'attributeId': 25,
      'attributeName': 'Цвет',
      'id': 1001,
      'type': 'string',
      'value': 1001,  // ID значения "Красный"
      'adaptValue': 'Красный',
    },
    {
      'attributeId': 26,
      'attributeName': 'Размер',
      'id': 2001,
      'type': 'string',
      'value': 2001,  // ID значения "Средний"
      'adaptValue': 'Средний',
    },
  ],
},
{
  'code': 1002,
  'stringCharacteristics': [
    {
      'attributeId': 25,
      'attributeName': 'Цвет',
      'id': 1002,
      'type': 'string',
      'value': 1002,  // ID значения "Синий"
      'adaptValue': 'Синий',
    },
    {
      'attributeId': 26,
      'attributeName': 'Размер',
      'id': 2002,
      'type': 'string',
      'value': 2002,  // ID значения "Большой"
      'adaptValue': 'Большой',
    },
  ],
},
```

### Риски Phase 3.2

**Риск 1: Слишком много значений для одного атрибута**
- Цвета: может быть 50+ оттенков
- Решение: TOP 20 по популярности + "Показать ещё"

**Риск 2: Производительность ROW_NUMBER()**
- SQLite может медленно работать с window functions на больших датасетах
- Решение: EXPLAIN QUERY PLAN, возможно упростить до простого LIMIT

**Риск 3: UI становится перегруженным**
- 5+ string характеристик по 20 значений = 100+ чекбоксов
- Решение: Сворачиваемые секции, показывать только TOP-3 характеристики

### Оценка Phase 3.2
**Время**: 2-3 дня
- Sync логика: 2 часа (копипаста с bool)
- Repository aggregation: 4-6 часов (сложнее из-за TOP-N)
- Фильтрация: 2 часа (расширение существующего кода)
- Тестовые данные: 1 час
- Тестирование: 4-6 часов

---

## Phase 3.3 — Numeric Characteristics

### Что такое Numeric Characteristics

```dart
// Пример: характеристика "Объем"
Characteristic(
  attributeId: 30,
  attributeName: "Объем",
  id: 3001,
  type: "numeric",
  value: 500.0,              // double - сырое значение
  adaptValue: "500 мл",      // человекочитаемое
);
```

### Отличия от String/Bool

| Аспект | String | Numeric |
|--------|--------|---------|
| **Тип значения** | int (ID) | double (число) |
| **Количество уникальных** | 10-50 | Может быть 100+ (499.5, 500.0, 500.3) |
| **UI тип** | List чекбоксов | Range slider / диапазоны |
| **Агрегация** | GROUP BY value | Нужны диапазоны (buckets) |

### Стратегия: Диапазоны (Buckets)

Вместо показа всех уникальных значений (500.0, 500.1, 500.2...) группируем в диапазоны:
- "До 100 мл" (0-100)
- "100-500 мл" (100-500)
- "500-1000 мл" (500-1000)
- "Больше 1000 мл" (1000+)

### Технические задачи

#### 1. Расширение sync логики

```dart
// В _upsertFacetData()
for (final char in product.numericCharacteristics) {
  companions.add(ProductCharacteristicFacetCompanion.insert(
    productCode: product.code,
    attributeId: char.attributeId,
    attributeName: char.attributeName,
    charType: 'numeric',
    numericValue: Value(char.value as double),
    adaptValue: Value(char.adaptValue),
  ));
}
```

#### 2. Вычисление MIN/MAX для создания buckets

```dart
Future<List<FacetGroup>> _fetchNumericCharacteristics(
  _FacetSqlParts parts,
  FacetFilter filter,
) async {
  if (!filter.hasFilteringContext) return [];

  // Шаг 1: Получить MIN/MAX для каждого атрибута
  final rangesSql = '''
    SELECT 
      pcf.attribute_id,
      pcf.attribute_name,
      MIN(pcf.numeric_value) AS min_val,
      MAX(pcf.numeric_value) AS max_val,
      COUNT(DISTINCT pcf.product_code) AS total_count
    FROM product_characteristic_facets pcf
    INNER JOIN product_facets pf ON pf.product_code = pcf.product_code
    ${parts.stockFilterJoin}
    ${parts.categoryFilterJoin}
    ${parts.whereClause}
      AND pcf.char_type = 'numeric'
      AND pcf.numeric_value IS NOT NULL
    GROUP BY pcf.attribute_id, pcf.attribute_name
    HAVING COUNT(DISTINCT pcf.product_code) > 0
  ''';

  final rangesRows = await _database.customSelect(
    rangesSql.trim(),
    variables: parts.buildVariables(),
    readsFrom: {
      _database.productCharacteristicFacets,
      _database.productFacets,
      if (parts.requiresCategoryJoin) _database.productCategoryFacets,
      if (parts.requiresStockJoin) _database.stockItems,
    },
  ).get();

  if (rangesRows.isEmpty) return [];

  final groups = <FacetGroup>[];
  
  for (final row in rangesRows) {
    final attrId = row.data['attribute_id'] as int;
    final attrName = row.data['attribute_name'] as String;
    final minVal = row.data['min_val'] as double;
    final maxVal = row.data['max_val'] as double;
    final totalCount = row.data['total_count'] as int;
    
    // Создаём диапазоны (buckets)
    final buckets = _createBuckets(minVal, maxVal);
    
    // Шаг 2: Подсчитываем товары в каждом диапазоне
    final bucketCounts = await _countProductsInBuckets(
      attrId, 
      buckets, 
      parts,
    );
    
    // Формируем FacetValue для каждого диапазона
    final values = <FacetValue>[];
    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      final count = bucketCounts[i];
      if (count == 0) continue;
      
      values.add(FacetValue(
        value: {'min': bucket.min, 'max': bucket.max}, // Map как value
        label: bucket.label,
        count: count,
        selected: false, // TODO: проверка выбранного диапазона
      ));
    }
    
    if (values.isEmpty) continue;
    
    groups.add(FacetGroup(
      key: 'attr[${attrId}]',
      title: attrName,
      type: FacetGroupType.range,  // NEW TYPE!
      values: values,
    ));
  }
  
  return groups;
}

List<_NumericBucket> _createBuckets(double minVal, double maxVal) {
  // Простая стратегия: 5 равных диапазонов
  final range = maxVal - minVal;
  final step = range / 5;
  
  final buckets = <_NumericBucket>[];
  for (var i = 0; i < 5; i++) {
    final bucketMin = minVal + (step * i);
    final bucketMax = (i == 4) ? maxVal : (minVal + (step * (i + 1)));
    
    buckets.add(_NumericBucket(
      min: bucketMin,
      max: bucketMax,
      label: '${bucketMin.toStringAsFixed(0)} - ${bucketMax.toStringAsFixed(0)}',
    ));
  }
  
  return buckets;
}

Future<List<int>> _countProductsInBuckets(
  int attrId,
  List<_NumericBucket> buckets,
  _FacetSqlParts parts,
) async {
  // Для каждого bucket делаем COUNT с WHERE между min и max
  final counts = <int>[];
  
  for (final bucket in buckets) {
    final sql = '''
      SELECT COUNT(DISTINCT pcf.product_code) AS cnt
      FROM product_characteristic_facets pcf
      INNER JOIN product_facets pf ON pf.product_code = pcf.product_code
      ${parts.stockFilterJoin}
      ${parts.categoryFilterJoin}
      ${parts.whereClause}
        AND pcf.attribute_id = ?
        AND pcf.char_type = 'numeric'
        AND pcf.numeric_value >= ?
        AND pcf.numeric_value < ?
    ''';
    
    final variables = [
      ...parts.buildVariables(),
      Variable.withInt(attrId),
      Variable.withReal(bucket.min),
      Variable.withReal(bucket.max),
    ];
    
    final rows = await _database.customSelect(
      sql.trim(),
      variables: variables,
      readsFrom: {
        _database.productCharacteristicFacets,
        _database.productFacets,
        if (parts.requiresCategoryJoin) _database.productCategoryFacets,
        if (parts.requiresStockJoin) _database.stockItems,
      },
    ).get();
    
    counts.add(rows.first.data['cnt'] as int? ?? 0);
  }
  
  return counts;
}

class _NumericBucket {
  final double min;
  final double max;
  final String label;
  _NumericBucket({required this.min, required this.max, required this.label});
}
```

#### 3. Новый тип фасета в Domain

**Файл**: `lib/features/shop/domain/entities/facet.dart`

```dart
enum FacetGroupType {
  list,     // Existing: brands, categories, string chars
  toggle,   // Existing: novelty, popular, bool chars
  range,    // NEW: numeric characteristics
}
```

#### 4. UI для Range фасетов

**Файл**: `lib/features/shop/presentation/widgets/facet_filter_sheet.dart`

Добавить рендеринг для `FacetGroupType.range`:

```dart
Widget _buildFacetGroup(BuildContext context, FacetGroup group) {
  switch (group.type) {
    case FacetGroupType.list:
      return _buildListFacet(context, group);
    case FacetGroupType.toggle:
      return _buildToggleFacet(context, group);
    case FacetGroupType.range:
      return _buildRangeFacet(context, group);  // NEW
  }
}

Widget _buildRangeFacet(BuildContext context, FacetGroup group) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          group.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ...group.values.map((value) {
        final rangeData = value.value as Map<String, double>;
        return CheckboxListTile(
          title: Text(value.label),
          subtitle: Text('${value.count} товаров'),
          value: value.selected,
          onChanged: (selected) {
            context.read<FacetFilterBloc>().add(
              SelectFacetValue(
                groupKey: group.key,
                value: rangeData,  // Передаём Map {min, max}
                selected: selected ?? false,
              ),
            );
          },
        );
      }),
      const Divider(),
    ],
  );
}
```

#### 5. Фильтрация по numeric в resolveProductCodes

```dart
// В цикле по selectedCharacteristics
if (values.first is Map) {
  // Это numeric range
  final range = values.first as Map<String, double>;
  charJoins.write('''
    INNER JOIN product_characteristic_facets $alias 
      ON $alias.product_code = pf.product_code 
      AND $alias.attribute_id = ? 
      AND $alias.char_type = 'numeric' 
      AND $alias.numeric_value >= ?
      AND $alias.numeric_value < ?
  ''');
  charVariables.add(Variable.withInt(attrId));
  charVariables.add(Variable.withReal(range['min']!));
  charVariables.add(Variable.withReal(range['max']!));
}
```

#### 6. Тестовые данные

```dart
{
  'code': 1001,
  'numericCharacteristics': [
    {
      'attributeId': 30,
      'attributeName': 'Объем',
      'id': 3001,
      'type': 'numeric',
      'value': 500.0,
      'adaptValue': '500 мл',
    },
    {
      'attributeId': 31,
      'attributeName': 'Вес',
      'id': 3101,
      'type': 'numeric',
      'value': 1.2,
      'adaptValue': '1.2 кг',
    },
  ],
},
{
  'code': 1002,
  'numericCharacteristics': [
    {
      'attributeId': 30,
      'attributeName': 'Объем',
      'id': 3002,
      'type': 'numeric',
      'value': 1000.0,
      'adaptValue': '1000 мл',
    },
  ],
},
```

### Риски Phase 3.3

**Риск 1: Производительность подсчёта buckets**
- N запросов для N диапазонов
- Решение: можно использовать CASE WHEN для одного запроса:
  ```sql
  SELECT 
    SUM(CASE WHEN value >= 0 AND value < 100 THEN 1 ELSE 0 END) AS bucket_0_100,
    SUM(CASE WHEN value >= 100 AND value < 500 THEN 1 ELSE 0 END) AS bucket_100_500,
    ...
  ```

**Риск 2: Выбор оптимального количества диапазонов**
- 5 диапазонов может быть слишком мало/много
- Решение: адаптивно в зависимости от range (если 0-10, то 5 диапазонов; если 0-10000, то 10)

**Риск 3: UX для range фасетов**
- Чекбоксы с диапазонами не так интуитивны как слайдер
- Решение: Phase 3.3.1 может добавить RangeSlider виджет

### Оценка Phase 3.3
**Время**: 3-4 дня
- Sync логика: 2 часа
- Repository MIN/MAX + buckets: 6-8 часов (самое сложное)
- Новый UI тип: 4-6 часов
- Фильтрация: 3-4 часа
- Тестирование: 6-8 часов

---

## Общий план внедрения

### Порядок реализации
1. ✅ Phase 3.1 — Bool (ЗАВЕРШЕНО)
2. Phase 3.2 — String (следующий шаг)
3. Phase 3.3 — Numeric (после string)

### Зависимости
- Phase 3.2 не зависит от 3.3 (можно делать параллельно)
- Phase 3.3 зависит от добавления `FacetGroupType.range` в domain

### Timeline
| Phase | Дни разработки | Дни тестирования | Итого |
|-------|----------------|------------------|-------|
| 3.1 Bool | ✅ 3 | ✅ 1 | ✅ 4 |
| 3.2 String | 2 | 1 | 3 |
| 3.3 Numeric | 3 | 1 | 4 |
| **Total** | **8** | **3** | **11** |

### Критерии готовности Phase 3.2

- [ ] String характеристики синхронизируются в БД
- [ ] Агрегация показывает TOP-20 значений для каждого атрибута
- [ ] Фильтрация по string работает корректно
- [ ] UI показывает чекбоксы для string характеристик
- [ ] Тесты покрывают основные сценарии
- [ ] Производительность: агрегация < 500ms на 10k товаров

### Критерии готовности Phase 3.3

- [ ] Numeric характеристики синхронизируются в БД
- [ ] Алгоритм bucket creation создаёт адекватные диапазоны
- [ ] Подсчёт товаров в диапазонах оптимизирован (< 1s)
- [ ] Новый `FacetGroupType.range` добавлен в domain
- [ ] UI показывает чекбоксы для диапазонов
- [ ] Фильтрация по numeric range работает корректно
- [ ] Тесты покрывают edge cases (min=max, один товар и т.д.)

---

## Приоритизация

### Must Have (для MVP)
- ✅ Bool characteristics
- String characteristics (цвета, размеры — критично для каталогов)

### Should Have (для полноценного релиза)
- Numeric characteristics (объем, вес — важно но не критично)

### Nice to Have (будущие улучшения)
- Поиск внутри string характеристик (когда > 20 значений)
- RangeSlider вместо чекбоксов для numeric
- Сортировка характеристик по популярности/алфавиту
- "Закрепить" топовые характеристики в начале списка
- Lazy loading для большого количества характеристик

---

## Next Steps

1. **Сейчас**: Зафиксировать Phase 3.1 в git (в процессе)
2. **Следующий спринт**: Начать Phase 3.2 (String characteristics)
   - Создать тикет с подзадачами из раздела "Технические задачи 3.2"
   - Добавить тестовые данные с разнообразными string характеристиками
   - Spike: проверить производительность ROW_NUMBER() на тестовых данных
3. **После 3.2**: Обсудить необходимость Phase 3.3
   - Собрать фидбек от пользователей/бизнеса про важность numeric фильтров
   - Если не критично — отложить до следующего релиза

---

## Документация для разработчиков

### Как добавить новый тип характеристики (future-proof)

Если в будущем появится 4-й тип (например, `dateCharacteristics`):

1. Добавить колонку в `product_characteristic_facets` (date_value)
2. Создать migration для добавления индекса
3. Расширить sync логику в `_upsertFacetData()`
4. Добавить метод `_fetchDateCharacteristics()` в repository
5. Определить `FacetGroupType.dateRange` если нужен специальный UI
6. Обновить `resolveProductCodes()` для фильтрации
7. Добавить рендеринг в `_buildFacetGroup()`
8. Написать тесты

### Как дебажить производительность фасетов

```dart
// В DriftFacetRepository добавить:
final stopwatch = Stopwatch()..start();
final groups = await _fetchStringCharacteristics(parts, filter);
_logger.info('_fetchStringCharacteristics took ${stopwatch.elapsedMilliseconds}ms');
```

### Полезные SQL для анализа

```sql
-- Топ-10 атрибутов по количеству товаров
SELECT 
  attribute_id,
  attribute_name,
  char_type,
  COUNT(DISTINCT product_code) AS products_count
FROM product_characteristic_facets
GROUP BY attribute_id
ORDER BY products_count DESC
LIMIT 10;

-- Атрибуты с слишком большим количеством значений
SELECT 
  attribute_id,
  attribute_name,
  COUNT(DISTINCT adapt_value) AS unique_values
FROM product_characteristic_facets
WHERE char_type = 'string'
GROUP BY attribute_id
HAVING unique_values > 50;
```
