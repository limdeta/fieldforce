import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

/// Migration v7: add a covering index that matches catalog ORDER BY clause.
class MigrationV7ProductTitleIndex {
  static final Logger _logger = Logger('MigrationV7ProductTitleIndex');

  static const String _indexStatement =
      'CREATE INDEX IF NOT EXISTS idx_products_title_nocase ON products(title COLLATE NOCASE, code)';

  static Future<void> apply(DatabaseConnectionUser db) async {
    _logger.info('Applying products title index migration (v7)');
    await db.customStatement(_indexStatement);
  }
}
