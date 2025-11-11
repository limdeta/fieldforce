# План реализации цветового кодирования цен

## 1. Анализ существующей системы цен

### 1.1 Protobuf структура (источник данных)

**OutletStockPricing message** (`stockitem.proto`):
```protobuf
message OutletStockPricing {
    int32 stock_item_id = 1;
    int32 product_code = 2;
    int32 warehouse_id = 3;
    string outlet_vendor_id = 4;
    int32 final_price = 5;              // Итоговая цена для торговой точки
    int32 price_difference = 6;         // Разница с региональной ценой
    float price_difference_percent = 7; // Процент отклонения
    string price_type = 8;              // ТИП ЦЕНЫ! Нужно сохранить
    float discount_value = 9;
    bool has_promotion = 10;            // Флаг наличия акции
    ActivePromotion promotion = 11;     // Детали акции
}
```

**Типы цен в priceType** (из `product_with_price.dart`):
- `"regional_base"` — базовая региональная цена (дефолтная)
- `"differential_price"` — индивидуальная цена для торговой точки (желтый)
- `"promotion"` — акционная цена (зеленый)

### 1.2 Текущая структура StockItem entity

**Файл**: `lib/features/shop/domain/entities/stock_item.dart`

```dart
class StockItem extends Equatable {
  final int id;
  final Product? product;
  final int productCode;
  final int warehouseId;
  final String? warehouseName;
  final String publicStock;
  final int multiplicity;
  final int defaultPrice;      // Сюда мапится regionalBasePrice из protobuf
  final int? offerPrice;       // СЕЙЧАС NULL! Должна мапиться finalPrice если есть акция
  final int? availablePrice;   // СЕЙЧАС NULL! Должна мапиться finalPrice если differential
  final double discountValue;
  final String? promotionJson; // СЕЙЧАС NULL! Должен мапиться JSON акции
  
  // НЕТ ПОЛЯ priceType! НУЖНО ДОБАВИТЬ
}
```

**Проблема**: Сейчас `priceType` НЕ сохраняется в StockItem, хотя приходит из protobuf.

### 1.3 Текущий конвертер (StockItemProtobufConverter)

**Файл**: `lib/features/shop/data/sync/models/stock_item_protobuf_converter.dart`

```dart
static StockItemsCompanion fromOutletPricing(
  OutletStockPricing pricing,
  int warehouseId,
) {
  return StockItemsCompanion.insert(
    // ... другие поля
    defaultPrice: pricing.regionalBasePrice,
    offerPrice: Value(null),      // ❌ ТЕРЯЕМ ДАННЫЕ!
    availablePrice: Value(null),  // ❌ ТЕРЯЕМ ДАННЫЕ!
    promotionJson: Value(null),   // ❌ ТЕРЯЕМ ДАННЫЕ!
    // priceType НЕТ ВООБЩЕ!
  );
}
```

**Проблема**: Конвертер игнорирует `priceType`, `hasPromotion`, `promotion` из protobuf.

### 1.4 Где отображаются цены (UI)

1. **ProductPurchaseCard** — основная карточка в каталоге
   - Строка 119-125: отображение цены
   - Цвет: дефолтный черный текст
   
2. **StockItemSelectorWidget** — выпадающий список складов
   - Строки 265-277: отображение цены и старой цены
   - Цвет: красный если есть offerPrice
   
3. **ProductDetailPage** — детальная страница товара
   - Строки 569-590: цена с зачеркиванием старой при акции
   - Цвет: красный для акций
   
4. **CartPage, OrderDetailPage, OrdersPage** — страницы заказов
   - Используют `availablePrice ?? defaultPrice`
   - Цвет: дефолтный

## 2. Целевая схема цветового кодирования

### 2.1 Правила окрашивания

| Тип цены (`priceType`) | Поле в StockItem | Цвет | Hex код |
|------------------------|------------------|------|---------|
| `"regional_base"` | `defaultPrice` | Дефолтный (черный) | `null` |
| `"promotion"` | `offerPrice` | Темно-зеленый | `#1B5E20` |
| `"differential_price"` | `availablePrice` | Темно-желтый | `#F57F17` |

### 2.2 Логика определения цвета

```dart
Color? getPriceColor(StockItem stockItem) {
  if (stockItem.priceType == null) return null;
  
  switch (stockItem.priceType) {
    case 'promotion':
      return const Color(0xFF1B5E20); // Темно-зеленый
    case 'differential_price':
      return const Color(0xFFF57F17); // Темно-желтый
    case 'regional_base':
    default:
      return null; // Дефолтный цвет текста
  }
}
```

