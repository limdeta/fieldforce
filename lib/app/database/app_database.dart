import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables/user_table.dart';
import 'tables/employee_table.dart';
import 'tables/route_table.dart';
import 'tables/point_of_interest_table.dart';
import 'tables/trading_point_table.dart';
import 'tables/trading_point_entity_table.dart';
import 'tables/employee_trading_point_assignment_table.dart';
import 'tables/user_track_table.dart';
import 'tables/compact_track_table.dart';
import 'tables/app_user_table.dart';
import 'tables/work_day_table.dart';
import 'tables/category_table.dart';
import 'tables/product_table.dart';
import 'tables/order_table.dart';
import 'tables/order_line_table.dart';
import 'tables/stock_item_table.dart';
import 'migrations/stock_item_indexes.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Employees,
  Routes,
  PointsOfInterest,
  TradingPoints,
  TradingPointEntities,
  EmployeeTradingPointAssignments,
  UserTracks,
  CompactTracks,
  AppUsers,
  WorkDays,
  Categories,
  Products,
  Orders,
  OrderLines,
  StockItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection('app_database.db'));
  AppDatabase.withFile(String dbFileName) : super(_openConnection(dbFileName));

  // Конструктор для тестов
  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 8;

  // Методы для работы с торговыми точками
  // TODO вынести в репозитории и отрефакторить
  Future<void> upsertTradingPoint(TradingPointEntitiesCompanion companion) async {

    if (companion.externalId.present) {
      final existing = await getTradingPointByExternalId(companion.externalId.value);
      
      if (existing != null) {
        await (update(tradingPointEntities)
          ..where((tp) => tp.externalId.equals(companion.externalId.value))
        ).write(companion);
      } else {
        await into(tradingPointEntities).insert(companion);
      }
    } else {
      await into(tradingPointEntities).insert(companion);
    }
  }

  Future<TradingPointEntity?> getTradingPointByExternalId(String externalId) async {
    final query = select(tradingPointEntities)
      ..where((tp) => tp.externalId.equals(externalId));
    return await query.getSingleOrNull();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Включаем foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Включаем foreign key constraints при обновлении
      await customStatement('PRAGMA foreign_keys = ON');
      
      if (from < 2) {
        // Добавляем таблицу связей сотрудников и торговых точек
        await m.createTable(employeeTradingPointAssignments);
      }

      if (from < 3) {
        // Добавляем таблицу категорий
        await m.createTable(categories);
      }

      if (from < 4) {
        // Добавляем таблицу продуктов
        await m.createTable(products);
      }

      if (from < 5) {
        // Добавляем таблицы заказов
        await m.createTable(orders);
        await m.createTable(orderLines);
      }

      if (from < 6) {
        // Безопасное обновление order_lines: заменяем productId на stockItemId если существует
        try {
          // Проверяем существование колонки productId
          final result = await customSelect("PRAGMA table_info(order_lines)").get();
          final hasProductId = result.any((row) => row.data['name'] == 'productId');
          
          if (hasProductId) {
            await customStatement('ALTER TABLE order_lines RENAME COLUMN productId TO stockItemId');
          }
        } catch (e) {
          // Колонка productId не существует или уже была переименована - это нормально
          print('Миграция v6: колонка productId не найдена или уже обновлена');
        }
      }

      if (from < 7) {
        // Добавляем таблицу остатков и цен
        await m.createTable(stockItems);
        
        // Создаем индексы для оптимизации производительности
        for (final indexSql in StockItemIndexes.createIndexes) {
          await customStatement(indexSql);
        }
      }

      if (from < 8) {
        // Исправляем Foreign Key в orders: outlet_id теперь ссылается на trading_point_entities
        // Проверяем существование таблицы orders
        try {
          final result = await customSelect("SELECT name FROM sqlite_master WHERE type='table' AND name='orders'").get();
          if (result.isNotEmpty) {
            // Таблица orders существует - пересоздаем с правильными Foreign Key
            await customStatement('ALTER TABLE orders RENAME TO orders_old');
            await m.createTable(orders);
            
            // Копируем данные из старой таблицы в новую
            await customStatement('''
              INSERT INTO orders (id, creator_id, outlet_id, state, payment_type, payment_details, 
                                 payment_is_cash, payment_is_card, payment_is_credit, comment, name, 
                                 is_pickup, approved_delivery_day, approved_assembly_day, 
                                 with_realization, created_at, updated_at)
              SELECT id, creator_id, outlet_id, state, payment_type, payment_details, 
                     payment_is_cash, payment_is_card, payment_is_credit, comment, name, 
                     is_pickup, approved_delivery_day, approved_assembly_day, 
                     with_realization, created_at, updated_at
              FROM orders_old
            ''');
            
            // Удаляем старую таблицу
            await customStatement('DROP TABLE orders_old');
          }
        } catch (e) {
          // Таблица orders не существует - это нормально для новой базы
          print('Миграция v8: таблица orders не найдена - пропускаем миграцию');
        }
      }
    },
  );
}

LazyDatabase _openConnection(String dbFileName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    print('=== DB FOLDER: [32m${dbFolder.path}[0m');
    final file = File(p.join(dbFolder.path, dbFileName));
    print('=== DB FILE: [32m${file.path}[0m');
    // Обеспечиваем поддержку SQLite на всех платформах
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    sqlite3.tempDirectory = dbFolder.path;
    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
    );
  });
}
