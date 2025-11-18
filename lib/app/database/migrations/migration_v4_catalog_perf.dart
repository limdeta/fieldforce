// lib/app/database/migrations/migration_v4_catalog_perf.dart

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/migrations/stock_item_indexes.dart';
import 'package:logging/logging.dart';

/// Migration that focuses on catalog query performance by ensuring
/// appropriate indexes exist for facet helper tables and stock filters.
class MigrationV4CatalogPerf {
  static final Logger _logger = Logger('MigrationV4CatalogPerf');

  static Future<void> apply(DatabaseConnectionUser db) async {
    _logger.info('Applying catalog performance migration (v4)');

    for (final statement in _facetIndexStatements) {
      await db.customStatement(statement);
    }

    for (final statement in StockItemIndexes.createIndexes) {
      await db.customStatement(statement);
    }
  }

  static const List<String> _facetIndexStatements = <String>[
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
}
