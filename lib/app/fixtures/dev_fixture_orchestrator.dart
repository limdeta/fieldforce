import 'package:fieldforce/app/database/repositories/work_day_repository.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/usecases/create_work_day_usecase.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/app/fixtures/route_fixture_service.dart';
import 'package:fieldforce/features/navigation/tracking/data/fixtures/track_fixtures.dart';
import 'package:fieldforce/features/shop/data/fixtures/trading_points_fixture_service.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/authentication/domain/services/user_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_employee_usecase.dart';
import 'package:fieldforce/app/domain/usecases/create_app_user_usecase.dart';
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

final saddam = DevUserData(
  name: 'Саддам Хусейн',
  email: 'salesrep@fieldforce.dev',
  password: 'password123',
  phone: '+7-999-111-2233',
  role: UserRole.admin,
);

class DevAppUsers {
  final List<AppUser> users;

  const DevAppUsers({
    required this.users,
  });
}

/// Центральный оркестратор для создания всех dev фикстур
class DevFixtureOrchestrator {
  final UserService _userService;
  final RouteFixtureService _routeFixtureService;
  final TradingPointsFixtureService _tradingPointsService;
  final CreateEmployeeUseCase _createEmployeeUseCase;
  final CreateAppUserUseCase _createAppUserUseCase;
  final CreateWorkDayUseCase _createWorkDayUseCase;

  DevFixtureOrchestrator(
      this._userService,
      this._routeFixtureService,
      this._tradingPointsService,
      this._createEmployeeUseCase,
      this._createAppUserUseCase,
      this._createWorkDayUseCase,
      );

  /// Создает полный набор dev данных
  Future<void> createFullDevDataset() async {
    await _clearAllData();
    await _tradingPointsService.createBaseTradingPoints();
    await createScenarioUser(saddam);
    print("Загрузил все dev фикстуры");
  }

  Future<void> _clearAllData() async {
    final database = GetIt.instance<AppDatabase>();
    await database.customStatement('PRAGMA foreign_keys = OFF');
    for (final table in database.allTables) {
      await database.delete(table).go();
    }
    await database.customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> createScenarioUser(DevUserData userData) async {
    try {
      final authUser = await _userService.createUser(
        externalId: userData.email,
        role: userData.role,
        phone: userData.phone,
        rawPassword: userData.password,
      );

      // Создаём сотрудника через UseCase
      final employeeResult = await _createEmployeeUseCase.call(
        lastName: userData.name.split(' ').first,
        firstName: userData.name.split(' ').last,
        middleName: null,
        role: EmployeeRole.sales,
      );
      final createdEmployee = employeeResult.fold(
        (failure) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: failure,
            stack: StackTrace.current,
            library: 'DevFixtureOrchestrator',
            context: ErrorDescription('Ошибка создания сотрудника'),
          ));
          throw Exception('Ошибка создания сотрудника: ${failure.message}');
        },
        (emp) => emp,
      );

      // Создаём AppUser через UseCase
      final appUserResult = await _createAppUserUseCase.call(
        employee: createdEmployee,
        user: authUser,
      );
      final saddamHusein = appUserResult.fold(
        (failure) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: failure,
            stack: StackTrace.current,
            library: 'DevFixtureOrchestrator',
            context: ErrorDescription('Ошибка создания AppUser'),
          ));
          throw Exception('Ошибка создания AppUser: ${failure.message}');
        },
        (au) => au,
      );

      // 1. Маршруты
      final yesterdayRoute = await unwrapOrThrow(
          _routeFixtureService.createYesterdayRoute(saddamHusein.employee),
          'Yesterday Route creation failed'
      );


      final todayRoute = await unwrapOrThrow(
          _routeFixtureService.createTodayRoute(saddamHusein.employee),
          'Today Route creation failed'
      );

      // 2. Треки
      final todayTrack = await TrackFixtures.createTodayTrack(
          user: saddamHusein, route: todayRoute
      );

      // 3. WorkDay
      _createWorkDayUseCase.call(
        user: saddamHusein,
        route: yesterdayRoute,
        track: null,
        date: DateTime.now().subtract(const Duration(days: 1)),
      );

      _createWorkDayUseCase.call(
        user: saddamHusein,
        track: todayTrack,
        route: todayRoute,
        date: DateTime.now(),
      );
    } catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'DevFixtureOrchestrator',
        context: ErrorDescription('Ошибка при создании сценария пользователя'),
      ));
      rethrow;
    }
  }
}

class DevFixtureOrchestratorFactory {
  static DevFixtureOrchestrator create() {
    final userService = UserServiceFactory.create();
    final routeFixtureService = RouteFixtureServiceFactory.create();
    final tradingPointsService = TradingPointsFixtureService();
    final employeeRepository = GetIt.instance<EmployeeRepository>();
    final appUserRepository = GetIt.instance<AppUserRepository>();
    final workDayRepository = GetIt.instance<WorkDayRepository>();
    final createEmployeeUseCase = CreateEmployeeUseCase(employeeRepository);
    final createAppUserUseCase = CreateAppUserUseCase(appUserRepository);
    final createWorkDayUseCase = CreateWorkDayUseCase(workDayRepository);
    return DevFixtureOrchestrator(
      userService,
      routeFixtureService,
      tradingPointsService,
      createEmployeeUseCase,
      createAppUserUseCase,
      createWorkDayUseCase,
    );
  }
}
