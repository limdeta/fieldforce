// lib/app/database/tables/product_characteristic_facet_table.dart

import 'package:drift/drift.dart';
import 'product_table.dart';

/// Таблица для хранения характеристик продуктов в денормализованном виде
/// для быстрой агрегации фасетов.
/// 
/// Заполняется при синхронизации из Product.boolCharacteristics, 
/// stringCharacteristics, numericCharacteristics.
@DataClassName('ProductCharacteristicFacetData')
class ProductCharacteristicFacets extends Table {
  /// Код продукта (FK)
  IntColumn get productCode => integer()
      .references(Products, #code, onDelete: KeyAction.cascade)();
  
  /// ID атрибута (например, ID для "Водостойкая")
  IntColumn get attributeId => integer()();
  
  /// Название атрибута (для отображения в UI)
  TextColumn get attributeName => text()();
  
  /// Тип характеристики: 'bool', 'string', 'numeric'
  TextColumn get charType => text()();
  
  /// Значение для bool характеристик (0 = false, 1 = true, NULL для других типов)
  IntColumn get boolValue => integer().nullable()();
  
  /// Значение для string характеристик (ID из справочника, NULL для других типов)
  IntColumn get stringValue => integer().nullable()();
  
  /// Значение для numeric характеристик (число, NULL для других типов)
  RealColumn get numericValue => real().nullable()();
  
  /// Человекочитаемое значение (например, "Да", "Красный", "500 мл")
  TextColumn get adaptValue => text().nullable()();
  
  /// Временные метки
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {productCode, attributeId};
}
