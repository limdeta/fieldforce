import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fieldforce/app/domain/usecases/create_app_user_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_work_days_for_user_usecase.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/features/authentication/di/auth_di.dart';
import 'package:fieldforce/features/authentication/domain/services/user_service.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/features/navigation/tracking/di/navigation_di.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_employee_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/user_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/session_repository_impl.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/trading_point_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/category_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/product_repository_drift.dart';
import 'package:fieldforce/app/services/simple_update_service.dart';
import 'package:fieldforce/app/services/post_authentication_service.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/app/services/trading_point_sync_service.dart';
import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/features/navigation/path_predictor/osrm_path_prediction_service.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/app_lifecycle_manager.dart';
import 'package:fieldforce/app/services/user_preferences_service.dart';
import 'package:fieldforce/app/database/repositories/work_day_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_trigger.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/di/shop_di.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  AppConfig.configureFromArgs();

  if (AppConfig.enableDetailedLogging) {
    AppConfig.printConfig();
  }

  await getIt.reset();

  getIt.registerLazySingleton<UserPreferencesService>(() {
    final service = UserPreferencesService();
    service.initialize();
    return service;
  });

  getIt.registerSingleton<AppDatabase>(
    AppDatabase.withFile(AppConfig.databaseName),
  );
  getIt.registerLazySingleton<WorkDayRepository>(
    () => WorkDayRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl());
  getIt.registerLazySingleton<OsrmPathPredictionService>(
    () => OsrmPathPredictionService(),
  );

  getIt.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(database: getIt()),
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

  getIt.registerLazySingleton<CategoryRepository>(
    () => DriftCategoryRepository(),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => DriftProductRepository(),
  );

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<SessionManager>(() => SessionManager.instance);

  registerShopDependencies(getIt);
  registerAuthenticationDependencies(getIt);

  getIt.registerLazySingleton<SimpleUpdateService>(() => SimpleUpdateService());

  getIt.registerLazySingleton<GetWorkDaysForUserUseCase>(
    () => GetWorkDaysForUserUseCase(),
  );

  getIt.registerLazySingleton<AppLifecycleManager>(() => AppLifecycleManager());

  await registerNavigationDependencies(
    getIt,
    gpsMode: AppConfig.isProd ? GpsMode.real : GpsMode.mock,
  );

  getIt.registerLazySingleton<UserFixture>(
    () => UserFixture(
      userService: getIt<UserService>(),
      createEmployeeUseCase: getIt<CreateEmployeeUseCase>(),
      createAppUserUseCase: getIt<CreateAppUserUseCase>(),
    ),
  );

  getIt.registerLazySingleton<TradingPointSyncService>(
    () => TradingPointSyncService(
      sessionManager: getIt<SessionManager>(),
      tradingPointRepository: getIt<TradingPointRepository>(),
      appUserRepository: getIt<AppUserRepository>(),
    ),
  );

  // Post authentication service for creating business entities
  getIt.registerLazySingleton<PostAuthenticationService>(
    () => PostAuthenticationService(
      employeeRepository: getIt<EmployeeRepository>(),
      appUserRepository: getIt<AppUserRepository>(),
      tradingPointRepository: getIt<TradingPointRepository>(),
      authApiService: getIt<IAuthApiService>(),
      tradingPointSyncService: getIt<TradingPointSyncService>(),
    ),
  );

  unawaited(getIt<OrderSubmissionQueueTrigger>().start());
  // Kick off processing of any pending order submissions in the background.
  unawaited(getIt<JobQueueService<OrderSubmissionJob>>().triggerProcessing());
}
