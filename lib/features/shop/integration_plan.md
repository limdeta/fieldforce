# Руководство по интеграции мобильного приложения с API синхронизации

## 📱 Для разработчиков Dart/Flutter

### Обзор архитектуры

API мобильной синхронизации предоставляет **двухуровневую систему кеширования** для оффлайн-работы торговых представителей:

1. **🌍 Региональные данные** (синхронизация 1 раз в день утром):
   - Продукты региона (~7000+ товаров)
   - Остатки на складах региона с привязкой к продуктам
   - Базовые цены региона

2. **🏪 Индивидуальные цены торговых точек** (синхронизация каждый час):
   - Только товары с уникальными ценами для конкретной торговой точки (~110 записей)
   - Дифференциальные данные (разница с региональными ценами)

**🎯 Итоговая структура данных на телефоне:**
- **Таблица продуктов** (региональная, ~7000 записей)
- **Таблица складов и остатков** (региональная, с привязкой к продуктам)
- **Таблица финальных цен** (StockItem + Торговая точка + Итоговая цена)

**🚀 Ключевое преимущество:** 
- Полная синхронизация: 1 раз в день (утром)
- Обновление остатков: каждый час (~10-50 МБ)
- Обновление цен для точки: каждый час (~100-500 КБ)

---

## 🚀 Быстрый старт

### 1. Установка зависимостей

Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  protobuf: ^3.1.0
  sqflite: ^2.3.0  # для локального хранения
```

### 2. Генерация Dart-классов из proto-схем

Скопируйте proto-файлы из бэкенда:
- `backend/src/MobileSync/Proto/product.proto`
- `backend/src/MobileSync/Proto/stockitem.proto`
- `backend/src/MobileSync/Proto/sync.proto`

Сгенерируйте Dart-классы:

```bash
# Установите protoc и плагин для Dart
dart pub global activate protoc_plugin

# Генерация классов
protoc --dart_out=lib/generated \
    -I=proto \
    proto/product.proto \
    proto/stockitem.proto \
    proto/sync.proto
