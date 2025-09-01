import 'package:drift/drift.dart';

@DataClassName('EmployeeData')
class Employees extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lastName => text()();
  TextColumn get firstName => text()();
  TextColumn get middleName => text().nullable()();
  TextColumn get role => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
