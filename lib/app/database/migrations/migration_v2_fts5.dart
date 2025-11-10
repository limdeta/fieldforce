// lib/app/database/migrations/migration_v2_fts5.dart

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

/// Миграция версии 2: Добавление полнотекстового поиска (FTS5)
/// 
/// Дата создания: 2025-11-10
/// 
/// Изменения:
/// - Создание виртуальной FTS5 таблицы products_fts
/// - Добавление триггеров для автоматической синхронизации индекса
/// - Заполнение индекса существующими продуктами
/// 
/// Поля FTS индекса:
/// - product_code (UNINDEXED) - связь с products.code
/// - title - название продукта
/// - code - код как текст для поиска
/// - vendor_code - артикул
/// - barcodes - штрих-коды (через пробел)
/// - brand_name - название бренда
class MigrationV2Fts5 {
  static final Logger _logger = Logger('MigrationV2Fts5');

  /// Создаёт FTS5 виртуальную таблицу для полнотекстового поиска продуктов
  static Future<void> createFtsTable(DatabaseConnectionUser db) async {
    _logger.info('Создание FTS5 таблицы для поиска продуктов');
    
    await db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS products_fts USING fts5(
        product_code UNINDEXED,
        title,
        code,
        vendor_code,
        barcodes,
        brand_name,
        tokenize='porter unicode61'
      );
    ''');
    
    _logger.info('FTS5 таблица products_fts создана');
  }

  /// Создаёт триггеры для автоматической синхронизации FTS индекса
  static Future<void> createFtsTriggers(DatabaseConnectionUser db) async {
    _logger.info('Создание триггеров для синхронизации FTS');
    
    // Триггер INSERT - добавление нового продукта
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_insert AFTER INSERT ON products
      BEGIN
        INSERT INTO products_fts(product_code, title, code, vendor_code, barcodes, brand_name)
        VALUES (
          new.code,
          new.title,
          CAST(new.code AS TEXT),
          COALESCE(json_extract(new.raw_json, '\$.vendorCode'), ''),
          COALESCE(
            (SELECT group_concat(value, ' ') 
             FROM json_each(json_extract(new.raw_json, '\$.barcodes'))),
            ''
          ),
          COALESCE(json_extract(new.raw_json, '\$.brand.name'), '')
        );
      END;
    ''');

    // Триггер UPDATE - обновление продукта
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_update AFTER UPDATE ON products
      BEGIN
        DELETE FROM products_fts WHERE product_code = old.code;
        INSERT INTO products_fts(product_code, title, code, vendor_code, barcodes, brand_name)
        VALUES (
          new.code,
          new.title,
          CAST(new.code AS TEXT),
          COALESCE(json_extract(new.raw_json, '\$.vendorCode'), ''),
          COALESCE(
            (SELECT group_concat(value, ' ') 
             FROM json_each(json_extract(new.raw_json, '\$.barcodes'))),
            ''
          ),
          COALESCE(json_extract(new.raw_json, '\$.brand.name'), '')
        );
      END;
    ''');

    // Триггер DELETE - удаление продукта
    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_delete AFTER DELETE ON products
      BEGIN
        DELETE FROM products_fts WHERE product_code = old.code;
      END;
    ''');
    
    _logger.info('Триггеры для FTS созданы');
  }

  /// Заполняет FTS индекс из существующих продуктов
  static Future<void> rebuildFtsIndex(DatabaseConnectionUser db) async {
    _logger.info('Перестроение FTS индекса из существующих продуктов');
    
    // Очищаем старый индекс
    await db.customStatement('DELETE FROM products_fts');
    
    // Заполняем из таблицы products
    await db.customStatement('''
      INSERT INTO products_fts(product_code, title, code, vendor_code, barcodes, brand_name)
      SELECT 
        p.code,
        p.title,
        CAST(p.code AS TEXT),
        COALESCE(json_extract(p.raw_json, '\$.vendorCode'), ''),
        COALESCE(
          (SELECT group_concat(value, ' ') 
           FROM json_each(json_extract(p.raw_json, '\$.barcodes'))),
          ''
        ),
        COALESCE(json_extract(p.raw_json, '\$.brand.name'), '')
      FROM products p;
    ''');
    
    // Проверяем количество проиндексированных записей
    final result = await db.customSelect(
      'SELECT count(*) as cnt FROM products_fts'
    ).getSingle();
    
    final count = result.data['cnt'];
    _logger.info('FTS индекс заполнен: $count записей');
  }

  /// Выполняет полную миграцию v1 -> v2
  static Future<void> migrate(DatabaseConnectionUser db) async {
    _logger.info('Начало миграции v1 -> v2 (FTS5)');
    
    await createFtsTable(db);
    await createFtsTriggers(db);
    await rebuildFtsIndex(db);
    
    _logger.info('Миграция v1 -> v2 завершена успешно');
  }

  /// Откат миграции (для тестирования/отладки)
  static Future<void> rollback(DatabaseConnectionUser db) async {
    _logger.warning('Откат миграции v2 -> v1 (удаление FTS5)');
    
    // Удаляем триггеры
    await db.customStatement('DROP TRIGGER IF EXISTS products_fts_insert');
    await db.customStatement('DROP TRIGGER IF EXISTS products_fts_update');
    await db.customStatement('DROP TRIGGER IF EXISTS products_fts_delete');
    
    // Удаляем FTS таблицу
    await db.customStatement('DROP TABLE IF EXISTS products_fts');
    
    _logger.info('Откат миграции v2 завершён');
  }
}
