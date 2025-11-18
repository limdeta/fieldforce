import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

/// Migration v5: refresh facet helper tables to guarantee data is in sync with
/// products after switching catalog queries entirely to SQL joins.
class MigrationV5CatalogFacets {
  static final Logger _logger = Logger('MigrationV5CatalogFacets');

  static Future<void> rebuild(DatabaseConnectionUser db) async {
    _logger.info('Clearing catalog tables as part of migration v5 to force a fresh sync');

    await db.transaction(() async {
      await db.customStatement('DELETE FROM product_category_facets;');
      await db.customStatement('DELETE FROM product_facets;');
      await db.customStatement('DELETE FROM stock_items;');
      await db.customStatement('DELETE FROM products;');
    });

    _logger.info('Catalog tables cleared. The next sync will repopulate products, stock, and facets.');
  }
}