## 3. План изменений (пошагово)

### Шаг 1: Добавить `priceType` в StockItem entity

**Файлы для изменения**:
1. `lib/features/shop/domain/entities/stock_item.dart` — добавить поле `String? priceType`
2. `lib/app/database/tables.dart` — добавить колонку `priceType` в таблицу StockItems
3. `lib/app/database/mappers/stock_item_mapper.dart` — обновить маппер

**Изменения**:
```dart
// stock_item.dart
class StockItem extends Equatable {
  // ... existing fields
  final String? priceType; // НОВОЕ ПОЛЕ
  
  const StockItem({
    // ... existing params
    this.priceType,
  });
}

// tables.dart
class StockItems extends Table {
  // ... existing columns
  TextColumn get priceType => text().nullable()(); // НОВАЯ КОЛОНКА
}
```

**После изменений**: Запустить `flutter pub run build_runner build --delete-conflicting-outputs`

### Шаг 2: Обновить StockItemProtobufConverter

**Файл**: `lib/features/shop/data/sync/models/stock_item_protobuf_converter.dart`

**Изменения**:
```dart
static StockItemsCompanion fromOutletPricing(
  OutletStockPricing pricing,
  int warehouseId,
) {
  // Определяем какую цену куда класть на основе типа
  int? offerPrice;
  int? availablePrice;
  String? promotionJson;
  
  if (pricing.hasPriceType()) {
    switch (pricing.priceType) {
      case 'promotion':
        offerPrice = pricing.finalPrice;
        if (pricing.hasPromotion && pricing.hasPromotion()) {
          // Сериализуем promotion в JSON
          promotionJson = jsonEncode({
            'id': pricing.promotion.promotionId,
            'type': pricing.promotion.promotionType,
            'title': pricing.promotion.title,
            'description': pricing.promotion.description,
            'validFrom': pricing.promotion.validFrom,
            'validTo': pricing.promotion.validTo,
          });
        }
        break;
      case 'differential_price':
        availablePrice = pricing.finalPrice;
        break;
      case 'regional_base':
      default:
        // Цена уже в defaultPrice (regionalBasePrice)
        break;
    }
  }
  
  return StockItemsCompanion.insert(
    // ... existing fields
    defaultPrice: pricing.regionalBasePrice,
    offerPrice: Value(offerPrice),
    availablePrice: Value(availablePrice),
    promotionJson: Value(promotionJson),
    priceType: Value(pricing.hasPriceType() ? pricing.priceType : null),
  );
}
```

### Шаг 3: Создать helper для определения цвета

**Файл**: `lib/features/shop/presentation/helpers/price_color_helper.dart` (НОВЫЙ)

```dart
import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';

class PriceColorHelper {
  // Темно-зеленый для акций
  static const Color promotionColor = Color(0xFF1B5E20);
  
  // Темно-желтый для индивидуальных цен
  static const Color differentialColor = Color(0xFFF57F17);
  
  /// Возвращает цвет цены на основе типа цены в StockItem
  /// null = дефолтный цвет текста (regional_base или не определен)
  static Color? getPriceColor(StockItem stockItem) {
    if (stockItem.priceType == null) return null;
    
    switch (stockItem.priceType) {
      case 'promotion':
        return promotionColor;
      case 'differential_price':
        return differentialColor;
      case 'regional_base':
      default:
        return null;
    }
  }
  
  /// Вспомогательный метод для получения TextStyle с цветом цены
  static TextStyle getPriceTextStyle(
    StockItem stockItem, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: getPriceColor(stockItem),
    );
  }
}
```

### Шаг 4: Обновить ProductPurchaseCard

**Файл**: `lib/features/shop/presentation/widgets/product_purchase_card_widget.dart`

**Изменения**:
```dart
class ProductPurchaseCard extends StatelessWidget {
  // ... existing fields
  final Color? priceColor; // НОВЫЙ ПАРАМЕТР
  
  const ProductPurchaseCard({
    // ... existing params
    this.priceColor,
  });
  
  @override
  Widget build(BuildContext context) {
    // ... existing code
    
    // Строка 119-125 — применяем цвет
    ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 60, maxWidth: 110),
      child: Text(
        '${_formatPrice(priceInKopecks)} ₽',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: priceColor, // ПРИМЕНЯЕМ ЦВЕТ
        ),
      ),
    ),
  }
}
```

