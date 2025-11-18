// lib/app/database/tables/product_facet_table.dart

import 'package:drift/drift.dart';

import 'product_table.dart';

@DataClassName('ProductFacetData')
class ProductFacets extends Table {
    IntColumn get productCode => integer()
      .references(Products, #code, onDelete: KeyAction.cascade)();
  IntColumn get brandId => integer().nullable()();
  TextColumn get brandName => text().nullable()();
  IntColumn get brandSearchPriority => integer().withDefault(const Constant(0))();
  IntColumn get manufacturerId => integer().nullable()();
  TextColumn get manufacturerName => text().nullable()();
  IntColumn get seriesId => integer().nullable()();
  TextColumn get seriesName => text().nullable()();
  IntColumn get typeId => integer().nullable()();
  TextColumn get typeName => text().nullable()();
  IntColumn get priceListCategoryId => integer().nullable()();
  BoolColumn get novelty => boolean().withDefault(const Constant(false))();
  BoolColumn get popular => boolean().withDefault(const Constant(false))();
  BoolColumn get canBuy => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {productCode};

}

@DataClassName('ProductCategoryFacetData')
class ProductCategoryFacets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productCode => integer()
      .references(Products, #code, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer()();
  TextColumn get categoryName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {productCode, categoryId},
  ];
}
