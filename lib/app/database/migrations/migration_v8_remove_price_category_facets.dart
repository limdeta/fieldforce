import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

/// Migration v8: drop price-list category facets and rebuild the helper table without them.
class MigrationV8RemovePriceCategoryFacets {
  static final Logger _logger = Logger('MigrationV8RemovePriceCategoryFacets');

  static Future<void> apply(DatabaseConnectionUser db) async {
    _logger.info('Applying migration v8: removing price category facets');

    await db.customStatement('DROP INDEX IF EXISTS idx_product_facets_price_category');

    await db.transaction(() async {
      await db.customStatement('ALTER TABLE product_facets RENAME TO product_facets_old');

      await db.customStatement('''
        CREATE TABLE product_facets (
          product_code INTEGER NOT NULL PRIMARY KEY REFERENCES products (code) ON DELETE CASCADE,
          brand_id INTEGER,
          brand_name TEXT,
          brand_search_priority INTEGER NOT NULL DEFAULT 0,
          manufacturer_id INTEGER,
          manufacturer_name TEXT,
          series_id INTEGER,
          series_name TEXT,
          type_id INTEGER,
          type_name TEXT,
          novelty INTEGER NOT NULL DEFAULT 0,
          popular INTEGER NOT NULL DEFAULT 0,
          can_buy INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      await db.customStatement('''
        INSERT INTO product_facets (
          product_code,
          brand_id,
          brand_name,
          brand_search_priority,
          manufacturer_id,
          manufacturer_name,
          series_id,
          series_name,
          type_id,
          type_name,
          novelty,
          popular,
          can_buy,
          created_at,
          updated_at
        )
        SELECT
          product_code,
          brand_id,
          brand_name,
          brand_search_priority,
          manufacturer_id,
          manufacturer_name,
          series_id,
          series_name,
          type_id,
          type_name,
          novelty,
          popular,
          can_buy,
          created_at,
          updated_at
        FROM product_facets_old;
      ''');

      await db.customStatement('DROP TABLE product_facets_old');
    });
  }
}
