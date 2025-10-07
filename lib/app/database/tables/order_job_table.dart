import 'package:drift/drift.dart';

import 'order_table.dart';

@DataClassName('OrderJobEntity')
class OrderJobs extends Table {
  TextColumn get id => text()();

  IntColumn get orderId => integer().references(Orders, #id, onDelete: KeyAction.cascade)();

  TextColumn get jobType => text().withLength(min: 1, max: 64)();

  TextColumn get payloadJson => text()();

  TextColumn get status => text().withLength(min: 1, max: 32)();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  DateTimeColumn get nextRunAt => dateTime().nullable()();

  TextColumn get failureReason => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