```

### 3. Оптимизированная структура локального хранения

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'generated/sync.pb.dart';

class MobileSyncService {
  final String baseUrl;
  
  MobileSyncService(this.baseUrl);
  
  /// 🌍 ПОЛНАЯ СИНХРОНИЗАЦИЯ (утром, 1 раз в день)
  Future<void> performFullSync(String regionFiasId, List<String> outletVendorIds) async {
    print('🌅 Начинаем полную утреннюю синхронизацию...');
    
    // 1. Загружаем региональные данные (продукты + базовые цены)
    final regionalData = await getRegionalData(regionFiasId);
    await saveRegionalData(regionalData);
    
    // 2. Загружаем остатки на складах
    final stockData = await getRegionalStock(regionFiasId);
    await saveStockData(stockData);
    
    // 3. Загружаем индивидуальные цены для всех торговых точек пользователя
    for (final outletId in outletVendorIds) {
      final outletPrices = await getOutletPrices(outletId);
      await saveOutletPrices(outletId, outletPrices);
    }
    
    print('✅ Полная синхронизация завершена');
  }
  
  /// ⏰ ЧАСОВОЕ ОБНОВЛЕНИЕ (остатки + цены)
  Future<void> performHourlySync(String regionFiasId, List<String> outletVendorIds) async {
    print('⏰ Часовое обновление остатков и цен...');
    
    // 1. Обновляем остатки на складах
    final stockData = await getRegionalStock(regionFiasId);
    await updateStockData(stockData);
    
    // 2. Обновляем цены для всех торговых точек
    for (final outletId in outletVendorIds) {
      final outletPrices = await getOutletPrices(outletId);
      await updateOutletPrices(outletId, outletPrices);
    }
    
    print('✅ Часовое обновление завершено');
  }
  
  /// 🌍 ЭТАП 1: Получить региональные данные (базовые данные)
  Future<RegionalCacheResponse> getRegionalData(String regionFiasId) async {
    final url = Uri.parse('$baseUrl/v1_api/mobile-sync/regional/$regionFiasId');
    
    final response = await http.get(url, headers: {
      'Accept': 'application/x-protobuf',
    });
    
    if (response.statusCode == 200) {
      final decompressedBytes = gzip.decode(response.bodyBytes);
      final regionalData = RegionalCacheResponse.fromBuffer(decompressedBytes);
      
      print('✅ Региональные данные: ${regionalData.products.length} товаров');
      return regionalData;
    }
    
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
  
  /// 🏪 ЭТАП 2: Получить индивидуальные цены для торговой точки
  Future<OutletSpecificCacheResponse> getOutletPrices(String outletVendorId) async {
    final url = Uri.parse('$baseUrl/v1_api/mobile-sync/outlet-prices/$outletVendorId');
    
    final response = await http.get(url, headers: {
      'Accept': 'application/x-protobuf',
    });
    
    if (response.statusCode == 200) {
      final decompressedBytes = gzip.decode(response.bodyBytes);
      final outletPrices = OutletSpecificCacheResponse.fromBuffer(decompressedBytes);
      
      print('✅ Индивидуальные цены: ${outletPrices.differentialProducts.length} уникальных цен');
      print('📊 Экономия: ${7000 - outletPrices.differentialProducts.length} товаров не передано');
      
      return outletPrices;
    }
    
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
  
  /// 📦 Получить региональные остатки
  Future<RegionalStockResponse> getRegionalStock(String regionFiasId) async {
    final url = Uri.parse('$baseUrl/v1_api/mobile-sync/regional-stock/$regionFiasId');
    
    final response = await http.get(url, headers: {
      'Accept': 'application/x-protobuf',
    });
    
    if (response.statusCode == 200) {
      final decompressedBytes = gzip.decode(response.bodyBytes);
      final stockData = RegionalStockResponse.fromBuffer(decompressedBytes);
      
      print('✅ Остатки обновлены: ${stockData.stockItems.length} позиций');
      return stockData;
    }
    
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
  
  /// 💾 Объединение региональных данных и индивидуальных цен
  Map<int, ProductWithPrice> mergeRegionalAndOutletData(
    RegionalCacheResponse regional,
    OutletSpecificCacheResponse outlet,
  ) {
    final result = <int, ProductWithPrice>{};
    
    // 1. Загружаем все региональные товары с базовыми ценами
    for (final product in regional.products) {
      result[product.code] = ProductWithPrice(
        product: product,
        finalPrice: product.regionalPrice, // базовая цена региона
        priceType: 'regional_base',
      );
    }
    
    // 2. Перезаписываем товары с уникальными ценами для точки
    for (final diffProduct in outlet.differentialProducts) {
      if (result.containsKey(diffProduct.productCode)) {
        result[diffProduct.productCode] = ProductWithPrice(
          product: result[diffProduct.productCode]!.product,
          finalPrice: diffProduct.outletSpecificPrice, // индивидуальная цена точки
          priceType: diffProduct.type,
          regionalBasePrice: diffProduct.regionalBasePrice,
          priceDifference: diffProduct.priceDifference,
          priceDifferencePercent: diffProduct.priceDifferencePercent,
          hasPromotion: diffProduct.hasPromotion(),
        );
      }
    }
    
    return result;
  }
}

/// Объединенные данные товара с итоговой ценой
class ProductWithPrice {
  final Product product;
  final int finalPrice;         // итоговая цена для отображения
  final String priceType;       // "regional_base", "differential_price", "promotion"
  final int? regionalBasePrice; // базовая цена региона (для сравнения)
  final int? priceDifference;   // разница в копейках
  final double? priceDifferencePercent;
  final bool hasPromotion;
  
  ProductWithPrice({
    required this.product,
    required this.finalPrice,
    required this.priceType,
    this.regionalBasePrice,
    this.priceDifference,
    this.priceDifferencePercent,
    this.hasPromotion = false,
  });
  
  /// Есть ли скидка относительно региональной цены
  bool get hasDiscount => priceDifference != null && priceDifference! < 0;
  
  /// Есть ли наценка относительно региональной цены
  bool get hasMarkup => priceDifference != null && priceDifference! > 0;
}
```

