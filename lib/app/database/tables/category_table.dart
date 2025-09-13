import 'package:drift/drift.dart';

/// Таблица для хранения дерева категорий
/// Храним как JSON blob для простоты работы с nested set
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer().unique()(); // ID из бекенда
  IntColumn get lft => integer()();
  IntColumn get lvl => integer()();
  IntColumn get rgt => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get query => text().nullable()();
  IntColumn get count => integer()();
  IntColumn get parentId => integer().nullable()(); // Для нормализации дерева
  TextColumn get rawJson => text()(); // Полный JSON категории для быстрого доступа
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}