### Шаг 5: Обновить ProductCatalogCardWidget

**Файл**: `lib/features/shop/presentation/widgets/product_catalog_card_widget.dart`

**Изменения**:
```dart
import 'package:fieldforce/features/shop/presentation/helpers/price_color_helper.dart';

class ProductCatalogCardWidget extends StatelessWidget {
  // ... existing code
  
  @override
  Widget build(BuildContext context) {
    // ... existing code
    
    return ProductPurchaseCard(
      // ... existing params
      priceColor: selectedStockItem != null 
        ? PriceColorHelper.getPriceColor(selectedStockItem!)
        : null, // НОВЫЙ ПАРАМЕТР
    );
  }
}
```

### Шаг 6: Обновить StockItemSelectorWidget

**Файл**: `lib/features/shop/presentation/widgets/stock_item_selector_widget.dart`

**Изменения** (строки 265-277):
```dart
import 'package:fieldforce/features/shop/presentation/helpers/price_color_helper.dart';

// В методе build, где отображаются цены
Text(
  stockItem.offerPrice != null
    ? '${_formatPrice(stockItem.offerPrice!)} ₽'
    : '${_formatPrice(stockItem.defaultPrice)} ₽',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PriceColorHelper.getPriceColor(stockItem), // ПРИМЕНЯЕМ ЦВЕТ
  ),
),
```

### Шаг 7: Обновить ProductDetailPage

**Файл**: `lib/features/shop/presentation/pages/product_detail_page.dart`

**Изменения** (строки 569-590):
```dart
import 'package:fieldforce/features/shop/presentation/helpers/price_color_helper.dart';

// Акционная цена (строка 580)
Text(
  '${(stockItem.offerPrice! / 100).toStringAsFixed(2)} ₽',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: PriceColorHelper.getPriceColor(stockItem), // ЗЕЛЕНЫЙ ДЛЯ АКЦИЙ
  ),
),

// Обычная цена без акции (строка 589)
Text(
  '${(stockItem.defaultPrice / 100).toStringAsFixed(2)} ₽',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: PriceColorHelper.getPriceColor(stockItem), // ЦВЕТ ПО ТИПУ
  ),
),
```

### Шаг 8: Обновить страницы заказов

**Файлы**:
- `lib/features/shop/presentation/pages/cart_page.dart`
- `lib/features/shop/presentation/pages/order_detail_page.dart`
- `lib/features/shop/presentation/pages/orders_page.dart`

**Изменения**: Найти все места где отображаются `availablePrice` и `defaultPrice` и применить цвет через `PriceColorHelper.getPriceColor(orderLine.stockItem)`.

## 4. Тестирование

### 4.1 Создать тестовые фикстуры

В `OrderFixtureService` или `ProductFixtureService` создать:
1. Товары с `priceType = "regional_base"` (черный)
2. Товары с `priceType = "promotion"` (зеленый)
3. Товары с `priceType = "differential_price"` (желтый)

### 4.2 Визуальная проверка

1. Открыть каталог — проверить цвета карточек
2. Открыть выпадающий список складов — проверить цвета
3. Открыть детали товара — проверить цвета
4. Открыть корзину — проверить цвета

### 4.3 Unit тесты

Создать тест для `PriceColorHelper.getPriceColor()`:
```dart
test('returns green for promotion price', () {
  final stockItem = StockItem(priceType: 'promotion', ...);
  expect(PriceColorHelper.getPriceColor(stockItem), PriceColorHelper.promotionColor);
});

test('returns yellow for differential price', () {
  final stockItem = StockItem(priceType: 'differential_price', ...);
  expect(PriceColorHelper.getPriceColor(stockItem), PriceColorHelper.differentialColor);
});

test('returns null for regional_base price', () {
  final stockItem = StockItem(priceType: 'regional_base', ...);
  expect(PriceColorHelper.getPriceColor(stockItem), null);
});
```

## 5. Миграция данных

### 5.1 Drift migration

После добавления колонки `priceType` в таблицу, Drift автоматически создаст миграцию. НО старые данные будут иметь `priceType = null`.

**Решение**: После первой синхронизации все товары получат актуальные `priceType` из protobuf. До этого все цены будут отображаться дефолтным цветом.

### 5.2 Опциональная ручная миграция