### 4. Полный цикл синхронизации

```dart
void main() async {
  final syncService = MobileSyncService('https://your-backend.com');
  
  const regionFiasId = '43909681-d6e1-432d-b61f-ddac393cb5da'; // Владивосток
  const outletVendorId = 'OUTLET_12345';
  
  try {
    // 🌍 Шаг 1: Загружаем региональные данные (7000+ товаров)
    final regionalData = await syncService.getRegionalData(regionFiasId);
    
    // 🏪 Шаг 2: Загружаем индивидуальные цены точки (~110 товаров)
    final outletPrices = await syncService.getOutletPrices(outletVendorId);
    
    // 💾 Шаг 3: Объединяем данные для использования в приложении
    final finalProducts = syncService.mergeRegionalAndOutletData(regionalData, outletPrices);
    
    print('✅ Готово к работе: ${finalProducts.length} товаров');
    print('📊 Индивидуальных цен: ${outletPrices.differentialProducts.length}');
    print('🎯 Базовых цен: ${regionalData.products.length - outletPrices.differentialProducts.length}');
    
    // Сохраняем в локальную БД
    await saveToLocalDatabase(finalProducts);
    
  } catch (e) {
    print('❌ Ошибка синхронизации: $e');
  }
}
```

---

## 🌍 Региональные FIAS ID

| Регион       | FIAS ID                              |
|--------------|--------------------------------------|
| Владивосток  | `43909681-d6e1-432d-b61f-ddac393cb5da` |
| Магадан      | `9c05e812-8679-4710-b8cb-5e8bd43cdf48` |
| Камчатка     | `d02f30fc-83bf-4c0f-ac2b-5729a866a207` |

---

## 📋 API Эндпоинты

### GET /v1_api/mobile-sync/regional/{regionFiasId}
**Описание:** Полная региональная синхронизация (утром)
- Продукты региона
- Базовые цены региона
- Информация о складах

**Размер:** ~15-25 МБ (сжато)
**Частота:** 1 раз в день

### GET /v1_api/mobile-sync/regional-stock/{regionFiasId}
**Описание:** Обновление остатков на складах (каждый час)
- Только актуальные остатки без продуктов
- Привязка к уже загруженным продуктам

**Размер:** ~5-15 МБ (сжато)
**Частота:** каждый час

### GET /v1_api/mobile-sync/outlet-prices/{outletVendorId}
**Описание:** Индивидуальные цены для торговой точки
- Только товары с ценами, отличающимися от региональных
- Дифференциальные данные

**Размер:** ~100-500 КБ (сжато)
**Частота:** каждый час

---

## 🗂️ Правильная структура данных

### RegionalCacheResponse (полная синхронизация утром)

```protobuf
message RegionalCacheResponse {
    repeated Product products = 1;              // Все продукты региона
    repeated Warehouse warehouses = 2;          // Склады региона
    int64 sync_timestamp = 3;
    string cache_type = 4;                     // "regional_full"
    CacheStats stats = 5;
}
```

### RegionalStockResponse (обновление остатков каждый час)

```protobuf
message RegionalStockResponse {
    RegionInfo region_info = 1;                // Информация о регионе
    repeated StockItem stock_items = 2;        // Остатки на складах
    int64 sync_timestamp = 3;
    string cache_type = 4;                     // "regional_stock_update"
    CacheStats stats = 5;
}
```

### StockItem (остатки с финальными ценами)

```protobuf
message StockItem {
    int32 product_code = 1;                    // Ссылка на продукт
    int32 warehouse_id = 2;                    // ID склада
    int32 quantity = 3;                        // Остаток
    int32 reserved_quantity = 4;               // Зарезервировано
    int32 available_quantity = 5;              // Доступно к продаже
    int64 last_updated = 6;                    // Время последнего обновления
    
    // Цены для разных торговых точек (рассчитываются на бэкенде)
    repeated OutletPrice outlet_prices = 7;    // Цены для каждой точки пользователя
}
```

