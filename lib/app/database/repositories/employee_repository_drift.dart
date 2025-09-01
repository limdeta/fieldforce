import '../../../features/shop/domain/entities/employee.dart' as domain;
import '../../../features/shop/domain/repositories/employee_repository.dart';
import '../../../../shared/either.dart';
import '../../../../shared/failures.dart';
import '../app_database.dart' as db;
import '../mappers/employee_mapper.dart';

class EmployeeRepositoryDrift implements EmployeeRepository {
  final db.AppDatabase _database;

  EmployeeRepositoryDrift(this._database);

  // Дополнительные методы для CRUD операций
  @override
  Future<Either<Failure, domain.Employee>> createEmployee(domain.Employee employee) async {
    try {
      final companion = EmployeeMapper.toDb(employee);
      final id = await _database.into(_database.employees).insert(companion);
      
      final createdEmployee = domain.Employee(
        id: id,
        lastName: employee.lastName,
        firstName: employee.firstName,
        middleName: employee.middleName,
        role: employee.role,
      );
      return Right(createdEmployee);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create employee: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Employee>>> getAllEmployees() async {
    try {
      final dbEmployees = await _database.select(_database.employees).get();
      final employees = dbEmployees.map(EmployeeMapper.fromDb).toList().cast<domain.Employee>();
      return Right(employees);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all employees: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Employee?>> getEmployeeById(int id) async {
    try {
      final query = _database.select(_database.employees)
        ..where((employee) => employee.id.equals(id));
      
      final dbEmployee = await query.getSingleOrNull();
      if (dbEmployee == null) return const Right(null);
      
      final employee = EmployeeMapper.fromDb(dbEmployee);
      return Right(employee);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get employee by id: $e'));
    }
  }

  // Простой метод для получения по ID (для AppUserRepository)
  Future<Either<Failure, domain.Employee>> getById(int id) async {
    try {
      final query = _database.select(_database.employees)
        ..where((employee) => employee.id.equals(id));
      
      final dbEmployee = await query.getSingleOrNull();
      if (dbEmployee == null) {
        return Left(NotFoundFailure('Employee with id $id not found'));
      }
      
      final employee = EmployeeMapper.fromDb(dbEmployee);
      return Right(employee);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get employee by id: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(int id) async {
    try {
      await (_database.delete(_database.employees)
        ..where((employee) => employee.id.equals(id))).go();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete employee: $e'));
    }
  }

  /// Получает внутренний database ID сотрудника для NavigationUser
  @override
  Future<Either<Failure, int?>> getInternalIdForNavigationUser(domain.Employee navigationUser) async {
    try {
      // Поскольку Employee уже реализует NavigationUser и содержит database ID
      // просто возвращаем его id (если он не 0, что означает еще не сохранен)
      final id = navigationUser.id == 0 ? null : navigationUser.id;
      
/*      if (id == null) {
        print('❌ Employee ID равен 0 - объект не сохранен в базе!');
      } else {
        print('✅ Employee ID корректен: $id');
      }*/
      
      return Right(id);
    } catch (e) {
      print('❌ Ошибка в getInternalIdForNavigationUser: $e');
      return Left(DatabaseFailure('Failed to get internal ID: $e'));
    }
  }

  /// Создает NavigationUser на основе database ID
  @override
  Future<Either<Failure, domain.Employee?>> getNavigationUserById(int id) async {
    try {
      final employeeResult = await getEmployeeById(id);
      return employeeResult.fold(
        (failure) => Left(failure),
        (employee) => Right(employee),
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get navigation user by id: $e'));
    }
  }
}
