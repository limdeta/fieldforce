import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/user_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/session_repository_impl.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/app_user_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/user_track_repository_drift.dart';
import 'package:fieldforce/app/services/app_user_login_service.dart';
import 'package:fieldforce/app/services/app_user_logout_service.dart';
import 'package:fieldforce/app/services/simple_update_service.dart';
import 'package:fieldforce/features/authentication/data/fixtures/user_fixture_service.dart';
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
import 'package:fieldforce/features/shop/data/di/route_di.dart';
import 'package:fieldforce/app/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/usecases/get_user_tracks_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/providers/user_tracks_provider.dart';
import 'package:fieldforce/features/navigation/path_predictor/osrm_path_prediction_service.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/app_lifecycle_manager.dart';
import 'package:fieldforce/app/presentation/usecases/load_user_routes_usecase.dart';
import 'package:fieldforce/features/shop/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/providers/selected_route_provider.dart';
import 'package:fieldforce/app/services/user_preferences_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  AppConfig.configureFromArgs();
  
  if (AppConfig.enableDetailedLogging) {
    AppConfig.printConfig();
  }

  getIt.registerLazySingleton<UserPreferencesService>(
    () {
      final service = UserPreferencesService();
      service.initialize();
      return service;
    },
  );
  
  getIt.registerLazySingleton<SelectedRouteProvider>(() => SelectedRouteProvider());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl());
  getIt.registerLazySingleton<OsrmPathPredictionService>(() => OsrmPathPredictionService());

  getIt.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      database: getIt(),
    ),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => getIt<UserRepositoryImpl>(),
  );

  getIt.registerLazySingleton<EmployeeRepositoryDrift>(
    () => EmployeeRepositoryDrift(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<EmployeeRepository>(
    () => getIt<EmployeeRepositoryDrift>(),
  );

  getIt.registerLazySingleton<TradingPointRepository>(
    () => DriftTradingPointRepository(),
  );

  getIt.registerLazySingleton<AppUserRepository>(
    () => AppUserRepositoryDrift(
      database: getIt<AppDatabase>(),
      employeeRepository: getIt<EmployeeRepositoryDrift>(),
      userRepository: getIt<UserRepositoryImpl>(),
    ),
  );

  getIt.registerLazySingleton<AuthenticationService>(
    () => AuthenticationService(
      userRepository: getIt(),
      sessionRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<UserFixtureService>(
    () => UserFixtureService(getIt()),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetEmployeeTradingPointsUseCase>(
    () => GetEmployeeTradingPointsUseCase(getIt<TradingPointRepository>()),
  );

  getIt.registerLazySingleton<AppUserLoginService>(
    () => AppUserLoginService(),
  );

  getIt.registerLazySingleton<AppUserLogoutService>(
    () => AppUserLogoutService(),
  );

  getIt.registerLazySingleton<SimpleUpdateService>(
    () => SimpleUpdateService(),
  );
  
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(authenticationService: getIt()),
  );
  
  getIt.registerLazySingleton<GetCurrentSessionUseCase>(
    () => GetCurrentSessionUseCase(sessionRepository: getIt()),
  );
  
  // BLoCs for features layer
  getIt.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentSessionUseCase: getIt<GetCurrentSessionUseCase>(),
    ),
  );
  
  // App Lifecycle Manager for GPS tracking
  getIt.registerLazySingleton<AppLifecycleManager>(
    () => AppLifecycleManager(),
  );
  
  // Route dependencies
  RouteDI.registerDependencies();

  getIt.registerLazySingleton<UserTrackRepository>(
    () => UserTrackRepositoryDrift(
      getIt<AppDatabase>(), 
      getIt<EmployeeRepositoryDrift>(),
    ),
  );

  getIt.registerLazySingleton<LocationTrackingService>(() => LocationTrackingService());
  
  // Tracking presentation layer
  getIt.registerLazySingleton<GetUserTracksUseCase>(
    () => GetUserTracksUseCase(getIt<UserTrackRepository>()),
  );
  
  getIt.registerLazySingleton<UserTracksProvider>(
    () => UserTracksProvider(getIt<GetUserTracksUseCase>()),
  );

  // Presentation layer UseCases
  getIt.registerLazySingleton<LoadUserRoutesUseCase>(
    () => LoadUserRoutesUseCase(getIt<RouteRepository>()),
  );
}
