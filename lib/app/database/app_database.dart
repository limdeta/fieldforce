import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logging/logging.dart';
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
import 'tables/warehouse_table.dart';
import 'tables/order_job_table.dart';

part 'app_database.g.dart';

/// Logger for database operations
final Logger _dbLogger = Logger('AppDatabase');

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
  OrderJobs,
  Warehouses,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection('app_database.db'));
  AppDatabase.withFile(String dbFileName) : super(_openConnection(dbFileName));

  // Конструктор для тестов
  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Включаем foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      _dbLogger.info('Миграция БД с версии $from на $to');

      if (from < 4) {
        await customStatement(
          "UPDATE trading_point_entities SET region = 'P3V' WHERE region IS NULL OR TRIM(region) = '';",
        );

        await customStatement('ALTER TABLE trading_point_entities RENAME TO trading_point_entities_old;');
        await m.createTable(tradingPointEntities);
        await customStatement('''
          INSERT INTO trading_point_entities (id, external_id, name, inn, region, created_at, updated_at)
          SELECT id, external_id, name, inn, COALESCE(region, 'P3V'), created_at, updated_at
          FROM trading_point_entities_old;
        ''');
        await customStatement('DROP TABLE trading_point_entities_old;');
      }

      if (from < 5) {
        await m.createTable(warehouses);
      }

      await m.createAll();
    },
    beforeOpen: (details) async {
      // Включаем foreign key constraints для всех соединений
      await customStatement('PRAGMA foreign_keys = ON');
      
      if (details.hadUpgrade) {
        _dbLogger.info('БД была обновлена с версии ${details.versionBefore} на ${details.versionNow}');
      } else if (details.wasCreated) {
        _dbLogger.info('БД создана с версией ${details.versionNow}');
      }
    },
  );

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
}

LazyDatabase _openConnection(String dbFileName) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    _dbLogger.info('=== DB FOLDER: ${dbFolder.path}');
    final file = File(p.join(dbFolder.path, dbFileName));
    _dbLogger.info('=== DB FILE: ${file.path}');
    // Обеспечиваем поддержку SQLite на всех платформах
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    sqlite3.tempDirectory = dbFolder.path;
    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
      setup: (database) {
        // Включаем foreign key constraints для всех соединений
        database.execute('PRAGMA foreign_keys = ON');
      },
    );
  });
}
