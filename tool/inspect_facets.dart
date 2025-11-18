import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  final path = args.isNotEmpty ? args.first : 'test_db/fieldforce_test.db';
  final db = sqlite3.open(path);
  try {
    final productCount = db.select('SELECT COUNT(*) AS cnt FROM products').first['cnt'];
    final facetCount = db.select('SELECT COUNT(*) AS cnt FROM product_facets').first['cnt'];
    final categoryFacetCount =
        db.select('SELECT COUNT(*) AS cnt FROM product_category_facets').first['cnt'];
    print('products=$productCount facets=$facetCount category_facets=$categoryFacetCount');
    final sampleCategories = db
        .select('SELECT DISTINCT category_id FROM product_category_facets LIMIT 5')
        .map((row) => row['category_id'])
        .toList();
    print('sample category ids: $sampleCategories');
  } finally {
    db.dispose();
  }
}