Если нужно явно установить `priceType = "regional_base"` для всех старых записей:

```dart
// В миграции
await customStatement(
  'UPDATE stock_items SET price_type = "regional_base" WHERE price_type IS NULL'
);
```

## 6. Потенциальные проблемы и решения

### Проблема 1: Pub.dev недоступен (текущая ситуация)

**Решение**: Все изменения можно внести в код сейчас. Build runner запустится когда pub.dev восстановится.

### Проблема 2: Старые данные без priceType

**Решение**: Дефолтный цвет (null) будет отображаться корректно как черный текст.

### Проблема 3: Несоответствие цветов между offerPrice и priceType

**Решение**: В конвертере жестко привязываем:
- `priceType = "promotion"` → данные идут в `offerPrice`
- `priceType = "differential_price"` → данные идут в `availablePrice`

### Проблема 4: Цвета могут быть недостаточно контрастными

**Решение**: После реализации можно протестировать и скорректировать hex коды:
- Темно-зеленый: `#1B5E20` (можно сделать светлее: `#2E7D32`)
- Темно-желтый: `#F57F17` (можно сделать темнее: `#EF6C00`)

## 7. Итоговый чеклист

- [ ] Шаг 1: Добавить `priceType` в StockItem entity + Drift таблицу
- [ ] Запустить build_runner (когда pub.dev доступен)
- [ ] Шаг 2: Обновить StockItemProtobufConverter с маппингом priceType
- [ ] Шаг 3: Создать PriceColorHelper
- [ ] Шаг 4: Обновить ProductPurchaseCard
- [ ] Шаг 5: Обновить ProductCatalogCardWidget
- [ ] Шаг 6: Обновить StockItemSelectorWidget
- [ ] Шаг 7: Обновить ProductDetailPage
- [ ] Шаг 8: Обновить страницы заказов
- [ ] Создать фикстуры для тестирования
- [ ] Визуальное тестирование всех экранов
- [ ] Написать unit тесты для PriceColorHelper
- [ ] Проверить работу после синхронизации с реальным бэкендом

## 8. Заметки для будущего

1. **Расширение палитры**: Если появятся новые типы цен, легко добавить в switch-case в `PriceColorHelper`.
2. **Темная тема**: При добавлении dark mode учесть что темно-зеленый и темно-желтый могут плохо читаться на темном фоне. Возможно нужны разные цвета для светлой/темной темы.
3. **Иконки вместо цветов**: Можно дополнить цветовое кодирование иконками (🔥 для акций, ⭐ для индивидуальных цен).
4. **Легенда**: Добавить в Settings страницу легенду цветов для пользователей.

---

## 9. Обновление от 2025-11-11: Фоновая подсветка цен

### Проблема
Цветовое кодирование цен (темно-зеленый для акций, темно-желтый для индивидуальных цен) было недостаточно заметным на светлом фоне карточек товаров.

### Решение
Добавлена полупрозрачная фоновая подсветка для цен:

**Обновления в `PriceColorHelper`**:
```dart
// Новые константы для фоновых цветов
static const Color promotionBackgroundColor = Color(0x33C8E6C9); // Light green 20% opacity
static const Color differentialBackgroundColor = Color(0x33FFF9C4); // Light yellow 20% opacity

// Новый метод
static Color? getPriceBackgroundColor(StockItem stockItem) {
  if (stockItem.priceType == null) return null;
  
  switch (stockItem.priceType) {
    case 'promotion':
      return promotionBackgroundColor;
    case 'differential_price':
      return differentialBackgroundColor;
    case 'regional_base':
    default:
      return null; // Без фона
  }
}
```

**Обновления в `ProductPurchaseCard`**:
- Добавлен параметр `priceBackgroundColor`
- Цена обёрнута в `Container` с `BoxDecoration` для отображения фона
- Добавлен небольшой padding (6x3) для визуального комфорта

**Обновления в `ProductCatalogCardWidget`**:
- Передаётся `priceBackgroundColor` через `PriceColorHelper.getPriceBackgroundColor()`

### Визуальный результат
- **Акционные цены**: темно-зеленый текст на светло-зеленом полупрозрачном фоне
- **Индивидуальные цены**: темно-желтый текст на светло-желтом полупрозрачном фоне  
- **Региональные цены**: обычный текст без фона

Это обеспечивает лучшую визуальную различимость специальных цен при сохранении минималистичного дизайна.

