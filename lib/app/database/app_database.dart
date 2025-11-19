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
import 'tables/product_facet_table.dart';
import 'tables/order_table.dart';
import 'tables/order_line_table.dart';
import 'tables/stock_item_table.dart';
import 'tables/warehouse_table.dart';
import 'tables/order_job_table.dart';
import 'tables/sync_log_table.dart';
import 'migrations/initial_schema_migration.dart';

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
  SyncLogs,
  ProductFacets,
  ProductCategoryFacets,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection('app_database.db'));
  AppDatabase.withFile(String dbFileName) : super(_openConnection(dbFileName));

  // Конструктор для тестов
  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 9; // v9: consolidated baseline migration

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      _dbLogger.info('🆕 Создание новой БД версии $schemaVersion');
      await m.createAll();
      
      // Создаём FTS5 таблицу и триггеры (миграция v2)
      await InitialSchemaMigration.setup(this);
      
      // Включаем foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');
      _dbLogger.info('✅ БД создана с версией $schemaVersion');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      _dbLogger.info('🔄 Миграция БД с версии $from на $to');
      
      if (from < schemaVersion) {
        await InitialSchemaMigration.resetCatalogAndSetup(this);
      }
      
      _dbLogger.info('✅ БД обновлена до версии $to');
    },
    /* 
    // ⚠️ ДЕСТРУКТИВНАЯ СТРАТЕГИЯ - ЗАКОММЕНТИРОВАНА ДЛЯ PRODUCTION
    // Используйте для локальной разработки при необходимости полного сброса БД
    onUpgrade: (Migrator m, int from, int to) async {
      _dbLogger.info('🔄 Обновление БД с версии $from на $to');
      
      // Простая стратегия: пересоздаем все таблицы
      _dbLogger.warning('⚠️ Пересоздание всех таблиц (данные будут потеряны)');
      
      // Отключаем foreign keys для безопасного удаления
      await customStatement('PRAGMA foreign_keys = OFF');
      
      // Удаляем все таблицы
      for (final table in allTables) {
        await customStatement('DROP TABLE IF EXISTS ${table.actualTableName};');
      }
      
      // Создаем заново
      await m.createAll();
      
      // Включаем foreign keys обратно
      await customStatement('PRAGMA foreign_keys = ON');
      
      _dbLogger.info('✅ БД обновлена до версии $to');
    },
    */
    beforeOpen: (details) async {
      // Включаем foreign key constraints для всех соединений
      await customStatement('PRAGMA foreign_keys = ON');
      
      // Создаем индексы после того, как все таблицы точно созданы
      try {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sync_logs_created_at ON sync_logs(created_at DESC);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sync_logs_task_created_at ON sync_logs(task, created_at DESC);',
        );
        _dbLogger.info('✅ Индексы для sync_logs созданы');
      } catch (e) {
        _dbLogger.warning('⚠️ Ошибка создания индексов sync_logs: $e');
      }
      
      if (details.hadUpgrade) {
        _dbLogger.info('БД была обновлена с версии ${details.versionBefore} на ${details.versionNow}');
      } else if (details.wasCreated) {
        _dbLogger.info('БД создана с версией ${details.versionNow}');
      }
    },
  );
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
