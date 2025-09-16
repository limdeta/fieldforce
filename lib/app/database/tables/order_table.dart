import 'package:drift/drift.dart';
import 'employee_table.dart';
import 'trading_point_entity_table.dart';

@DataClassName('OrderEntity')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Ссылка на создателя заказа (сотрудника)
  IntColumn get creatorId => integer().references(Employees, #id)();
  
  // Ссылка на торговую точку
  IntColumn get outletId => integer().references(TradingPointEntities, #id)();
  
  // Состояние заказа: draft, pending, completed, failed
  TextColumn get state => text().withLength(min: 1, max: 20)();
  
  // Способ оплаты
  TextColumn get paymentType => text().nullable()();
  TextColumn get paymentDetails => text().nullable()();
  BoolColumn get paymentIsCash => boolean().withDefault(const Constant(false))();
  BoolColumn get paymentIsCard => boolean().withDefault(const Constant(false))();
  BoolColumn get paymentIsCredit => boolean().withDefault(const Constant(false))();
  
  // Дополнительные поля
  TextColumn get comment => text().nullable()();
  TextColumn get name => text().withLength(max: 20).nullable()();
  BoolColumn get isPickup => boolean().withDefault(const Constant(true))();
  DateTimeColumn get approvedDeliveryDay => dateTime().nullable()();
  DateTimeColumn get approvedAssemblyDay => dateTime().nullable()();
  BoolColumn get withRealization => boolean().withDefault(const Constant(true))();
  
  // Метки времени
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}