### OutletPrice (цена для конкретной торговой точки)

```protobuf
message OutletPrice {
    string outlet_vendor_id = 1;               // ID торговой точки
    int32 final_price = 2;                     // Итоговая цена для этой точки
    int32 regional_base_price = 3;             // Базовая цена региона
    int32 price_difference = 4;                // Разница в копейках
    float price_difference_percent = 5;         // Разница в процентах
    string price_type = 6;                     // "regional_base", "differential", "promotion"
    bool has_promotion = 7;                    // Есть ли активная акция
}
```

---

## 💾 ОПТИМИЗИРОВАННАЯ схема SQLite (исправленная версия)

### Четырехтабличная архитектура для максимальной эффективности

```sql
-- 1. Продукты (статичные, обновляется 1 раз в день)
CREATE TABLE products (
    code INTEGER PRIMARY KEY,
    bcode INTEGER,
    title TEXT NOT NULL,
    vendor_code TEXT,
    brand_name TEXT,
    manufacturer_name TEXT,
    category_name TEXT,
    -- НЕТ цен! Только карточки товаров
    sync_timestamp INTEGER,
    region_fias_id TEXT
);

-- 2. Региональные остатки (обновляется каждый час, БЕЗ индивидуальных цен)
CREATE TABLE regional_stock_items (
    id INTEGER PRIMARY KEY,
    product_code INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    warehouse_name TEXT,
    public_stock TEXT,                    -- "1666 шт."
    multiplicity INTEGER DEFAULT 1,
    regional_base_price INTEGER,          -- ТОЛЬКО базовая цена региона
    last_updated INTEGER,
    region_fias_id TEXT,
    FOREIGN KEY (product_code) REFERENCES products(code),
    UNIQUE(product_code, warehouse_id)
);

-- 3. Индивидуальные цены торговых точек (обновляется каждый час)
CREATE TABLE outlet_stock_pricing (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    stock_item_id INTEGER NOT NULL,         -- ссылка на regional_stock_items
    product_code INTEGER NOT NULL,          -- дубль для быстрого поиска
    warehouse_id INTEGER NOT NULL,          -- дубль для быстрого поиска
    outlet_vendor_id TEXT NOT NULL,         -- ID торговой точки
    
    -- Рассчитанные цены для этой торговой точки
    final_price INTEGER NOT NULL,           -- итоговая цена
    price_difference INTEGER DEFAULT 0,     -- разница с базовой
    price_difference_percent REAL DEFAULT 0,
    price_type TEXT DEFAULT 'regional_base',
    
    -- Скидки и акции
    discount_value REAL DEFAULT 0,
    has_promotion BOOLEAN DEFAULT FALSE,
    promotion_id INTEGER,                   -- ссылка на таблицу акций
    
    last_updated INTEGER,
    FOREIGN KEY (stock_item_id) REFERENCES regional_stock_items(id),
    FOREIGN KEY (product_code) REFERENCES products(code),
    UNIQUE(stock_item_id, outlet_vendor_id)
);

-- 4. Активные акции (отдельная таблица для детализации)
CREATE TABLE active_promotions (
    id INTEGER PRIMARY KEY,
    outlet_vendor_id TEXT NOT NULL,
    promotion_type TEXT,                   -- "discount", "nx", "bundle"
    title TEXT,
    description TEXT,
    valid_from INTEGER,
    valid_to INTEGER,
    discount_percent REAL,
    discount_amount INTEGER,
    -- Детали NX акций
    buy_quantity INTEGER,
    get_quantity INTEGER,
    -- Условия
    min_quantity INTEGER,
    max_quantity INTEGER,
    min_amount INTEGER
);

-- Индексы для максимальной производительности
CREATE INDEX idx_stock_items_product ON regional_stock_items(product_code);
CREATE INDEX idx_stock_items_warehouse ON regional_stock_items(warehouse_id);
CREATE INDEX idx_stock_items_region ON regional_stock_items(region_fias_id);

CREATE INDEX idx_outlet_pricing_outlet ON outlet_stock_pricing(outlet_vendor_id);
CREATE INDEX idx_outlet_pricing_product_outlet ON outlet_stock_pricing(product_code, outlet_vendor_id);
CREATE INDEX idx_outlet_pricing_warehouse_outlet ON outlet_stock_pricing(warehouse_id, outlet_vendor_id);
CREATE INDEX idx_outlet_pricing_stock_item ON outlet_stock_pricing(stock_item_id);

CREATE INDEX idx_promotions_outlet ON active_promotions(outlet_vendor_id);
CREATE INDEX idx_promotions_dates ON active_promotions(valid_from, valid_to);
```

