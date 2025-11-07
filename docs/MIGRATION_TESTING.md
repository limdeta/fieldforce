# Тестирование миграций базы данных

## Зачем нужны тесты миграций?

В production-приложении данные пользователя должны сохраняться при обновлениях. Миграции БД — критически важная часть, которая может привести к потере данных если работает неправильно.

## Процесс тестирования миграций

### 1. Подготовка тестовой БД

Создайте файл с БД старой версии, заполненный реалистичными данными.

```dart
// test/database/migrations/create_v1_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Создает БД версии 1 с тестовыми данными
Future<void> createV1Database(String path) async {
  final connection = NativeDatabase.memory(); // или File для сохранения
  final db = AppDatabaseV1(connection); // старая версия схемы
  
  // Заполняем тестовыми данными
  await db.into(db.users).insert(UsersCompanion.insert(
    externalId: 'test-user-1',
    role: 'user',
    phoneNumber: '+79991112233',
    hashedPassword: 'hashed_password',
  ));
  
  // ... больше тестовых данных
  
  await db.close();
}
```

### 2. Тест миграции

```dart
// test/database/migrations/migration_v1_to_v2_test.dart
import 'package:test/test.dart';

void main() {
  test('Migration from v1 to v2 preserves user data', () async {
    // 1. Создаем БД версии 1
    final tempDir = await getTemporaryDirectory();
    final dbPath = '${tempDir.path}/test_v1.db';
    await createV1Database(dbPath);
    
    // 2. Читаем данные ДО миграции
    var db = AppDatabase.withFile(dbPath);
    final usersBefore = await db.select(db.users).get();
    expect(usersBefore, hasLength(greaterThan(0)));
    await db.close();
    
    // 3. Открываем БД с новой версией (миграция запустится автоматически)
    db = AppDatabaseV2.withFile(dbPath);
    
    // 4. Проверяем, что данные сохранились
    final usersAfter = await db.select(db.users).get();
    expect(usersAfter.length, equals(usersBefore.length));
    
    // 5. Проверяем, что новые поля добавились
    final firstUser = usersAfter.first;
    expect(firstUser.email, isNotNull); // новое поле в v2
    
    await db.close();
    
    // Чистим
    await File(dbPath).delete();
  });
  
  test('Migration from v1 to v2 adds email column with default', () async {
    // Аналогично, но проверяем конкретное изменение схемы
  });
  
  test('Migration is idempotent - can run multiple times', () async {
    // Проверяем, что повторный запуск миграции не ломает данные
    final tempDir = await getTemporaryDirectory();
    final dbPath = '${tempDir.path}/test_idempotent.db';
    
    await createV1Database(dbPath);
    
    // Первая миграция
    var db = AppDatabaseV2.withFile(dbPath);
    await db.close();
    
    // Вторая миграция (не должна упасть)
    db = AppDatabaseV2.withFile(dbPath);
    final users = await db.select(db.users).get();
    expect(users, isNotEmpty);
    
    await db.close();
    await File(dbPath).delete();
  });
}
```

### 3. Ручное тестирование на устройстве

**Сценарий:**
1. Установить старую версию APK
2. Залогиниться и создать тестовые данные (заказы, маршруты и т.д.)
3. Записать скриншоты данных
4. Установить новую версию APK (обновление)
5. Открыть приложение
6. Проверить, что все данные на месте
7. Сверить со скриншотами

**Чеклист данных для проверки:**
- [ ] Пользователь остался залогинен
- [ ] Профиль пользователя заполнен
- [ ] Список торговых точек на месте
- [ ] Маршруты сохранились
- [ ] Заказы в корзине не потерялись
- [ ] GPS-треки доступны
- [ ] Настройки приложения сохранились

### 4. Откат при ошибке

Если миграция не прошла:

```dart
// В app_database.dart можно добавить fallback:
onUpgrade: (Migrator m, int from, int to) async {
  try {
    // Миграция
    await _performMigration(m, from, to);
  } catch (e, st) {
    _dbLogger.severe('❌ Ошибка миграции', e, st);
    
    // Варианты:
    // 1. Откатиться к предыдущей версии (если возможно)
    // 2. Сохранить дамп и пересоздать БД
    // 3. Показать пользователю сообщение
    
    // Для критичных случаев: backup + пересоздание
    await _backupAndRecreate(m);
  }
}

Future<void> _backupAndRecreate(Migrator m) async {
  // Экспортировать критичные данные в JSON
  final users = await select(users).get();
  final backup = {'users': users.map((u) => u.toJson()).toList()};
  
  // Сохранить в shared_preferences или файл
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('db_backup', jsonEncode(backup));
  
  // Пересоздать БД
  await customStatement('PRAGMA foreign_keys = OFF');
  for (final table in allTables) {
    await customStatement('DROP TABLE IF EXISTS ${table.actualTableName}');
  }
  await m.createAll();
  await customStatement('PRAGMA foreign_keys = ON');
  
  // Восстановить из backup
  // ...
}
```

