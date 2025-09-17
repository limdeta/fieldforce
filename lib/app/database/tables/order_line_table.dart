import 'package:drift/drift.dart';
import 'order_table.dart';

@DataClassName('OrderLineEntity')
class OrderLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Ссылка на заказ
  IntColumn get orderId => integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  
  // Ссылка на остаток товара на складе (StockItem)
  IntColumn get stockItemId => integer()();
  
  // Количество товара
  IntColumn get quantity => integer()();
  
  // Цена за единицу в копейках
  IntColumn get pricePerUnit => integer()();
  
  // Метки времени
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}