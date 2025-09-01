import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/data/di/route_di.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/usecases/get_user_tracks_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/providers/user_tracks_provider.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/app/database/repositories/user_track_repository_drift.dart';
import 'package:fieldforce/app/services/app_lifecycle_manager.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/app/database/repositories/user_repository_drift.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/app/database/repositories/session_repository_impl.dart';
import 'package:fieldforce/features/navigation/path_predictor/osrm_path_prediction_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/app/database/repositories/app_user_repository_drift.dart';
import 'package:fieldforce/features/authentication/data/fixtures/user_fixture_service.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:fieldforce/app/services/app_user_login_service.dart';
import 'package:fieldforce/app/services/app_user_logout_service.dart';
import 'package:fieldforce/app/services/simple_update_service.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/app/database/repositories/trading_point_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_employee_trading_points_usecase.dart';

/// Тестовый Service Locator для настройки зависимостей в тестах
class TestServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static Future<void> initialize() async {

    if (_getIt.isRegistered<AppDatabase>()) {
      await _getIt.unregister<AppDatabase>();
    }

    final testDatabase = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    _getIt.registerSingleton<AppDatabase>(testDatabase);

    RouteDI.registerDependencies();

    // Регистрация остальных зависимостей
    if (_getIt.isRegistered<AppLifecycleManager>()) {
      await _getIt.unregister<AppLifecycleManager>();
    }

    if (_getIt.isRegistered<UserRepository>()) {
      await _getIt.unregister<UserRepository>();
    }

    if (_getIt.isRegistered<UserTrackRepository>()) {
      await _getIt.unregister<UserTrackRepository>();
    }

    if (_getIt.isRegistered<LoginUseCase>()) {
      await _getIt.unregister<LoginUseCase>();
    }

    if (_getIt.isRegistered<AuthenticationService>()) {
      await _getIt.unregister<AuthenticationService>();
    }

    // Register SessionRepository
    if (_getIt.isRegistered<SessionRepository>()) {
      await _getIt.unregister<SessionRepository>();
    }
    _getIt.registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl());

    // Register OsrmPathPredictionService
    if (_getIt.isRegistered<OsrmPathPredictionService>()) {
      await _getIt.unregister<OsrmPathPredictionService>();
    }
    _getIt.registerLazySingleton<OsrmPathPredictionService>(() => OsrmPathPredictionService());

    // Register EmployeeRepository
    if (_getIt.isRegistered<EmployeeRepository>()) {
      await _getIt.unregister<EmployeeRepository>();
    }
    _getIt.registerLazySingleton<EmployeeRepositoryDrift>(() => EmployeeRepositoryDrift(_getIt<AppDatabase>()));
    _getIt.registerLazySingleton<EmployeeRepository>(() => _getIt<EmployeeRepositoryDrift>());

    // Register AppUserRepository
    if (_getIt.isRegistered<AppUserRepository>()) {
      await _getIt.unregister<AppUserRepository>();
    }
    _getIt.registerLazySingleton<AppUserRepository>(() => AppUserRepositoryDrift(
      database: _getIt<AppDatabase>(),
      employeeRepository: _getIt<EmployeeRepositoryDrift>(),
      userRepository: _getIt<UserRepositoryImpl>(),
    ));

    // Register UserFixtureService
    if (_getIt.isRegistered<UserFixtureService>()) {
      await _getIt.unregister<UserFixtureService>();
    }
    _getIt.registerLazySingleton<UserFixtureService>(() => UserFixtureService(_getIt()));

    // Register LogoutUseCase
    if (_getIt.isRegistered<LogoutUseCase>()) {
      await _getIt.unregister<LogoutUseCase>();
    }
    _getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(authenticationService: _getIt()));

    // Register GetCurrentSessionUseCase
    if (_getIt.isRegistered<GetCurrentSessionUseCase>()) {
      await _getIt.unregister<GetCurrentSessionUseCase>();
    }
    _getIt.registerLazySingleton<GetCurrentSessionUseCase>(() => GetCurrentSessionUseCase(sessionRepository: _getIt()));

    // Register AppUserLoginService
    if (_getIt.isRegistered<AppUserLoginService>()) {
      await _getIt.unregister<AppUserLoginService>();
    }
    _getIt.registerLazySingleton<AppUserLoginService>(() => AppUserLoginService());

    // Register AppUserLogoutService
    if (_getIt.isRegistered<AppUserLogoutService>()) {
      await _getIt.unregister<AppUserLogoutService>();
    }
    _getIt.registerLazySingleton<AppUserLogoutService>(() => AppUserLogoutService());

    _getIt.registerLazySingleton<SimpleUpdateService>(() => SimpleUpdateService());

    _getIt.registerLazySingleton<AppLifecycleManager>(() => AppLifecycleManager());
    _getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(database: _getIt<AppDatabase>()));
    _getIt.registerLazySingleton<UserTrackRepository>(() => UserTrackRepositoryDrift(_getIt<AppDatabase>(), _getIt()));
    _getIt.registerLazySingleton<LocationTrackingService>(() => LocationTrackingService());
    _getIt.registerLazySingleton<GetUserTracksUseCase>(() => GetUserTracksUseCase(_getIt<UserTrackRepository>()));
    _getIt.registerFactory<UserTracksProvider>(() => UserTracksProvider(_getIt<GetUserTracksUseCase>()));
    _getIt.registerLazySingleton<AuthenticationService>(() => AuthenticationService(
      userRepository: _getIt<UserRepository>(),
      sessionRepository: _getIt(),
    ));

    // Trading Point Repository и Use Case
    _getIt.registerLazySingleton<TradingPointRepository>(() => DriftTradingPointRepository());
    _getIt.registerLazySingleton<GetEmployeeTradingPointsUseCase>(() => GetEmployeeTradingPointsUseCase(_getIt<TradingPointRepository>()));

    _getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(_getIt<AuthenticationService>()));
  }

  /// Очистка всех зависимостей после тестов
  static Future<void> dispose() async {
    if (_getIt.isRegistered<AppDatabase>()) {
      final db = _getIt<AppDatabase>();
      await db.close();
      await _getIt.unregister<AppDatabase>();
    }

    RouteDI.clearDependencies();
  }
}
