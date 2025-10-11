// lib/app/database/tables/product_table.dart

import 'package:drift/drift.dart';

/// Таблица для хранения продуктов
@DataClassName('ProductData')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catalogId => integer()(); // ID из бекенда (убрали unique - может быть 0 у многих продуктов)
  IntColumn get code => integer().unique()(); // Код продукта - основной идентификатор
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
  IntColumn get priceListCategoryId => integer().nullable()(); // ID категории прайс-листа
  TextColumn get defaultImageJson => text().nullable()(); // JSON объект defaultImage как в API
  TextColumn get imagesJson => text().nullable()(); // JSON массив images как в API
  TextColumn get barcodesJson => text().nullable()(); // JSON массив штрихкодов
  TextColumn get howToUse => text().nullable()(); // Как использовать
  TextColumn get ingredients => text().nullable()(); // Состав
  TextColumn get rawJson => text()(); // Полный JSON продукта с категориями, брендами и характеристиками

  // Индексы для быстрого поиска
  @override
  List<String> get customConstraints => [
    // catalog_id может быть 0 для многих продуктов (нет каталожного ID)
    // поэтому убираем UNIQUE constraint 
    'UNIQUE(code)', // code остается уникальным
  ];

  // Индексы создаются автоматически для внешних ключей
  // categoryId и typeId будут проиндексированы автоматически

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}