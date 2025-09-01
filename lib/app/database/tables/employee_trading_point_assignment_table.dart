import 'package:drift/drift.dart';
import 'employee_table.dart';

@DataClassName('EmployeeTradingPointAssignment')
class EmployeeTradingPointAssignments extends Table {
  IntColumn get employeeId => integer().references(Employees, #id)();
  TextColumn get tradingPointExternalId => text()();
  DateTimeColumn get assignedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {employeeId, tradingPointExternalId};
}
