import 'package:fieldforce/app/di/route_di.dart';
import 'package:fieldforce/app/domain/usecases/app_user_login_usecase.dart';
import 'package:fieldforce/app/domain/usecases/app_user_logout_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_current_app_session_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_work_days_for_user_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_track_for_date_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_tracks_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/user_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/session_repository_impl.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/app_user_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/user_track_repository_drift.dart';
import 'package:fieldforce/app/services/simple_update_service.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/bloc.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_employee_trading_points_usecase.dart';
import 'package:fieldforce/app/database/repositories/trading_point_repository_drift.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/path_predictor/osrm_path_prediction_service.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/app_lifecycle_manager.dart';
import 'package:fieldforce/app/domain/usecases/load_user_routes_usecase.dart';
import 'package:fieldforce/app/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/services/user_preferences_service.dart';
import 'package:fieldforce/app/database/repositories/work_day_repository.dart';
import '../../features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';

final _getIt = GetIt.instance;

Future<void> setupTestServiceLocator() async {
  AppConfig.configureFromArgs();
  AppConfig.printConfig();

  await _getIt.reset();

  _getIt.registerLazySingleton<UserPreferencesService>(
    () {
      final service = UserPreferencesService();
      service.initialize();
      return service;
    },
  );

  _getIt.registerSingleton<AppDatabase>(AppDatabase.withFile(AppConfig.databaseName));
  _getIt.registerLazySingleton<WorkDayRepository>(
    () => WorkDayRepository(_getIt<AppDatabase>()),
  );
  _getIt.registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl());
  _getIt.registerLazySingleton<OsrmPathPredictionService>(() => OsrmPathPredictionService());

  _getIt.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      database: _getIt(),
    ),
  );

  _getIt.registerLazySingleton<UserRepository>(
    () => _getIt<UserRepositoryImpl>(),
  );

  _getIt.registerLazySingleton<EmployeeRepositoryDrift>(
    () => EmployeeRepositoryDrift(_getIt<AppDatabase>()),
  );

  _getIt.registerLazySingleton<EmployeeRepository>(
    () => _getIt<EmployeeRepositoryDrift>(),
  );

  _getIt.registerLazySingleton<UserTrackRepositoryDrift>(
        () => UserTrackRepositoryDrift(
          _getIt<AppDatabase>(),
          _getIt<EmployeeRepositoryDrift>(),
        ),
  );

  _getIt.registerLazySingleton<TradingPointRepository>(
    () => DriftTradingPointRepository(),
  );

  _getIt.registerLazySingleton<AppUserRepository>(
    () => AppUserRepositoryDrift(
      database: _getIt<AppDatabase>(),
      employeeRepository: _getIt<EmployeeRepositoryDrift>(),
      userRepository: _getIt<UserRepositoryImpl>(),
    ),
  );

  _getIt.registerLazySingleton<AuthenticationService>(
    () => AuthenticationService(
      userRepository: _getIt(),
      sessionRepository: _getIt(),
    ),
  );

  _getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(_getIt()),
  );

  _getIt.registerLazySingleton<GetEmployeeTradingPointsUseCase>(
    () => GetEmployeeTradingPointsUseCase(_getIt<TradingPointRepository>()),
  );

  _getIt.registerLazySingleton<AppUserLoginUseCase>(
    () => AppUserLoginUseCase(),
  );

  _getIt.registerLazySingleton<AppUserLogoutUseCase>(
    () => AppUserLogoutUseCase(),
  );

  _getIt.registerLazySingleton<SimpleUpdateService>(
    () => SimpleUpdateService(),
  );

  _getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(authenticationService: _getIt()),
  );

  _getIt.registerLazySingleton<GetCurrentSessionUseCase>(
    () => GetCurrentSessionUseCase(sessionRepository: _getIt()),
  );


  _getIt.registerLazySingleton<GetCurrentAppSessionUseCase>(
    () => GetCurrentAppSessionUseCase(),
  );

  _getIt.registerLazySingleton<GetUserTrackForDateUseCase>(
        () => GetUserTrackForDateUseCase(userTrackRepository: _getIt()),
  );

  _getIt.registerLazySingleton<GetWorkDaysForUserUseCase>(
    () => GetWorkDaysForUserUseCase(),
  );

  _getIt.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(
      loginUseCase: _getIt<LoginUseCase>(),
      logoutUseCase: _getIt<LogoutUseCase>(),
      getCurrentSessionUseCase: _getIt<GetCurrentSessionUseCase>(),
    ),
  );

  _getIt.registerLazySingleton<AppLifecycleManager>(
    () => AppLifecycleManager(),
  );

  RouteDI.registerDependencies();

  _getIt.registerLazySingleton<UserTrackRepository>(
    () => UserTrackRepositoryDrift(
      _getIt<AppDatabase>(),
      _getIt<EmployeeRepositoryDrift>(),
    ),
  );

  _getIt.registerLazySingleton<LocationTrackingServiceBase>(
    () => LocationTrackingService(_getIt<GpsDataManager>()),
  );

  // GpsDataManager с mock источником для тестов
  await GpsDataManager().initialize(mode: GpsMode.mock);
  _getIt.registerSingleton<GpsDataManager>(GpsDataManager());

  _getIt.registerLazySingleton<GetUserTracksUseCase>(
    () => GetUserTracksUseCase(_getIt<UserTrackRepository>()),
  );

  _getIt.registerLazySingleton<LoadUserRoutesUseCase>(
    () => LoadUserRoutesUseCase(_getIt<RouteRepository>()),
  );
}
