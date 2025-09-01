import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/app/domain/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';

/// Хранит части имени
class NameParts {
  final String firstName;
  final String lastName;
  final String? middleName;

  NameParts(this.firstName, this.lastName, this.middleName);
}

/// Фикстуры для создания связанных Employee и AppUser
/// Координирует создание полной связки User -> Employee -> AppUser
class AppUserFixtureService {
  final EmployeeRepository _employeeRepository;
  final AppUserRepository _appUserRepository;

  AppUserFixtureService({
    required EmployeeRepository employeeRepository,
    required AppUserRepository appUserRepository,
  }) : _employeeRepository = employeeRepository,
       _appUserRepository = appUserRepository;

  /// Создает Employee и AppUser для существующего User
  /// Возвращает готовый AppUser для использования в приложении
  Future<AppUser> createAppUserForAuthUser(User authUser) async {
    // print('🔍 Создание AppUser для User ID: ${authUser.id} (${authUser.phoneNumber.value})');
    
    // Проверяем, что у User есть ID
    if (authUser.id == null) {
      throw Exception('User должен быть сохранен в базе (id не может быть null)');
    }

    // 1. Создаем Employee на основе User
    final nameParts = _extractNameFromPhone(authUser.phoneNumber.value);
    final employee = Employee(
      id: null, // ID будет присвоен при сохранении
      firstName: nameParts.firstName,
      lastName: nameParts.lastName,
      middleName: nameParts.middleName,
      role: _getEmployeeRoleFromUserRole(authUser.role),
    );

    // print('🔧 Создаем Employee для User ${authUser.id}: ${employee.firstName} ${employee.lastName}');

    // 2. Сохраняем Employee
    final employeeResult = await _employeeRepository.createEmployee(employee);
    final savedEmployee = employeeResult.fold(
      (failure) => throw Exception('Не удалось создать Employee: $failure'),
      (employee) => employee,
    );

    // print('✅ Employee создан с ID: ${savedEmployee.id}');

    // 3. Создаем связь AppUser (Employee + AuthUser)
    final appUserResult = await _appUserRepository.createAppUser(
      employeeId: savedEmployee.id,
      userId: authUser.id!,
    );

    final appUser = appUserResult.fold(
      (failure) => throw Exception('Не удалось создать AppUser: $failure'),
      (appUser) => appUser,
    );

    // print('✅ AppUser создан: Employee ID ${appUser.employee.id}, User ID ${appUser.authUser.id}');

    return appUser;
  }

  /// Создает AppUser для всех переданных User'ов
  Future<List<AppUser>> createAppUsersForAuthUsers(List<User> authUsers) async {
    final appUsers = <AppUser>[];
    
    for (final authUser in authUsers) {
      try {
        final appUser = await createAppUserForAuthUser(authUser);
        appUsers.add(appUser);
      } catch (e) {
        print('❌ Ошибка создания AppUser для ${authUser.phoneNumber.value}: $e');
        rethrow;
      }
    }
    
    return appUsers;
  }

  NameParts _extractNameFromPhone(String phone) {
    if (phone.contains('111-2233')) return NameParts('Алексей', 'Торговый', null);
    if (phone.contains('444-5566')) return NameParts('Мария', 'Продажкина', null);
    if (phone.contains('000-0001')) return NameParts('Админ', 'Главный', null);
    if (phone.contains('000-0002')) return NameParts('Менеджер', 'Управляющий', null);
    
    final lastFour = phone.substring(phone.length - 4);
    return NameParts('Пользователь', lastFour, null);
  }

  /// Определяет роль Employee на основе роли User
  EmployeeRole _getEmployeeRoleFromUserRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.manager:
        return EmployeeRole.manager;
      case UserRole.user:
        return EmployeeRole.sales;
    }
  }

  /// Очищает всех AppUsers (для dev режима)
  Future<void> clearAllAppUsers() async {
    print('🧹 Очистка AppUsers для dev режима...');
    // При очистке Employee связи AppUser тоже удалятся
  }
}

/// Factory для AppUserFixtureService
class AppUserFixtureServiceFactory {
  static AppUserFixtureService create() {
    return AppUserFixtureService(
      employeeRepository: GetIt.instance<EmployeeRepository>(),
      appUserRepository: GetIt.instance<AppUserRepository>(),
    );
  }
}