## Лучшие практики

### ✅ DO

1. **Всегда тестируйте миграции** перед релизом
2. **Сохраняйте snapshot БД** каждой версии для тестов
3. **Логируйте каждый шаг миграции** для отладки
4. **Используйте транзакции** для атомарности
5. **Тестируйте на реальных устройствах** с реальными данными

### ❌ DON'T

1. **Не удаляйте данные** без крайней необходимости
2. **Не забывайте про foreign keys** при изменении таблиц
3. **Не делайте миграции слишком сложными** (разбейте на версии)
4. **Не тестируйте только в памяти** (файловая БД ведет себя иначе)
5. **Не пропускайте версии** (миграция 1→3 должна работать)

## Примеры распространенных миграций

### Добавление колонки

```dart
// v1 -> v2: Добавить email в users
if (from == 1 && to == 2) {
  await m.addColumn(users, users.email);
  _dbLogger.info('✅ Добавлена колонка email в users');
}
```

### Удаление колонки

```dart
// v2 -> v3: Удалить deprecated_field
if (from == 2 && to == 3) {
  // SQLite не поддерживает DROP COLUMN напрямую
  // Нужно пересоздать таблицу
  
  await customStatement('PRAGMA foreign_keys = OFF');
  
  // Создаем новую таблицу
  await customStatement('''
    CREATE TABLE users_new (
      id INTEGER PRIMARY KEY,
      external_id TEXT NOT NULL,
      email TEXT,
      -- deprecated_field удалено
    )
  ''');
  
  // Копируем данные
  await customStatement('''
    INSERT INTO users_new SELECT 
      id, external_id, email 
    FROM users
  ''');
  
  // Удаляем старую
  await customStatement('DROP TABLE users');
  
  // Переименовываем
  await customStatement('ALTER TABLE users_new RENAME TO users');
  
  await customStatement('PRAGMA foreign_keys = ON');
  
  _dbLogger.info('✅ Удалена колонка deprecated_field из users');
}
```

### Создание таблицы

```dart
// v3 -> v4: Добавить таблицу notifications
if (from == 3 && to == 4) {
  await m.createTable(notifications);
  _dbLogger.info('✅ Создана таблица notifications');
}
```

### Изменение типа данных

```dart
// v4 -> v5: Изменить phone_number с TEXT на INTEGER
if (from == 4 && to == 5) {
  await customStatement('PRAGMA foreign_keys = OFF');
  
  await customStatement('''
    CREATE TABLE users_new (
      id INTEGER PRIMARY KEY,
      external_id TEXT NOT NULL,
      phone_number INTEGER NOT NULL  -- было TEXT
    )
  ''');
  
  // Конвертация при копировании
  await customStatement('''
    INSERT INTO users_new SELECT 
      id, 
      external_id, 
      CAST(REPLACE(phone_number, '+', '') AS INTEGER)
    FROM users
  ''');
  
  await customStatement('DROP TABLE users');
  await customStatement('ALTER TABLE users_new RENAME TO users');
  await customStatement('PRAGMA foreign_keys = ON');
  
  _dbLogger.info('✅ Изменен тип phone_number на INTEGER');
}
```

### Миграция данных с трансформацией

```dart
// v5 -> v6: Разделить full_name на first_name и last_name
if (from == 5 && to == 6) {
  await m.addColumn(users, users.firstName);
  await m.addColumn(users, users.lastName);
  
  // Разбиваем существующие данные
  final allUsers = await select(users).get();
  for (final user in allUsers) {
    final parts = user.fullName.split(' ');
    await (update(users)..where((u) => u.id.equals(user.id))).write(
      UsersCompanion(
        firstName: Value(parts.first),
        lastName: Value(parts.length > 1 ? parts.last : ''),
      ),
    );
  }
  
  _dbLogger.info('✅ Разделено full_name на first_name и last_name');
}
```

## CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Test Migrations

on: [push, pull_request]

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
        
      - name: Generate code
        run: flutter pub run build_runner build
        
      - name: Run migration tests
        run: flutter test test/database/migrations/
        
      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v2
        with:
          name: migration-test-results
          path: test-results/
```

## Мониторинг в Production

Добавьте телеметрию для отслеживания миграций:

```dart
beforeOpen: (details) async {
  if (details.hadUpgrade) {
    final from = details.versionBefore;
    final to = details.versionNow;
    
    // Логируем успешную миграцию
    _dbLogger.info('✅ Миграция $from → $to успешна');
    
    // Отправляем метрику (Firebase, Sentry и т.д.)
    // analytics.logEvent('db_migration_success', {
    //   'from': from,
    //   'to': to,
    //   'duration_ms': migrationDuration,
    // });
  }
}
```

---

**Важно**: Миграции БД — это критичная часть приложения. Всегда тестируйте на реальных устройствах перед релизом!
