import 'package:fieldforce/features/authentication/domain/services/user_service.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_employee_usecase.dart';
import 'package:fieldforce/app/domain/usecases/create_app_user_usecase.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:flutter/foundation.dart';

class DevUserData {
  final String name;
  final String email;
  final String password;
  final String phone;
  final UserRole role;

  const DevUserData({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });
}

class UserFixture {
  final UserService userService;
  final CreateEmployeeUseCase createEmployeeUseCase;
  final CreateAppUserUseCase createAppUserUseCase;

  UserFixture({
    required this.userService,
    required this.createEmployeeUseCase,
    required this.createAppUserUseCase,
  });

  final admin = const DevUserData(
    name: 'Админ Админов',
    email: 'admin@fieldforce.dev',
    password: '123456',
    phone: '+7-000-000-0000',
    role: UserRole.admin,
  );

  final saddam = const DevUserData(
    name: 'Саддам Хусейн',
    email: 'salesrep@fieldforce.dev',
    password: 'password123',
    phone: '+7-999-111-2233',
    role: UserRole.admin,
  );

  Future<AppUser> getBasicUser({
    required DevUserData userData,
  }) async {
    try {
      final authUser = await userService.createUser(
        externalId: userData.email,
        role: userData.role,
        phone: userData.phone,
        rawPassword: userData.password,
      );

      final employeeResult = await createEmployeeUseCase.call(
        lastName: userData.name
            .split(' ')
            .first,
        firstName: userData.name
            .split(' ')
            .last,
        middleName: null,
        role: EmployeeRole.sales,
      );
      final createdEmployee = employeeResult.fold(
            (failure) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: failure,
            stack: StackTrace.current,
            library: 'UserFixture',
            context: ErrorDescription('Ошибка создания сотрудника'),
          ));
          throw Exception('Ошибка создания сотрудника: ${failure.message}');
        },
            (emp) => emp,
      );

      final appUserResult = await createAppUserUseCase.call(
        employee: createdEmployee,
        user: authUser,
      );

      final appUser = appUserResult.fold(
            (failure) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: failure,
            stack: StackTrace.current,
            library: 'UserFixture',
            context: ErrorDescription('Ошибка создания AppUser'),
          ));
          throw Exception('Ошибка создания AppUser: ${failure.message}');
        },
            (au) => au,
      );

      return appUser;
    } catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'UserFixture',
        context: ErrorDescription('Ошибка при создании сценария пользователя'),
      ));
      rethrow;
    }
  }
}


