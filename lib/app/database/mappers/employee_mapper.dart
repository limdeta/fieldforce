import 'package:fieldforce/features/shop/domain/entities/employee.dart' as domain;
import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart' as db;

class EmployeeMapper {
  static domain.Employee fromDb(db.EmployeeData dbEmployee) {
    return domain.Employee(
      id: dbEmployee.id,
      lastName: dbEmployee.lastName,
      firstName: dbEmployee.firstName,
      middleName: dbEmployee.middleName,
      role: _stringToEmployeeRole(dbEmployee.role),
    );
  }

  static db.EmployeesCompanion toDb(domain.Employee employee) {
    return db.EmployeesCompanion.insert(
      lastName: employee.lastName ?? '',
      firstName: employee.firstName ?? '',
      middleName: employee.middleName != null 
        ? Value(employee.middleName!)
        : const Value.absent(),
      role: _employeeRoleToString(employee.role),
    );
  }

  static domain.EmployeeRole _stringToEmployeeRole(String role) {
    return domain.EmployeeRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => domain.EmployeeRole.sales,
    );
  }

  static String _employeeRoleToString(domain.EmployeeRole role) {
    return role.name;
  }
}
