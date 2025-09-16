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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection('app_database.db'));
  AppDatabase.withFile(String dbFileName) : super(_openConnection(dbFileName));

  // Конструктор для тестов
  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 6;

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
        // Обновляем order_lines: заменяем productId на stockItemId
        await customStatement('ALTER TABLE order_lines RENAME COLUMN productId TO stockItemId');
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
