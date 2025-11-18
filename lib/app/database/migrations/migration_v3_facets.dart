// lib/app/database/migrations/migration_v3_facets.dart

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

/// Миграция версии 3: вспомогательные таблицы для офлайн-фасетов
///
/// Изменения:
/// - создаются таблицы product_facets и product_category_facets
/// - заполняются данными на основе существующих записей products
class MigrationV3Facets {
  static final Logger _logger = Logger('MigrationV3Facets');

  /// Перестраивает содержимое facet-таблиц из products.raw_json
  static Future<void> rebuildFacets(DatabaseConnectionUser db) async {
    _logger.info('Начинаем перестроение facet-таблиц из products');

    await db.customStatement('DELETE FROM product_facets');
    await db.customStatement('DELETE FROM product_category_facets');

    final products = await db
        .customSelect('SELECT code, raw_json FROM products')
        .get();

    for (final row in products) {
      final productCode = row.read<int>('code');
      final rawJson = row.read<String>('raw_json');

      Map<String, dynamic> json;
      try {
        json = jsonDecode(rawJson) as Map<String, dynamic>;
      } catch (e) {
        _logger.warning('Не удалось распарсить raw_json для продукта $productCode: $e');
        continue;
      }

      final brand = json['brand'] as Map<String, dynamic>?;
      final manufacturer = json['manufacturer'] as Map<String, dynamic>?;
      final series = json['series'] as Map<String, dynamic>?;
      final type = json['type'] as Map<String, dynamic>?;

      await db.customStatement(
        '''
        INSERT OR REPLACE INTO product_facets (
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
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        '''.trim(),
        [
          productCode,
          _safeInt(brand?['id']),
          brand?['name'],
          _safeInt(brand?['search_priority']) ?? 0,
          _safeInt(manufacturer?['id']),
          manufacturer?['name'],
          _safeInt(series?['id']),
          series?['name'],
          _safeInt(type?['id']),
          type?['name'],
          _boolToInt(json['novelty']),
          _boolToInt(json['popular']),
          _boolToInt(json['canBuy'], fallback: true),
        ],
      );

      final categories = json['categoriesInstock'] as List<dynamic>?;
      if (categories != null && categories.isNotEmpty) {
        for (final category in categories) {
          if (category is! Map<String, dynamic>) continue;
          final categoryId = _safeInt(category['id']);
          if (categoryId == null) continue;
          await db.customStatement(
            '''
            INSERT INTO product_category_facets (
              product_code,
              category_id,
              category_name,
              created_at
            ) VALUES (?, ?, ?, CURRENT_TIMESTAMP);
            '''.trim(),
            [
              productCode,
              categoryId,
              category['name'],
            ],
          );
        }
      }
    }

    _logger.info('Facet-таблицы перестроены. Обработано ${products.length} продуктов');
  }

  static int _boolToInt(dynamic value, {bool fallback = false}) {
    if (value is bool) return value ? 1 : 0;
    if (value is num) return value != 0 ? 1 : 0;
    return fallback ? 1 : 0;
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
