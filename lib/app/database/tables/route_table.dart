import 'package:drift/drift.dart';
import 'employee_table.dart';

@DataClassName('RouteData')
class Routes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get status => text()(); // RouteStatus enum as string
  IntColumn get employeeId => integer().nullable().references(Employees, #id)();
}
