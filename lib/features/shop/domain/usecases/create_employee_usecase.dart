import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class CreateEmployeeUseCase {
  final EmployeeRepository _repository;

  CreateEmployeeUseCase(this._repository);

  Future<Either<Failure, Employee>> call({
    required String lastName,
    required String firstName,
    String? middleName,
    required EmployeeRole role,
  }) async {

    if (lastName.isEmpty || firstName.isEmpty) {
      return Left(ValidationFailure('Фамилия и имя обязательны'));
    }

    final allEmployeesResult = await _repository.getAllEmployees();
    final allEmployees = allEmployeesResult.fold((l) => [], (r) => r);
    final exists = allEmployees.any((e) =>
      e.lastName == lastName &&
      e.firstName == firstName &&
      e.middleName == middleName
    );
    if (exists) {
      return Left(EntityCreationFailure('Сотрудник с такими ФИО уже существует'));
    }

    final employee = Employee(
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      role: role,
    );

    return await _repository.createEmployee(employee);
  }
}
