# База Данных FieldForce - Схема v1.0

## Общая информация

- **Schema Version**: 1
- **ORM**: Drift
- **Foreign Keys**: Включены (PRAGMA foreign_keys = ON)
- **Платформы**: Android, Windows, iOS

## Принципы миграций

### Production (Release builds)
- **НИКОГДА** не удаляем данные при обновлении схемы
- Миграции выполняются через `MigrationStrategy.onUpgrade`
- Каждое изменение схемы = инкремент `schemaVersion`
- Миграции должны быть **идемпотентными** (можно запустить несколько раз)

### Development (Local)
- Для полного сброса БД можно раскомментировать деструктивную стратегию в `app_database.dart`
- Либо удалить файл БД вручную из директории приложения

## Таблицы

### Аутентификация и Пользователи

#### `users`
Таблица пользователей для аутентификации (Security-слой).

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT NOT NULL UNIQUE,
  role TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  hashed_password TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Роли**: `admin`, `manager`, `user`

#### `employees`
Бизнес-сущность сотрудника (связана с users).

```sql
CREATE TABLE employees (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  first_name TEXT NOT NULL,
  middle_name TEXT,
  last_name TEXT,
  role TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**Роли**: `sales`, `supervisor`, `manager`

#### `app_users`
App-уровневая сущность пользователя (агрегирует User + Employee).

```sql
CREATE TABLE app_users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  selected_trading_point_id INTEGER,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (selected_trading_point_id) REFERENCES trading_point_entities(id)
);
```

### Маршруты и Локации

#### `routes`
Маршруты для торговых представителей.

```sql
CREATE TABLE routes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  employee_id INTEGER NOT NULL,
  scheduled_date INTEGER,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);
```

**Статусы**: `draft`, `scheduled`, `active`, `completed`, `cancelled`

#### `points_of_interest`
Точки интереса на маршруте (адреса, магазины и т.д.).

```sql
CREATE TABLE points_of_interest (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route_id INTEGER NOT NULL,
  trading_point_id INTEGER,
  name TEXT NOT NULL,
  description TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  visit_order INTEGER NOT NULL,
  status TEXT NOT NULL,
  visited_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  FOREIGN KEY (trading_point_id) REFERENCES trading_points(id)
);
```

**Статусы**: `pending`, `visited`, `skipped`

#### `trading_points`
**DEPRECATED**: Старая таблица торговых точек. Используйте `trading_point_entities`.

#### `trading_point_entities`
Торговые точки (магазины, аптеки и т.д.).

```sql
CREATE TABLE trading_point_entities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  inn TEXT,
  region TEXT NOT NULL,
  latitude REAL,
  longitude REAL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Регионы**: `P3V` (Владивосток), `M3V` (Магадан), `K3V` (Камчатка)

#### `employee_trading_point_assignments`
Связь торговых представителей с торговыми точками.

```sql
CREATE TABLE employee_trading_point_assignments (
  employee_id INTEGER NOT NULL,
  trading_point_external_id TEXT NOT NULL,
  PRIMARY KEY (employee_id, trading_point_external_id),
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
  FOREIGN KEY (trading_point_external_id) REFERENCES trading_point_entities(external_id)
);
```

### GPS-треки

#### `user_tracks`
Подробные GPS-треки пользователей (каждая точка).

```sql
CREATE TABLE user_tracks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  route_id INTEGER,
  timestamp INTEGER NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  accuracy REAL,
  altitude REAL,
  speed REAL,
  heading REAL,
  battery_level REAL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE SET NULL
);
```

#### `compact_tracks`
Упрощенные треки (для оптимизации хранения/передачи).

```sql
CREATE TABLE compact_tracks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  route_id INTEGER,
  start_time INTEGER NOT NULL,
  end_time INTEGER NOT NULL,
  encoded_path TEXT NOT NULL,
  distance_meters REAL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE SET NULL
);
```

### Рабочие дни

#### `work_days`
Запись рабочих дней и чек-инов/чек-аутов.

```sql
CREATE TABLE work_days (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  employee_id INTEGER NOT NULL,
  date INTEGER NOT NULL,
  check_in_time INTEGER,
  check_in_latitude REAL,
  check_in_longitude REAL,
  check_out_time INTEGER,
  check_out_latitude REAL,
  check_out_longitude REAL,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);
```

**Статусы**: `pending`, `checked_in`, `checked_out`, `completed`

### Каталог и Товары

#### `categories`
Категории товаров (древовидная структура).

```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  parent_external_id TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  image_url TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (parent_external_id) REFERENCES categories(external_id)
);
```

#### `products`
Товары.

```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  vendor_code TEXT,
  category_external_id TEXT,
  barcode TEXT,
  image_url TEXT,
  properties_json TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  min_order_quantity INTEGER,
  packaging_type TEXT,
  packaging_quantity INTEGER,
  weight REAL,
  volume REAL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (category_external_id) REFERENCES categories(external_id)
);
```

#### `warehouses`
Склады.

