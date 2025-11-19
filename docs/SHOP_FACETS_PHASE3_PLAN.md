# Facets Phase 3 — Dynamic Characteristics Filters

## 1. Анализ текущего состояния

### Фаза 1 (завершена)
- ✅ Статические фасеты: brands, manufacturers, series, types, categories, novelty/popular
- ✅ Материализованные таблицы `product_facets`, `product_category_facets`
- ✅ `FacetFilter` + `FacetRepository` + `FacetBloc`
- ✅ UI компоненты: drawer, chips, summary bar
- ✅ Единый pipeline через `ProductQuery`

### Фаза 2 (пропускается)
- Акции/промо требуют хранения сложных данных о promotions
- Пока не определена структура данных акций для офлайн-хранения
- Откладываем до прояснения требований по синхронизации промо-данных

### Что есть сейчас для характеристик
В `Product` entity три типа характеристик:
```dart
final List<Characteristic> numericCharacteristics;  // type: 'numeric', value: double
final List<Characteristic> stringCharacteristics;   // type: 'string', value: int (ID)
final List<Characteristic> boolCharacteristics;     // type: 'bool', value: bool
```

Структура `Characteristic`:
```dart
class Characteristic {
  final int attributeId;        // Уникальный ID атрибута (например, "Объем")
  final String attributeName;   // Название атрибута
  final int id;                 // ID конкретного значения характеристики
  final String type;            // 'numeric' | 'string' | 'bool'
  final String? adaptValue;     // Человекочитаемое значение (например, "500 мл")
  final dynamic value;          // Сырое значение (double/int/bool)
}
```

## 2. Бэкенд логика (Elasticsearch)

### Как работает бэкенд (PHP SearchService)

#### Nested aggregation по характеристикам
Бэкенд делает вложенные агрегации:
```php
foreach (['boolCharacteristics', 'stringCharacteristics', 'numericCharacteristics'] as $type) {
    $aggValue = new Terms("value");
    $aggValue->setField($type.'.value');
    
    $aggName = new Terms("adaptValue");
    $aggName->setField($type.'.adaptValue.keyword');
    $aggValue->addAggregation($aggName);
    
    $aggAttrName = new Terms('attributeNames');
    $aggAttrName->setField($type.'.attributeName.keyword');
    $aggAttrName->addAggregation($aggValue);
    
    $aggAttr = new Terms("attributeId");
    $aggAttr->setField($type.'.attributeId');
    $aggAttr->addAggregation($aggAttrName);
    
    $aggCharacteristic = new Nested($type, $type);
    $aggCharacteristic->addAggregation($aggAttr);
    
    $query->addAggregation($aggCharacteristic);
}
```

#### Результирующая структура фасетов
```php
return [
    'type' => 'bool',           // или 'list', 'numeric'
    'title' => 'Водостойкая',   // attributeName
    'key' => 'attr[123]',       // 'attr[' + attributeId + ']'
    'values' => [
        ['name' => 'Да', 'value' => true, 'count' => 15],
        ['name' => 'Нет', 'value' => false, 'count' => 8],
    ]
];
```

#### Ключевое ограничение бэкенда
**Бэкенд ЗАПРЕЩАЕТ запрос всех продуктов без фильтров!**
- Нужен поисковый запрос ИЛИ выбранные категории/бренды/фильтры
- Динамические характеристики показываются только когда есть сужающий контекст
- Это оправдано: без контекста может быть сотни тысяч уникальных характеристик

## 3. Стратегия для Flutter-приложения

### Ограничения на запрос фасетов
Динамические характеристики будем показывать ТОЛЬКО когда:
1. Есть поисковый запрос (`query.searchText.isNotEmpty`), ИЛИ
2. Выбрана категория (`filter.baseCategoryId != null`), ИЛИ
3. Применены статические фильтры (бренды/типы/производители)

**Без этих условий — не показываем динамические характеристики!**

### Почему начинаем с boolCharacteristics
1. **Простота типов**: только `true`/`false`, нет диапазонов
2. **Похожи на toggle-фасеты**: уже есть UI для `novelty`/`popular`
3. **Меньше данных**: bool обычно меньше чем string/numeric
4. **Проверка архитектуры**: если работает для bool — легко расширить

## 4. План реализации Phase 3.1 — Bool Characteristics

### 4.1 Database Schema Extensions

#### Новая таблица для характеристик
```sql
CREATE TABLE product_characteristic_facets (
    product_code INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    attribute_name TEXT NOT NULL,
    char_type TEXT NOT NULL,  -- 'bool', 'string', 'numeric'
    bool_value INTEGER,        -- NULL или 0/1 для bool
    string_value INTEGER,      -- NULL или ID для string
    numeric_value REAL,        -- NULL или double для numeric
    adapt_value TEXT,          -- Человекочитаемое значение
    PRIMARY KEY (product_code, attribute_id),
    FOREIGN KEY (product_code) REFERENCES products(code) ON DELETE CASCADE
);

CREATE INDEX idx_pcf_attribute_type ON product_characteristic_facets(attribute_id, char_type);
CREATE INDEX idx_pcf_bool_value ON product_characteristic_facets(attribute_id, bool_value) 
    WHERE char_type = 'bool';
```

