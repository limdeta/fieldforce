import 'package:fieldforce/app/di/route_di.dart';
import 'package:fieldforce/app/domain/usecases/app_user_login_usecase.dart';
import 'package:fieldforce/app/domain/usecases/app_user_logout_usecase.dart';
import 'package:fieldforce/app/domain/usecases/create_app_user_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_current_app_session_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_work_days_for_user_usecase.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/features/authentication/domain/services/user_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_track_for_date_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_tracks_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_employee_usecase.dart';
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
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/app/database/repositories/category_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/app/database/repositories/product_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/data/repositories/order_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/add_product_to_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_order_state_usecase.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  AppConfig.configureFromArgs();

  if (AppConfig.enableDetailedLogging) {
    AppConfig.printConfig();
  }

  await getIt.reset();

  getIt.registerLazySingleton<UserPreferencesService>(
    () {
      final service = UserPreferencesService();
      service.initialize();
      return service;
    },
  );

  getIt.registerSingleton<AppDatabase>(AppDatabase.withFile(AppConfig.databaseName));
  getIt.registerLazySingleton<WorkDayRepository>(
    () => WorkDayRepository(getIt<AppDatabase>()),
  );
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

  getIt.registerLazySingleton<UserTrackRepositoryDrift>(
        () => UserTrackRepositoryDrift(
          getIt<AppDatabase>(),
          getIt<EmployeeRepositoryDrift>(),
        ),
  );

  getIt.registerLazySingleton<TradingPointRepository>(
    () => DriftTradingPointRepository(),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => DriftCategoryRepository(),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => DriftProductRepository(),
  );

  // Order repositories and use cases
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryDrift(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<AddProductToOrderUseCase>(
    () => AddProductToOrderUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<UpdateOrderStateUseCase>(
    () => UpdateOrderStateUseCase(getIt<OrderRepository>()),
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

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetEmployeeTradingPointsUseCase>(
    () => GetEmployeeTradingPointsUseCase(getIt<TradingPointRepository>()),
  );

  getIt.registerLazySingleton<AppUserLoginUseCase>(
    () => AppUserLoginUseCase(),
  );

  getIt.registerLazySingleton<AppUserLogoutUseCase>(
    () => AppUserLogoutUseCase(),
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


  getIt.registerLazySingleton<GetCurrentAppSessionUseCase>(
    () => GetCurrentAppSessionUseCase(),
  );

  getIt.registerLazySingleton<GetUserTrackForDateUseCase>(
        () => GetUserTrackForDateUseCase(userTrackRepository: getIt()),
  );

  getIt.registerLazySingleton<GetWorkDaysForUserUseCase>(
    () => GetWorkDaysForUserUseCase(),
  );

  getIt.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentSessionUseCase: getIt<GetCurrentSessionUseCase>(),
    ),
  );

  getIt.registerLazySingleton<AppLifecycleManager>(
    () => AppLifecycleManager(),
  );

  RouteDI.registerDependencies();

  getIt.registerLazySingleton<UserTrackRepository>(
    () => UserTrackRepositoryDrift(
      getIt<AppDatabase>(),
      getIt<EmployeeRepositoryDrift>(),
    ),
  );

  getIt.registerLazySingleton<LocationTrackingServiceBase>(
    () => LocationTrackingService(getIt<GpsDataManager>()),
  );

  // GPS initialization based on environment
  if (AppConfig.isProd) {
    await GpsDataManager().initialize(mode: GpsMode.real);
    getIt.registerSingleton<GpsDataManager>(GpsDataManager());
  } else {
    await GpsDataManager().initialize(mode: GpsMode.mock);
    getIt.registerSingleton<GpsDataManager>(GpsDataManager());
  }

  getIt.registerLazySingleton<GetUserTracksUseCase>(
    () => GetUserTracksUseCase(getIt<UserTrackRepository>()),
  );

  getIt.registerLazySingleton<LoadUserRoutesUseCase>(
    () => LoadUserRoutesUseCase(getIt<RouteRepository>()),
  );

  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<CreateEmployeeUseCase>(
    () => CreateEmployeeUseCase(getIt<EmployeeRepository>()),
  );

  getIt.registerLazySingleton<CreateAppUserUseCase>(
    () => CreateAppUserUseCase(getIt<AppUserRepository>()),
  );

  getIt.registerLazySingleton<UserFixture>(
    () => UserFixture(
      userService: getIt<UserService>(),
      createEmployeeUseCase: getIt<CreateEmployeeUseCase>(),
      createAppUserUseCase: getIt<CreateAppUserUseCase>(),
    ),
  );
}