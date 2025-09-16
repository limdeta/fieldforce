// lib/app/database/tables/product_table.dart

import 'package:drift/drift.dart';

/// Таблица для хранения продуктов
/// Храним как JSON blob для простоты работы со сложной структурой
@DataClassName('ProductData')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catalogId => integer().unique()(); // ID из бекенда
  IntColumn get code => integer()();
  IntColumn get bcode => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get vendorCode => text().nullable()();
  IntColumn get amountInPackage => integer().nullable()();
  BoolColumn get novelty => boolean()();
  BoolColumn get popular => boolean()();
  BoolColumn get isMarked => boolean()();
  BoolColumn get canBuy => boolean()();
  IntColumn get categoryId => integer().nullable()(); // ID основной категории
  IntColumn get typeId => integer().nullable()(); // ID типа продукта
  TextColumn get rawJson => text()(); // Полный JSON продукта для быстрого доступа

  // Индексы для быстрого поиска
  @override
  List<String> get customConstraints => [
    'UNIQUE(catalog_id)',
  ];

  // Индексы создаются автоматически для внешних ключей
  // categoryId и typeId будут проиндексированы автоматически

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}