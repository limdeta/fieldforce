import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

abstract interface class AppUserRepository {
  Future<Either<Failure, AppUser>> getAppUserByEmployeeId(int employeeId);
  Future<Either<Failure, AppUser>> getAppUserByUserId(int userId);
  Future<Either<Failure, AppUser?>> getAppUserByExternalId(String externalId);
  Future<Either<Failure, AppUser>> createAppUser(Employee employee, User user);
  Future<Either<Failure, bool>> appUserExists(int employeeId);
  Future<Either<Failure, void>> deleteAppUser(int employeeId);
}