#### Заполнение при сохранении продукта
В `ProductRepositoryDrift._saveProductFacets()` добавить:
```dart
Future<void> _saveCharacteristicFacets(Product product) async {
  await (_database.delete(_database.productCharacteristicFacets)
        ..where((tbl) => tbl.productCode.equals(product.code)))
      .go();

  final companions = <ProductCharacteristicFacetCompanion>[];
  
  // Bool characteristics
  for (final char in product.boolCharacteristics) {
    companions.add(ProductCharacteristicFacetCompanion.insert(
      productCode: product.code,
      attributeId: char.attributeId,
      attributeName: char.attributeName,
      charType: 'bool',
      boolValue: Value(char.value == true ? 1 : 0),
      adaptValue: Value(char.adaptValue),
    ));
  }
  
  // TODO: string/numeric в Phase 3.2/3.3
  
  if (companions.isNotEmpty) {
    await _database.batch((batch) {
      batch.insertAll(_database.productCharacteristicFacets, companions);
    });
  }
}
```

### 4.2 Repository Layer

#### Расширение FacetFilter
```dart
class FacetFilter {
  // ...existing fields...
  
  // Новые поля для динамических характеристик
  final Map<int, List<dynamic>> selectedCharacteristics; // attributeId -> [values]
  
  const FacetFilter({
    // ...existing params...
    this.selectedCharacteristics = const {},
  });
  
  FacetFilter copyWith({
    // ...existing...
    Map<int, List<dynamic>>? selectedCharacteristics,
  }) {
    return FacetFilter(
      // ...existing...
      selectedCharacteristics: selectedCharacteristics ?? this.selectedCharacteristics,
    );
  }
}
```

#### Агрегация bool-характеристик в DriftFacetRepository
```dart
Future<List<FacetGroup>> _fetchBoolCharacteristics(
  _FacetSqlParts parts,
  FacetFilter filter,
) async {
  // Проверяем контекст: должен быть поиск или фильтры
  if (!_hasFilteringContext(filter)) {
    return [];
  }

  final sql = '''
    SELECT 
      pcf.attribute_id,
      pcf.attribute_name,
      pcf.bool_value,
      pcf.adapt_value,
      COUNT(*) AS value_count
    FROM product_characteristic_facets pcf
    INNER JOIN product_facets pf ON pf.product_code = pcf.product_code
    ${parts.stockFilterJoin}
    ${parts.categoryFilterJoin}
    ${parts.whereClause}
      AND pcf.char_type = 'bool'
    GROUP BY pcf.attribute_id, pcf.attribute_name, pcf.bool_value
    ORDER BY pcf.attribute_name, pcf.bool_value DESC
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
      type: FacetGroupType.toggle,  // bool = toggle
      values: values,
    ));
  }

  return groups;
}

bool _hasFilteringContext(FacetFilter filter) {
  return filter.baseCategoryId != null ||
         filter.brandIds.isNotEmpty ||
         filter.manufacturerIds.isNotEmpty ||
         filter.seriesIds.isNotEmpty ||
         filter.typeIds.isNotEmpty ||
         filter.onlyNovelty ||
         filter.onlyPopular;
}

class _CharacteristicAgg {
  final int attributeId;
  final String attributeName;
  final Map<bool, _CharValue> values = {};
  _CharacteristicAgg(this.attributeId, this.attributeName);
}

class _CharValue {
  final String label;
  final bool value;
  final int count;
  _CharValue(this.label, this.value, this.count);
}
```

#### Обновление getFacetGroups
```dart
@override
Future<Either<Failure, List<FacetGroup>>> getFacetGroups(FacetFilter filter) async {
  try {
    // ...existing static facets code...
    
    // Добавляем динамические характеристики
    final boolCharGroups = await _fetchBoolCharacteristics(parts, filter);
    groups.addAll(boolCharGroups);
    
    return Right(groups);
  } catch (e, stackTrace) {
    _logger.severe('Ошибка при расчёте фасетов', e, stackTrace);
    return Left(DatabaseFailure('Не удалось получить фасеты: $e'));
  }
}
```

