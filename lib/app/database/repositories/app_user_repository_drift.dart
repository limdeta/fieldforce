import 'package:fieldforce/app/domain/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/mappers/app_user_mapper.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/user_repository_drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class AppUserRepositoryDrift implements AppUserRepository {
  final AppDatabase database;
  final EmployeeRepositoryDrift employeeRepository;
  final UserRepositoryImpl userRepository;

  AppUserRepositoryDrift({
    required this.database,
    required this.employeeRepository,
    required this.userRepository,
  });

  Future<AppUserData?> _getAppUserByEmployeeId(int employeeId) async {
    final query = database.select(database.appUsers)..where((au) => au.employeeId.equals(employeeId));
    return await query.getSingleOrNull();
  }

  Future<AppUserData?> _getAppUserByUserId(int userId) async {
    final query = database.select(database.appUsers)..where((au) => au.userId.equals(userId));
    return await query.getSingleOrNull();
  }

  Future<int> _insertAppUser(AppUsersCompanion appUser) async {
    return await database.into(database.appUsers).insert(appUser);
  }

  Future<int> _deleteAppUser(int employeeId) async {
    return await (database.delete(database.appUsers)..where((au) => au.employeeId.equals(employeeId))).go();
  }

  @override
  Future<Either<Failure, AppUser>> getAppUserByEmployeeId(int employeeId) async {
    try {
      final appUserData = await _getAppUserByEmployeeId(employeeId);
      if (appUserData == null) {
        return Left(NotFoundFailure('AppUser с employeeId $employeeId не найден'));
      }

      final employeeResult = await employeeRepository.getById(employeeId);
      final employee = employeeResult.fold(
        (failure) => throw Exception(failure.toString()),
        (employee) => employee,
      );

      final userResult = await userRepository.getUserByInternalId(appUserData.userId);
      final authUser = userResult.fold(
        (failure) => throw Exception(failure.toString()),
        (user) => user,
      );

      final appUser = AppUserMapper.fromComponents(
        employee: employee,
        authUser: authUser,
      );

      return Right(appUser);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения AppUser: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> getAppUserByUserId(int userId) async {
    try {
      final appUserData = await _getAppUserByUserId(userId);
      if (appUserData == null) {
        return Left(NotFoundFailure('AppUser с userId $userId не найден'));
      }

      final employeeResult = await employeeRepository.getById(appUserData.employeeId);
      final employee = employeeResult.fold(
        (failure) => throw Exception(failure.toString()),
        (employee) => employee,
      );

      final userResult = await userRepository.getUserByInternalId(appUserData.userId);
      final authUser = userResult.fold(
        (failure) => throw Exception(failure.toString()),
        (user) => user,
      );

      final appUser = AppUser(
        employee: employee,
        authUser: authUser,
      );

      return Right(appUser);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения AppUser: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> createAppUser({
    required int employeeId,
    required int userId,
  }) async {
    try {
      await _insertAppUser(AppUserMapper.toDb(
        employeeId: employeeId,
        userId: userId,
      ));

      return await getAppUserByEmployeeId(employeeId);
    } catch (e) {
      return Left(EntityCreationFailure('Не удалось создать AppUser: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppUser(int employeeId) async {
    try {
      await _deleteAppUser(employeeId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка удаления AppUser: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getAppUserByExternalId(String externalId) async {
    try {

      // 1. Находим User по externalId
      final userResult = await userRepository.getUserByExternalId(externalId);
      final authUser = userResult.fold(
        (failure) {
          print('❌ [AppUserRepo] User не найден по externalId $externalId: ${failure.message}');
          return null;
        },
        (user) {
          return user;
        },
      );

      if (authUser?.id == null) {
        print('❌ [AppUserRepo] User не найден или ID null для externalId: $externalId');
        return const Right(null);
      }

      // 2. Находим AppUser по userId
      final appUserResult = await getAppUserByUserId(authUser!.id!);
      return appUserResult.fold(
        (failure) {
          print('❌ [AppUserRepo] AppUser не найден для userId ${authUser.id}: ${failure.message}');
          return const Right(null);
        },
        (appUser) {
          return Right(appUser);
        },
      );
    } catch (e) {
      print('❌ [AppUserRepo] Ошибка при поиске AppUser по externalId $externalId: $e');
      return Left(DatabaseFailure('Ошибка поиска AppUser: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> appUserExists(int employeeId) async {
    try {
      final appUserData = await _getAppUserByEmployeeId(employeeId);
      return Right(appUserData != null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка проверки существования AppUser: $e'));
    }
  }
}
