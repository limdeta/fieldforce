import 'package:drift/drift.dart';
import 'product_table.dart';

/// Таблица для остатков и цен товаров на складах
/// Денормализованная для высокой производительности обновлений
@DataClassName('StockItemData')
class StockItems extends Table {
  /// Уникальный ID StockItem
  IntColumn get id => integer().autoIncrement()();
  
  /// Ссылка на продукт
  IntColumn get productCode => integer().references(Products, #code)();
  
  /// Данные склада (денормализованы для производительности)
  IntColumn get warehouseId => integer()();
  TextColumn get warehouseName => text()();
  TextColumn get warehouseVendorId => text()();
  BoolColumn get isPickUpPoint => boolean().withDefault(const Constant(false))();
  
  /// Остатки товара
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get multiplicity => integer().nullable()();
  TextColumn get publicStock => text()();
  
  /// Ценообразование (все в копейках)
  IntColumn get defaultPrice => integer()();
  IntColumn get discountValue => integer().withDefault(const Constant(0))();
  IntColumn get availablePrice => integer().nullable()();
  IntColumn get offerPrice => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  
  /// Промоакция (JSON для гибкости)
  TextColumn get promotionJson => text().nullable()();
  
  /// Метки времени
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();


  
  @override
  List<Set<Column>> get uniqueKeys => [
    // Уникальная комбинация продукт-склад для предотвращения дублей
    {productCode, warehouseId},
  ];
}