### Ключевые преимущества новой схемы:

#### 🔥 Максимальная производительность поиска
```dart
// Получить товар с ценой для торговой точки (1 запрос!)
Future<ProductWithPrice> getProductForOutlet(int productCode, String outletVendorId) async {
  final result = await db.rawQuery('''
    SELECT 
      p.code, p.title, p.vendor_code, p.brand_name,
      rsi.warehouse_id, rsi.warehouse_name, rsi.public_stock,
      rsi.regional_base_price,
      COALESCE(osp.final_price, rsi.regional_base_price) as final_price,
      COALESCE(osp.price_type, 'regional_base') as price_type,
      COALESCE(osp.has_promotion, 0) as has_promotion,
      ap.title as promotion_title
    FROM products p
    JOIN regional_stock_items rsi ON p.code = rsi.product_code
    LEFT JOIN outlet_stock_pricing osp ON rsi.id = osp.stock_item_id AND osp.outlet_vendor_id = ?
    LEFT JOIN active_promotions ap ON osp.promotion_id = ap.id
    WHERE p.code = ?
  ''', [outletVendorId, productCode]);
  
  return ProductWithPrice.fromMap(result.first);
}
```

#### 🎯 Эффективное кеширование по типам данных
```dart
class OptimizedSyncService {
  /// ЭТАП 1: Полная синхронизация утром
  Future<void> performMorningSync(String regionFiasId, List<String> outletIds) async {
    // 1. Продукты (один раз в день)
    final products = await getRegionalProducts(regionFiasId);
    await saveProducts(products);
    
    // 2. Остатки с базовыми ценами (каждый час)
    final stockItems = await getRegionalStock(regionFiasId);
    await saveRegionalStock(stockItems);
    
    // 3. Индивидуальные цены для каждой торговой точки
    for (final outletId in outletIds) {
      final pricing = await getOutletPricing(outletId);
      await saveOutletPricing(outletId, pricing);
    }
  }
  
  /// ЭТАП 2: Часовые обновления (только остатки + цены)
  Future<void> performHourlyUpdate(String regionFiasId, List<String> outletIds) async {
    // Остатки изменились -> обновляем региональную таблицу
    final stockItems = await getRegionalStock(regionFiasId);
    await updateRegionalStock(stockItems);
    
    // Цены изменились -> обновляем индивидуальные таблицы
    for (final outletId in outletIds) {
      final pricing = await getOutletPricing(outletId);
      await updateOutletPricing(outletId, pricing);
    }
  }
}
```

### ⚡ Стратегии вычислений на бэкенде и в мобильном приложении

#### 🖥️ БЭКЕНД: Максимально предвычисляем на сервере