#### Фильтрация по характеристикам в resolveProductCodes
```dart
Future<Either<Failure, List<int>>> resolveProductCodes(FacetFilter filter) async {
  // ...existing code...
  
  // Добавляем WHERE условия для selectedCharacteristics
  final charWheres = <String>[];
  final charVariables = <Variable>[];
  
  for (final entry in filter.selectedCharacteristics.entries) {
    final attrId = entry.key;
    final values = entry.value;
    if (values.isEmpty) continue;
    
    // Для bool: pf.product_code IN (SELECT product_code FROM pcf WHERE attr_id=? AND bool_value IN (?))
    final placeholders = List.filled(values.length, '?').join(',');
    charWheres.add('''
      pf.product_code IN (
        SELECT product_code 
        FROM product_characteristic_facets 
        WHERE attribute_id = ? AND bool_value IN ($placeholders)
      )
    ''');
    charVariables.add(Variable.withInt(attrId));
    charVariables.addAll(values.map((v) => Variable.withInt(v == true ? 1 : 0)));
  }
  
  if (charWheres.isNotEmpty) {
    parts.addWhere(charWheres.join(' AND '));
    parts.addVariables(charVariables);
  }
  
  // ...rest of query...
}
```

### 4.3 Domain/Presentation Updates

#### UI изменения минимальны
- `FacetFilterSheet` уже умеет рендерить `FacetGroupType.toggle`
- Добавится просто больше групп с ключами `attr[123]`
- `FacetFilterBloc` уже обрабатывает выборы через `selectedCharacteristics`

#### Парсинг ключей фасетов
```dart
// В FacetFilterBloc или helper
class FacetKeyParser {
  static bool isDynamicCharacteristic(String key) {
    return key.startsWith('attr[') && key.endsWith(']');
  }
  
  static int? parseAttributeId(String key) {
    if (!isDynamicCharacteristic(key)) return null;
    final match = RegExp(r'attr\[(\d+)\]').firstMatch(key);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
}
```

#### Обработка выбора в FacetFilterBloc
```dart
on<SelectFacetValue>((event, emit) {
  final filter = state.workingFilter;
  
  if (FacetKeyParser.isDynamicCharacteristic(event.groupKey)) {
    final attrId = FacetKeyParser.parseAttributeId(event.groupKey);
    if (attrId == null) return;
    
    final current = Map<int, List<dynamic>>.from(filter.selectedCharacteristics);
    final currentValues = List<dynamic>.from(current[attrId] ?? []);
    
    if (event.selected) {
      if (!currentValues.contains(event.value)) {
        currentValues.add(event.value);
      }
    } else {
      currentValues.remove(event.value);
    }
    
    if (currentValues.isEmpty) {
      current.remove(attrId);
    } else {
      current[attrId] = currentValues;
    }
    
    emit(state.copyWith(
      workingFilter: filter.copyWith(selectedCharacteristics: current),
    ));
  } else {
    // ...existing static facet logic...
  }
});
```

### 4.4 Testing Strategy

#### Unit tests
```dart
test('fetchBoolCharacteristics returns empty when no filtering context', () async {
  final filter = FacetFilter(); // пустой
  final repo = DriftFacetRepository();
  
  final result = await repo.getFacetGroups(filter);
  
  expect(result.isRight, true);
  final groups = result.getOrElse([]);
  final boolGroups = groups.where((g) => g.key.startsWith('attr[')).toList();
  expect(boolGroups, isEmpty);
});

test('fetchBoolCharacteristics returns groups when category selected', () async {
  // Setup: категория ID=1, продукты с bool характеристикой "Водостойкая"
  final filter = FacetFilter(baseCategoryId: 1);
  
  final result = await repo.getFacetGroups(filter);
  
  final groups = result.getOrElse([]);
  final waterproofGroup = groups.firstWhere((g) => g.title == 'Водостойкая');
  expect(waterproofGroup.type, FacetGroupType.toggle);
  expect(waterproofGroup.values.length, 2); // Да/Нет
});
```

#### Integration tests
```dart
testWidgets('Dynamic bool facets appear after selecting category', (tester) async {
  await tester.pumpWidget(buildTestApp());
  
  // Открываем категорию
  await tester.tap(find.text('Краски'));
  await tester.pumpAndSettle();
  
  // Открываем фильтры
  await tester.tap(find.byIcon(Icons.filter_list));
  await tester.pumpAndSettle();
  
  // Проверяем наличие динамических характеристик
  expect(find.text('Водостойкая'), findsOneWidget);
  expect(find.text('Морозостойкая'), findsOneWidget);
});
```

## 5. Deliverables Phase 3.1 (Bool Characteristics)

- [ ] **Schema**: таблица `product_characteristic_facets` + индексы
- [ ] **Sync**: заполнение таблицы при `saveProducts` для `boolCharacteristics`
- [ ] **Repository**: агрегация bool-характеристик с проверкой контекста
- [ ] **Repository**: фильтрация `resolveProductCodes` по `selectedCharacteristics`
- [ ] **Domain**: расширение `FacetFilter.selectedCharacteristics`
- [ ] **Bloc**: обработка выбора динамических фасетов через `FacetKeyParser`
- [ ] **Tests**: unit + integration для bool фасетов
- [ ] **Docs**: обновление комментариев в коде про ограничения показа

