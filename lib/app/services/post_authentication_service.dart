import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Сервис для создания бизнес-сущностей после успешной аутентификации
/// Отвечает за создание Employee и AppUser в app слое
class PostAuthenticationService {
  static final Logger _logger = Logger('PostAuthenticationService');
  final EmployeeRepository employeeRepository;
  final AppUserRepository appUserRepository;
  final TradingPointRepository tradingPointRepository;
  final IAuthApiService authApiService;

  const PostAuthenticationService({
    required this.employeeRepository,
    required this.appUserRepository,
    required this.tradingPointRepository,
    required this.authApiService,
  });

  /// Создает Employee и AppUser для аутентифицированного пользователя
  /// Вызывается после успешной аутентификации в auth модуле
  Future<Either<Failure, void>> createBusinessEntitiesForUser(User authUser) async {
    try {
      // Проверяем, существует ли уже AppUser для этого пользователя
      final existingAppUserResult = await appUserRepository.getAppUserByUserId(authUser.id!);

      return existingAppUserResult.fold(
        (failure) async {
          // AppUser не найден, нужно создать Employee и AppUser
          // Пока создаем Employee напрямую (в будущем можно добавить проверку)
          final employeeResult = await _createEmployeeForUser(authUser);
          return employeeResult.fold(
            (employeeFailure) => Left(employeeFailure),
            (employee) async {
              // Создаем AppUser
              final appUserResult = await appUserRepository.createAppUser(employee, authUser);
              return appUserResult.fold(
                (appUserFailure) => Left(appUserFailure),
                (_) async {
                  // После создания бизнес-сущностей синхронизируем данные с API
                  final syncResult = await syncUserInfo(authUser);
                  return syncResult.fold(
                    (syncFailure) {
                      // Логируем ошибку синхронизации, но не прерываем процесс
                      _logger.warning('Ошибка синхронизации данных пользователя: ${syncFailure.message}');
                      return const Right(null); // Возвращаем успех, так как основные сущности созданы
                    },
                    (_) => const Right(null),
                  );
                },
              );
            },
          );
        },
        (existingAppUser) async {
          // AppUser уже существует - синхронизируем данные с API
          final syncResult = await syncUserInfo(authUser);
          return syncResult.fold(
            (syncFailure) {
              // Логируем ошибку синхронизации, но не прерываем процесс
              _logger.warning('Ошибка синхронизации данных пользователя: ${syncFailure.message}');
              return const Right(null); // Возвращаем успех, так как основные сущности существуют
            },
            (_) => const Right(null),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка создания бизнес-сущностей: $e'));
    }
  }

  /// Создает Employee для пользователя
  Future<Either<Failure, Employee>> _createEmployeeForUser(User authUser) async {
    // TODO: В будущем можно получать дополнительные данные из API
    // Пока создаем с базовой информацией
    final employee = Employee(
      lastName: 'Пользователь', // Заглушка
      firstName: authUser.phoneNumber.value, // Используем номер телефона как имя
      role: EmployeeRole.sales, // По умолчанию торговый представитель
    );

    return await employeeRepository.create(employee);
  }

  /// Синхронизирует данные пользователя с сервером
  /// Получает актуальную информацию и обновляет Employee если необходимо
  Future<Either<Failure, void>> syncUserInfo(User authUser) async {
    try {
      final userInfoResult = await authApiService.getUserInfo();

      return userInfoResult.fold(
        (failure) => Left(failure),
        (userData) async {
          // Проверяем, активен ли аккаунт
          final isActive = userData['isActive'] as bool? ?? true;
          if (!isActive) {
            _logger.warning('Аккаунт пользователя отключен (isActive: false)');
            // Можно добавить дополнительную логику для обработки отключенного аккаунта
            // Например, пометить пользователя как неактивного в локальной БД
          }
          
          // Экспериментальный парсинг outlet из данных пользователя
          await _parseAndSelectOutlet(userData, authUser);
          
          final syncResult = await _syncEmployeeData(authUser, userData);
          return syncResult.fold(
            (syncFailure) => Left(syncFailure),
            (_) => const Right(null),
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка синхронизации данных пользователя: $e'));
    }
  }

  Future<Either<Failure, void>> _syncEmployeeData(User authUser, Map<String, dynamic> userData) async {
    try {
      final appUserResult = await appUserRepository.getAppUserByUserId(authUser.id!);

      return appUserResult.fold(
        (failure) async {
          // AppUser не найден - создаем нового Employee с данными из API
          final employeeResult = await _createEmployeeFromApiData(userData);
          return employeeResult.fold(
            (createFailure) => Left(createFailure),
            (employee) async {
              // Создаем AppUser
              final appUserResult = await appUserRepository.createAppUser(employee, authUser);
              return appUserResult.fold(
                (appUserFailure) => Left(appUserFailure),
                (_) => const Right(null),
              );
            },
          );
        },
        (appUser) async {
          final employee = appUser.employee;
          final updatedEmployee = _updateEmployeeFromApiData(employee, userData);

          final updateResult = await employeeRepository.update(updatedEmployee);
          return updateResult.fold(
            (updateFailure) => Left(updateFailure),
            (savedEmployee) {
              _logger.info('Данные Employee сохранены в БД: ${savedEmployee.fullName}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка синхронизации Employee: $e'));
    }
  }

  Future<Either<Failure, Employee>> _createEmployeeFromApiData(Map<String, dynamic> userData) async {
    try {
      final employee = Employee(
        lastName: userData['lastName'] ?? 'Неизвестно',
        firstName: userData['firstName'] ?? 'Неизвестно',
        middleName: userData['fatherName'], 
        role: _mapApiRolesToEmployeeRole(userData['roles']),
      );

      return await employeeRepository.create(employee);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка создания Employee из API данных: $e'));
    }
  }

  Employee _updateEmployeeFromApiData(Employee employee, Map<String, dynamic> userData) {
    return Employee(
      id: employee.id,
      lastName: userData['lastName'] ?? employee.lastName,
      firstName: userData['firstName'] ?? employee.firstName,
      middleName: userData['fatherName'] ?? employee.middleName, // API возвращает fatherName
      role: _mapApiRolesToEmployeeRole(userData['roles'] ?? [employee.role.name]), // Пока у ролях нет нужды, возможно удалим это
      assignedTradingPoints: employee.assignedTradingPoints,
    );
  }

  EmployeeRole _mapApiRolesToEmployeeRole(dynamic apiRoles) {
    if (apiRoles is List) {
      // Ищем самую высокую роль в массиве
      for (final role in apiRoles) {
        switch (role?.toString().toLowerCase()) {
          case 'role_admin':
            return EmployeeRole.manager;
          case 'role_manager':
            return EmployeeRole.manager;
          case 'role_supervisor':
            return EmployeeRole.supervisor;
          case 'role_user':
            return EmployeeRole.sales;
        }
      }
    } else if (apiRoles is String) {
      // Обработка одиночной роли для обратной совместимости
      return _mapApiRoleToEmployeeRole(apiRoles);
    }

    return EmployeeRole.sales; // По умолчанию
  }

  /// Преобразует роль из API (строка) в EmployeeRole (для обратной совместимости)
  EmployeeRole _mapApiRoleToEmployeeRole(String? apiRole) {
    switch (apiRole?.toLowerCase()) {
      case 'sales':
        return EmployeeRole.sales;
      case 'supervisor':
        return EmployeeRole.supervisor;
      case 'manager':
        return EmployeeRole.manager;
      default:
        return EmployeeRole.sales; // По умолчанию
    }
  }

  /// Экспериментальный метод для парсинга и автоматического выбора outlet
  /// Извлекает outlet из данных пользователя и устанавливает его как текущий
  Future<void> _parseAndSelectOutlet(Map<String, dynamic> userData, User authUser) async {
    try {
      // Экспериментальный парсинг outlet из userData
      final outletData = userData['outlet'];
      if (outletData == null) {
        _logger.info('🏪 Outlet не найден в данных пользователя - пропускаем авто-выбор');
        return;
      }

      _logger.info('🏪 Найден outlet в данных пользователя: $outletData');

      // Пытаемся извлечь ID outlet
      int? outletId;
      String? outletExternalId;

      if (outletData is Map<String, dynamic>) {
        outletId = outletData['id'] as int?;
        outletExternalId = outletData['externalId'] as String?;
      } else if (outletData is int) {
        outletId = outletData;
      } else if (outletData is String) {
        outletExternalId = outletData;
      }

      if (outletId == null && outletExternalId == null) {
        _logger.warning('🏪 Не удалось извлечь ID или externalId outlet из данных: $outletData');
        return;
      }

      // Ищем TradingPoint в базе данных
      final tradingPointResult = outletId != null
          ? await tradingPointRepository.getById(outletId)
          : await tradingPointRepository.getByExternalId(outletExternalId!);

      _logger.info('🏪 Ищем TradingPoint: outletId=$outletId, outletExternalId=$outletExternalId');

      TradingPoint? tradingPoint = tradingPointResult.fold(
        (failure) {
          _logger.warning('🏪 TradingPoint не найден: ${failure.message}');
          return null;
        },
        (point) => point,
      );

      // Если TradingPoint не найден, создаем его из данных API
      if (tradingPoint == null && outletData is Map<String, dynamic>) {
        _logger.info('🏪 TradingPoint не найден, создаем из данных API...');
        try {
          final newTradingPoint = TradingPoint(
            id: outletData['id'],
            externalId: outletData['vendorId']?.toString() ?? outletData['id'].toString(),
            name: outletData['name'],
          );

          final createResult = await tradingPointRepository.save(newTradingPoint);
          tradingPoint = createResult.fold(
            (failure) {
              _logger.warning('🏪 Ошибка создания TradingPoint: ${failure.message}');
              return null;
            },
            (created) {
              _logger.info('🏪 TradingPoint создан: ${created.name} (ID: ${created.id})');
              return created;
            },
          );
        } catch (e) {
          _logger.warning('🏪 Ошибка создания TradingPoint из API данных: $e');
        }
      }

      if (tradingPoint == null) {
        _logger.warning('🏪 TradingPoint не найден и не удалось создать');
        return;
      }

      _logger.info('🏪 Найден TradingPoint: ${tradingPoint.name} (ID: ${tradingPoint.id})');

      // Получаем текущего пользователя по userId
      final currentUserResult = await appUserRepository.getAppUserByUserId(authUser.id!);
      _logger.info('🏪 Получаем AppUser для userId=${authUser.id}');
      
      final currentUser = currentUserResult.fold(
        (failure) {
          _logger.warning('🏪 AppUser не найден: ${failure.message}');
          return null;
        },
        (user) => user,
      );

      if (currentUser == null) {
        _logger.warning('🏪 Текущий AppUser не найден - не можем установить outlet');
        return;
      }

      // Обновляем AppUser с выбранным trading point
      final updatedUser = currentUser.selectTradingPoint(tradingPoint);
      final updateResult = await appUserRepository.updateAppUser(updatedUser);

      updateResult.fold(
        (failure) => _logger.warning('🏪 Ошибка обновления AppUser с outlet: ${failure.message}'),
        (updatedAppUser) => _logger.info('🏪 ✅ Outlet успешно выбран: ${tradingPoint!.name}'),
      );

    } catch (e, st) {
      _logger.warning('🏪 Ошибка при парсинге outlet: $e', e, st);
    }
  }
}