```php
// В RegionalStockItemService - генерируем только базовые данные
public function generateRegionalStockCache(Region $region): array
{
    // Только региональные остатки с базовыми ценами (БЕЗ торговых точек)
    $stockItems = $this->getRegionalStockItems($region);
    
    $result = [];
    foreach ($stockItems as $stockItem) {
        $result[] = [
            'id' => $stockItem->getId(),
            'product_code' => $stockItem->getProduct()->getCode(),
            'warehouse_id' => $stockItem->getWarehouse()->getId(),
            'public_stock' => $stockItem->getPublicStock(),
            'multiplicity' => $stockItem->getMultiplicity(),
            // ТОЛЬКО базовая цена региона
            'regional_base_price' => $this->aussPricingService->getRegionalBasePrice(
                $stockItem->getProduct(), 
                $region
            ),
        ];
    }
    
    return ['stock_items' => $result];
}

// В OutletSpecificPricingService - генерируем дифференциальные цены
public function generateOutletPricing(Outlet $outlet): array
{
    $stockItems = $this->getStockItemsForOutlet($outlet);
    $region = $outlet->getRegionalUnit()->getAddress()->getRegion();
    
    $outletPricing = [];
    foreach ($stockItems as $stockItem) {
        // Получаем базовую цену региона
        $regionalPrice = $this->aussPricingService->getRegionalBasePrice(
            $stockItem->getProduct(), 
            $region
        );
        
        // Рассчитываем индивидуальную цену для точки
        $finalPrice = $this->aussPricingService->calculateFinalPrice(
            $outlet, 
            $stockItem->getProduct()
        );
        
        // Передаем только если цена отличается от региональной
        if ($finalPrice !== $regionalPrice) {
            $outletPricing[] = [
                'stock_item_id' => $stockItem->getId(),
                'product_code' => $stockItem->getProduct()->getCode(),
                'warehouse_id' => $stockItem->getWarehouse()->getId(),
                'final_price' => $finalPrice,
                'price_difference' => $finalPrice - $regionalPrice,
                'price_difference_percent' => (($finalPrice - $regionalPrice) / $regionalPrice) * 100,
                'price_type' => $this->determinePriceType($outlet, $stockItem),
                'has_promotion' => $this->hasActivePromotion($outlet, $stockItem),
            ];
        }
    }
    
    return ['outlet_pricing' => $outletPricing];
}
```

#### 📱 МОБИЛЬНОЕ ПРИЛОЖЕНИЕ: Умное кеширование и lazy loading

```dart
class MobileProductService {
  /// Стратегия 1: Кеширование с приоритетами
  Future<void> performIntelligentSync(String regionFiasId, List<String> outletIds) async {
    // ПРИОРИТЕТ 1: Продукты (background, низкий приоритет)
    await _syncProducts(regionFiasId, priority: 'low');
    
    // ПРИОРИТЕТ 2: Остатки первой торговой точки (высокий приоритет)
    if (outletIds.isNotEmpty) {
      await _syncStockForOutlet(regionFiasId, outletIds.first, priority: 'high');
    }
    
    // ПРИОРИТЕТ 3: Остальные торговые точки (background)
    for (final outletId in outletIds.skip(1)) {
      await _syncStockForOutlet(regionFiasId, outletId, priority: 'low');
    }
  }
  
  /// Стратегия 2: Lazy loading с кешированием результатов
  Future<List<ProductWithStockAndPrice>> getProductsForOutlet(
    String outletVendorId, {
    int page = 0,
    int limit = 50,
    String? searchQuery,
  }) async {
    // Проверяем кеш результатов поиска
    final cacheKey = 'products_${outletVendorId}_${page}_${searchQuery ?? "all"}';
    final cached = await _resultCache.get(cacheKey);
    if (cached != null && _isCacheValid(cached)) {
      return cached.products;
    }
    
    // Выполняем оптимизированный запрос к SQLite
    final query = _buildOptimizedQuery(outletVendorId, searchQuery);
    final result = await db.rawQuery(query, [
      outletVendorId,
      limit,
      page * limit,
      if (searchQuery != null) '%$searchQuery%',
    ]);
    
    final products = result.map((row) => ProductWithStockAndPrice.fromMap(row)).toList();
    
    // Кешируем результат на 10 минут
    await _resultCache.put(cacheKey, CachedResult(products, DateTime.now()));
    
    return products;
  }
  
  /// Стратегия 3: Предсказательное кеширование
  Future<void> preloadPopularProducts(String outletVendorId) async {
    // Предзагружаем топ-100 популярных товаров
    final popularProducts = await db.rawQuery('''
      SELECT product_code, COUNT(*) as order_count
      FROM order_history 
      WHERE outlet_vendor_id = ? 
      GROUP BY product_code 
      ORDER BY order_count DESC 
      LIMIT 100
    ''', [outletVendorId]);
    
    // Предзагружаем их данные в память
    for (final product in popularProducts) {
      await getProductForOutlet(product['product_code'], outletVendorId);
    }
  }
  
  /// Стратегия 4: Дифференциальные обновления
  Future<void> performSmartUpdate(String regionFiasId, List<String> outletIds) async {
    final lastSync = await getLastSyncTimestamp();
    
    // Проверяем что изменилось с последней синхронизации
    final changes = await checkChanges(regionFiasId, outletIds, lastSync);
    
    if (changes.hasProductChanges) {
      // Обновляем только измененные продукты
      await updateChangedProducts(changes.changedProducts);
    }
    
    if (changes.hasStockChanges) {
      // Обновляем только остатки по измененным складам
      await updateChangedStock(changes.changedWarehouses);
    }
    
    if (changes.hasPriceChanges) {
      // Обновляем цены только для измененных точек
      await updateChangedPricing(changes.changedOutlets);
    }
  }
}
```