```sql
CREATE TABLE warehouses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  region TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

#### `stock_items`
Остатки товаров на складах.

```sql
CREATE TABLE stock_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_external_id TEXT NOT NULL,
  warehouse_external_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  reserved_quantity INTEGER NOT NULL DEFAULT 0,
  available_quantity INTEGER NOT NULL DEFAULT 0,
  base_price REAL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (product_external_id) REFERENCES products(external_id),
  FOREIGN KEY (warehouse_external_id) REFERENCES warehouses(external_id),
  UNIQUE (product_external_id, warehouse_external_id)
);
```

### Заказы

#### `orders`
Заказы (включая корзины в статусе `draft`).

```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT UNIQUE,
  employee_id INTEGER NOT NULL,
  trading_point_external_id TEXT NOT NULL,
  warehouse_external_id TEXT NOT NULL,
  status TEXT NOT NULL,
  total_amount REAL NOT NULL DEFAULT 0,
  discount_amount REAL NOT NULL DEFAULT 0,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  submitted_at INTEGER,
  approved_at INTEGER,
  rejected_at INTEGER,
  FOREIGN KEY (employee_id) REFERENCES employees(id),
  FOREIGN KEY (trading_point_external_id) REFERENCES trading_point_entities(external_id),
  FOREIGN KEY (warehouse_external_id) REFERENCES warehouses(external_id)
);
```

**Статусы**: `draft`, `submitted`, `approved`, `rejected`, `completed`

#### `order_lines`
Строки заказа (позиции товаров).

```sql
CREATE TABLE order_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  stock_item_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  total_price REAL NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (stock_item_id) REFERENCES stock_items(id)
);
```

#### `order_jobs`
Очередь отправки заказов на сервер (фоновая синхронизация).

```sql
CREATE TABLE order_jobs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  status TEXT NOT NULL,
  retry_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  next_retry_at INTEGER,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  UNIQUE (order_id)
);
```

**Статусы**: `pending`, `processing`, `completed`, `failed`

### Синхронизация

#### `sync_logs`
Логи синхронизации данных с сервером.

```sql
CREATE TABLE sync_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task TEXT NOT NULL,
  status TEXT NOT NULL,
  details TEXT,
  error_message TEXT,
  started_at INTEGER NOT NULL,
  completed_at INTEGER,
  created_at INTEGER NOT NULL
);

CREATE INDEX idx_sync_logs_created_at ON sync_logs(created_at DESC);
CREATE INDEX idx_sync_logs_task_created_at ON sync_logs(task, created_at DESC);
```

**Задачи**: `regional_sync`, `regional_stock`, `outlet_pricing`, `order_upload`
**Статусы**: `started`, `completed`, `failed`

## Миграции (История)

### v1 (Initial Schema) - 2025-11-07
- Создание всех базовых таблиц
- Включение foreign keys
- Индексы для sync_logs

### Будущие миграции

Примеры миграций для следующих версий:

```dart
onUpgrade: (Migrator m, int from, int to) async {
  // v1 -> v2: Добавить колонку email в users
  if (from == 1 && to == 2) {
    await m.addColumn(users, users.email);
  }
  
  // v2 -> v3: Создать таблицу notifications
  if (from <= 2 && to >= 3) {
    await m.createTable(notifications);
  }
  
  // v3 -> v4: Изменить тип данных (требует пересоздания)
  if (from <= 3 && to >= 4) {
    // Создаем временную таблицу
    await customStatement('CREATE TABLE orders_new AS SELECT * FROM orders');
    await customStatement('DROP TABLE orders');
    await m.createTable(orders);
    await customStatement('INSERT INTO orders SELECT * FROM orders_new');
    await customStatement('DROP TABLE orders_new');
  }
}
```

## Правила работы с БД

### При добавлении новых полей
1. Увеличить `schemaVersion` на 1
2. Добавить миграцию в `onUpgrade`
3. Обновить фикстуры в `DevFixtureOrchestrator`
4. Протестировать миграцию на копии production БД
5. Обновить этот документ

### При удалении полей
1. Сначала выпустить версию, которая НЕ ИСПОЛЬЗУЕТ это поле
2. Дождаться обновления всех клиентов
3. В следующей версии удалить поле физически

### При изменении типа данных
1. Создать новую колонку с новым типом
2. Скопировать данные с конвертацией
3. Удалить старую колонку
4. Переименовать новую колонку (если нужно)

### Тестирование миграций
```dart
test('Migration from v1 to v2 preserves data', () async {
  // 1. Создать БД версии 1
  // 2. Заполнить тестовыми данными
  // 3. Закрыть БД
  // 4. Открыть с версией 2
  // 5. Проверить, что данные на месте и в правильном формате
});
```

## Backup и Recovery

### Локальный Backup (для тестирования)
```dart
// Копировать файл БД
final dbFolder = await getApplicationDocumentsDirectory();
final dbFile = File(p.join(dbFolder.path, 'fieldforce.db'));
final backupFile = File(p.join(dbFolder.path, 'fieldforce_backup.db'));
await dbFile.copy(backupFile.path);
```

### Recovery
- При критической ошибке: удалить БД и пересоздать (потеря данных)
- Для production: реализовать механизм синхронизации с сервером

## Performance

### Индексы
- `sync_logs`: индексы на `created_at` и `(task, created_at)` для быстрых запросов последних синхронизаций
- При необходимости добавить индексы на часто запрашиваемые поля (например, `orders.status`, `products.category_external_id`)

### Оптимизация
- Foreign keys включены для целостности данных
- Используйте транзакции для массовых операций
- Batch inserts через `batch()` для фикстур
- Регулярная очистка старых логов синхронизации

## Безопасность

- Пароли хранятся в хешированном виде (`hashed_password`)
- БД хранится в защищенной директории приложения
- Нет прямого SQL injection (Drift защищает)
- Sensitive данные (телефоны, координаты) - соблюдать GDPR/законодательство РФ

---

**Дата создания**: 2025-11-07  
**Последнее обновление**: 2025-11-07  
**Maintainer**: Development Team
