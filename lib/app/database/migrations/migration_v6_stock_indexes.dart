import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/migrations/stock_item_indexes.dart';
import 'package:logging/logging.dart';

/// Migration v6: refresh stock indexes to speed up warehouse-scoped queries.
class MigrationV6StockIndexes {
  static final Logger _logger = Logger('MigrationV6StockIndexes');

  static Future<void> apply(DatabaseConnectionUser db) async {
    _logger.info('Applying stock index migration (v6)');
    for (final statement in StockItemIndexes.createIndexes) {
      await db.customStatement(statement);
    }
  }
}
