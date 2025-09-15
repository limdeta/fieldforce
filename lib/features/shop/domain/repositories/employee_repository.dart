import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, Employee>> create(Employee employee);
  Future<Either<Failure, List<Employee>>> getAll();
  Future<Either<NotFoundFailure, Employee>> getById(int id);
  Future<Either<Failure, void>> delete(int id);
  Future<Either<Failure, int?>> getInternalIdForNavigationUser(Employee navigationUser);
  Future<Either<Failure, Employee?>> getNavigationUserById(int id);
}