## 6. Phase 3.2 (Future) — String Characteristics

### Особенности stringCharacteristics
```dart
final List<Characteristic> stringCharacteristics;
// type: 'string'
// value: int (ID значения из справочника)
// adaptValue: String (человекочитаемое значение, например "Красный")
```

### Стратегия
- Тип фасета: `FacetGroupType.list` (мультивыбор)
- В SQL: `GROUP BY attribute_id, string_value, adapt_value`
- UI: чекбоксы как для brands/categories
- Может быть МНОГО значений (цвета, размеры и т.д.) — нужна пагинация/поиск внутри группы

### Примерный SQL
```sql
SELECT 
  pcf.attribute_id,
  pcf.attribute_name,
  pcf.string_value,
  pcf.adapt_value,
  COUNT(*) AS value_count
FROM product_characteristic_facets pcf
INNER JOIN product_facets pf ON pf.product_code = pcf.product_code
${parts.whereClause}
  AND pcf.char_type = 'string'
GROUP BY pcf.attribute_id, pcf.attribute_name, pcf.string_value
ORDER BY pcf.attribute_name, value_count DESC
LIMIT 20  -- Топ-20 значений для каждого атрибута
```

## 7. Phase 3.3 (Future) — Numeric Characteristics

### Особенности numericCharacteristics
```dart
final List<Characteristic> numericCharacteristics;
// type: 'numeric'
// value: double (например, 500.0 для объема)
// adaptValue: String ("500 мл")
```

### Стратегия
- Тип фасета: `FacetGroupType.range` (новый тип!)
- Вычисляем MIN/MAX для атрибута
- Разбиваем на 5-10 диапазонов (как price ranges на бэкенде)
- UI: слайдер или список чекбоксов с диапазонами

### Примерный SQL
```sql
SELECT 
  pcf.attribute_id,
  pcf.attribute_name,
  MIN(pcf.numeric_value) AS min_val,
  MAX(pcf.numeric_value) AS max_val,
  COUNT(DISTINCT pcf.product_code) AS total_count
FROM product_characteristic_facets pcf
WHERE pcf.char_type = 'numeric'
GROUP BY pcf.attribute_id
```

## 8. Риски и ограничения

### Риск 1: Слишком много характеристик
**Проблема**: У некоторых категорий может быть 50+ атрибутов
**Решение**: 
- Показывать только топ-N по количеству товаров
- Добавить поиск внутри фасетов
- Группировать похожие атрибуты

### Риск 2: Производительность JOIN-ов
**Проблема**: Дополнительный JOIN с `product_characteristic_facets`
**Решение**:
- Индексы на `(attribute_id, char_type, bool_value)`
- EXPLAIN QUERY PLAN в debug режиме
- Возможно, денормализация часто используемых характеристик в `product_facets`

### Риск 3: Сложность UI с большим числом фасетов
**Проблема**: Drawer становится слишком длинным
**Решение**:
- Сворачиваемые секции для динамических характеристик
- Отдельная вкладка "Дополнительные фильтры"
- Показывать только топ-3 характеристики, остальные по кнопке "Еще"

## 9. Success Criteria

### Phase 3.1 считается успешной если:
1. ✅ Bool-характеристики появляются в фильтрах при выборе категории
2. ✅ Фильтрация по bool работает корректно (товары соответствуют выбору)
3. ✅ Без контекста (пустой поиск + нет фильтров) динамических фасетов нет
4. ✅ Производительность: расчет фасетов < 500ms для категории с 1000+ товаров
5. ✅ UI не ломается при 10+ динамических характеристиках
6. ✅ Есть тесты покрывающие основные сценарии

## 10. Timeline Estimate

- **Phase 3.1 (Bool)**: 3-5 дней
  - Schema + migrations: 0.5 дня
  - Repository aggregation: 1 день
  - Filtering logic: 1 день
  - Bloc/UI integration: 1 день
  - Testing: 0.5-1.5 дня

- **Phase 3.2 (String)**: 2-3 дня (если 3.1 работает)
- **Phase 3.3 (Numeric)**: 3-4 дня (новый UI для ranges)

**Total для всех типов: ~10 дней разработки + 2-3 дня багфиксинг/полировка**

## 11. Next Steps

1. Обсудить с командой ограничение "показывать только при наличии контекста"
2. Создать тикет на Phase 3.1 с подзадачами из раздела 5
3. Подготовить тестовые фикстуры с разнообразными bool-характеристиками
4. Провести spike: проверить производительность JOIN на реальных данных (10k+ products)
5. Начать реализацию с schema + sync (самая безопасная часть)
