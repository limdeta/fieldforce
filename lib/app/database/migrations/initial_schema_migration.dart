import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/migrations/stock_item_indexes.dart';
import 'package:logging/logging.dart';

/// Consolidated migration that represents the full baseline schema for the
/// catalog stack (FTS, facet helpers, indexes). Use this instead of chaining
/// multiple incremental migrations.
class InitialSchemaMigration {
  static final Logger _logger = Logger('InitialSchemaMigration');

  /// Runs after [Migrator.createAll] on a clean database.
  static Future<void> setup(AppDatabase db) async {
    _logger.info('Setting up baseline catalog helpers (FTS, indexes)');
    await _rebuildCatalogArtifacts(db, logMissing: false);
  }

  /// Upgrades an existing database to the consolidated baseline.
  ///
  /// Steps:
  /// Legacy name kept for compatibility: now simply refreshes helpers without
  /// wiping business data.
  static Future<void> resetCatalogAndSetup(AppDatabase db) async {
    _logger.info('Refreshing catalog helpers without purging tables');
    await _rebuildCatalogArtifacts(db, logMissing: true);
  }

  static Future<void> _rebuildCatalogArtifacts(AppDatabase db, {required bool logMissing}) async {
    await _dropFtsArtifacts(db, logMissing: logMissing);
    await _createFtsTable(db);
    await _createFtsTriggers(db);
    await _ensureFacetIndexes(db);
    await _ensureStockIndexes(db);
    await _ensureProductIndexes(db);
  }

  static Future<void> _createFtsTable(DatabaseConnectionUser db) async {
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
  }

  static Future<void> _createFtsTriggers(DatabaseConnectionUser db) async {
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

    await db.customStatement('''
      CREATE TRIGGER IF NOT EXISTS products_fts_delete AFTER DELETE ON products
      BEGIN
        DELETE FROM products_fts WHERE product_code = old.code;
      END;
    ''');
  }

  static Future<void> _ensureFacetIndexes(DatabaseConnectionUser db) async {
    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_product_facets_brand ON product_facets(brand_id, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_facets_manufacturer ON product_facets(manufacturer_id, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_facets_series ON product_facets(series_id, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_facets_type ON product_facets(type_id, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_facets_novelty ON product_facets(novelty, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_facets_popular ON product_facets(popular, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_facets_can_buy ON product_facets(can_buy, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_category_facets_category ON product_category_facets(category_id, product_code)',
      'CREATE INDEX IF NOT EXISTS idx_product_category_facets_code ON product_category_facets(product_code)',
    ];

    for (final statement in statements) {
      await db.customStatement(statement);
    }
  }

  static Future<void> _ensureStockIndexes(DatabaseConnectionUser db) async {
    for (final statement in StockItemIndexes.createIndexes) {
      await db.customStatement(statement);
    }
  }

  static Future<void> _ensureProductIndexes(DatabaseConnectionUser db) async {
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_title_nocase ON products(title COLLATE NOCASE, code)',
    );
  }

  static Future<void> _dropFtsArtifacts(AppDatabase db, {required bool logMissing}) async {
    if (logMissing) {
      _logger.info('Dropping existing FTS helpers before rebuild');
    }

    await db.customStatement('DROP TRIGGER IF EXISTS products_fts_insert');
    await db.customStatement('DROP TRIGGER IF EXISTS products_fts_update');
    await db.customStatement('DROP TRIGGER IF EXISTS products_fts_delete');
    await db.customStatement('DROP TABLE IF EXISTS products_fts');
  }
}
