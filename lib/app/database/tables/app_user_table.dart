import 'package:drift/drift.dart';
import 'employee_table.dart';
import 'user_table.dart';

@DataClassName('AppUserData')
class AppUsers extends Table {
  IntColumn get employeeId => integer().references(Employees, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get selectedTradingPointId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {employeeId};
}