## 🎯 Конкретные рекомендации по оптимизации:

### 1. **Разделение вычислений бэкенд/мобильное приложение**

**БЭКЕНД делает:**
- ✅ Расчет всех цен через AussPricingService
- ✅ Определение активных акций  
- ✅ Вычисление дифференциальных данных
- ✅ Сжатие protobuf + gzip
- ✅ Кеширование результатов в файлах

**МОБИЛЬНОЕ ПРИЛОЖЕНИЕ делает:**
- ✅ Умное кеширование по типам данных
- ✅ Lazy loading с пагинацией
- ✅ Предсказательное кеширование популярных товаров
- ✅ Дифференциальные обновления
- ✅ Индексирование SQLite для быстрого поиска

### 2. **Оптимизация размера данных**

```dart
// Пример экономии: Вместо 7000 товаров с ценами каждый час
// передаем только ~110 измененных цен

class DataOptimization {
  /// До оптимизации: 7000 товаров × 4 точки = 28,000 записей/час
  /// После оптимизации: 110 измененных цен × 4 точки = 440 записей/час
  /// Экономия: 98.4% трафика!
  
  static const int PRODUCTS_COUNT = 7000;
  static const int AVERAGE_DIFFERENTIAL_PRICES = 110;
  static const int OUTLETS_COUNT = 4;
  
  static double calculateTrafficSaving() {
    final beforeOptimization = PRODUCTS_COUNT * OUTLETS_COUNT;
    final afterOptimization = AVERAGE_DIFFERENTIAL_PRICES * OUTLETS_COUNT;
    
    return ((beforeOptimization - afterOptimization) / beforeOptimization) * 100;
    // Результат: 98.4% экономии трафика
  }
}
```

### 3. **Умные стратегии синхронизации**

```dart
class SyncStrategy {
  /// Утренняя синхронизация (06:00)
  static Future<void> morningFullSync() async {
    await performFullSync(); // Все данные
  }
  
  /// Дневная синхронизация (каждый час 09:00-18:00)
  static Future<void> businessHourSync() async {
    await updateStockOnly(); // Только остатки
    await updatePricingOnly(); // Только цены
  }
  
  /// Вечерняя синхронизация (19:00-23:00) 
  static Future<void> eveningLightSync() async {
    await updatePricingOnly(); // Только цены
  }
  
  /// Ночная синхронизация (00:00-05:00)
  static Future<void> nightMaintenanceSync() async {
    await cleanupOldCache(); // Очистка
    await optimizeDatabase(); // Оптимизация SQLite
  }
}
```