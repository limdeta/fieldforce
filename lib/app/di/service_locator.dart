import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fieldforce/app/di/route_di.dart';
import 'package:fieldforce/app/domain/usecases/app_user_login_usecase.dart';
import 'package:fieldforce/app/domain/usecases/app_user_logout_usecase.dart';
import 'package:fieldforce/app/domain/usecases/create_app_user_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_current_app_session_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_work_days_for_user_usecase.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/features/authentication/domain/services/user_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
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
import 'package:fieldforce/app/services/post_authentication_service.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/app/services/trading_point_sync_service.dart';
import 'package:fieldforce/app/jobs/job_queue_repository.dart';
import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/services/auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/services/mock_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/bloc.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/user_tracks_bloc.dart';
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
import 'package:fieldforce/features/shop/data/services/product_sync_service_impl.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/regional_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/stock_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/outlet_pricing_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/protobuf_sync_coordinator.dart';
import 'package:fieldforce/features/shop/data/sync/repositories/protobuf_sync_repository.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_trigger.dart';
import 'package:fieldforce/app/database/repositories/product_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/data/repositories/order_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/add_product_to_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_current_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_item_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_stock_item_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/remove_from_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/clear_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/submit_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/retry_order_submission_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_orders_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_order_by_id_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/orders_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/protobuf_sync_bloc.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_order_state_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/perform_protobuf_sync_usecase.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/app/database/repositories/stock_item_repository_drift.dart';
import 'package:fieldforce/features/shop/data/services/isolate_sync_manager.dart';
import 'package:fieldforce/features/shop/data/repositories/order_job_repository_impl.dart';
import 'package:fieldforce/features/shop/data/services/mock_order_api_service.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_service.dart';

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

  getIt.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );

  // Order repositories and use cases
  getIt.registerLazySingleton<OrderRepository>(
    () =>
        OrderRepositoryDrift(getIt<AppDatabase>(), getIt<ProductRepository>()),
  );

  getIt.registerLazySingleton<StockItemRepository>(
    () => DriftStockItemRepository(),
  );

  getIt.registerLazySingleton<JobQueueRepository<OrderSubmissionJob>>(
    () => OrderJobRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<OrderApiService>(
    () => MockOrderApiService(),
  );

  getIt.registerLazySingleton<OrderSubmissionService>(
    () => OrderSubmissionService(apiService: getIt<OrderApiService>()),
  );

  getIt.registerLazySingleton<JobQueueService<OrderSubmissionJob>>(
    () => OrderSubmissionQueueService(
      repository: getIt<JobQueueRepository<OrderSubmissionJob>>(),
      orderRepository: getIt<OrderRepository>(),
      submissionService: getIt<OrderSubmissionService>(),
    ),
  );

  getIt.registerLazySingleton<RetryOrderSubmissionUseCase>(
    () => RetryOrderSubmissionUseCase(
      orderRepository: getIt<OrderRepository>(),
      queueService: getIt<JobQueueService<OrderSubmissionJob>>(),
    ),
  );

  getIt.registerLazySingleton<OrderSubmissionQueueTrigger>(
    () => ConnectivityOrderSubmissionQueueTrigger(
      connectivity: getIt<Connectivity>(),
      queueService: getIt<JobQueueService<OrderSubmissionJob>>(),
    ),
  );

  // Protobuf Sync Services
  getIt.registerLazySingleton<ProtobufSyncRepository>(
    () => ProtobufSyncRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<RegionalSyncService>(
    () => RegionalSyncService(
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  getIt.registerLazySingleton<StockSyncService>(
    () => StockSyncService(
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  getIt.registerLazySingleton<OutletPricingSyncService>(
    () => OutletPricingSyncService(
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  getIt.registerLazySingleton<ProtobufSyncCoordinator>(
    () => ProtobufSyncCoordinator(
      regionalSyncService: getIt<RegionalSyncService>(),
      stockSyncService: getIt<StockSyncService>(),
      outletPricingSyncService: getIt<OutletPricingSyncService>(),
      syncRepository: getIt<ProtobufSyncRepository>(),
      productRepository: getIt<ProductRepository>(),
      stockItemRepository: getIt<StockItemRepository>(),
    ),
  );

  // Product parsing service
  getIt.registerLazySingleton<ProductParsingService>(
    () => ProductParsingService(),
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

  // Cart Use Cases
  getIt.registerLazySingleton<GetCurrentCartUseCase>(
    () => GetCurrentCartUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<UpdateCartItemUseCase>(
    () => UpdateCartItemUseCase(
      getIt<OrderRepository>(),
      getIt<StockItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateCartStockItemUseCase>(
    () => UpdateCartStockItemUseCase(
      getIt<OrderRepository>(),
      getIt<StockItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<UpdateCartUseCase>(
    () => UpdateCartUseCase(
      getIt<OrderRepository>(),
      getIt<StockItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<ClearCartUseCase>(
    () => ClearCartUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<SubmitOrderUseCase>(
    () => SubmitOrderUseCase(
      orderRepository: getIt<OrderRepository>(),
      queueService: getIt<JobQueueService<OrderSubmissionJob>>(),
    ),
  );

  // Orders Use Cases
  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<GetOrderByIdUseCase>(
    () => GetOrderByIdUseCase(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<PerformProtobufSyncUseCase>(
    () => PerformProtobufSyncUseCase(getIt<ProtobufSyncCoordinator>()),
  );

  // BLoCs
  getIt.registerLazySingleton<CartBloc>(
    () => CartBloc(
      getCurrentCartUseCase: getIt<GetCurrentCartUseCase>(),
      updateCartItemUseCase: getIt<UpdateCartItemUseCase>(),
      updateCartStockItemUseCase: getIt<UpdateCartStockItemUseCase>(),
      removeFromCartUseCase: getIt<RemoveFromCartUseCase>(),
      updateCartUseCase: getIt<UpdateCartUseCase>(),
      clearCartUseCase: getIt<ClearCartUseCase>(),
      submitOrderUseCase: getIt<SubmitOrderUseCase>(),
    ),
  );

  getIt.registerFactory<OrdersBloc>(
    () => OrdersBloc(
      getOrdersUseCase: getIt<GetOrdersUseCase>(),
      getOrderByIdUseCase: getIt<GetOrderByIdUseCase>(),
      retryOrderSubmissionUseCase: getIt<RetryOrderSubmissionUseCase>(),
    ),
  );

  getIt.registerFactory<ProtobufSyncBloc>(
    () => ProtobufSyncBloc(
      performProtobufSyncUseCase: getIt<PerformProtobufSyncUseCase>(),
    ),
  );

  getIt.registerLazySingleton<AppUserRepository>(
    () => AppUserRepositoryDrift(
      database: getIt<AppDatabase>(),
      employeeRepository: getIt<EmployeeRepositoryDrift>(),
      userRepository: getIt<UserRepositoryImpl>(),
    ),
  );

  getIt.registerLazySingleton<IAuthApiService>(
    () => AppConfig.useMockAuth ? MockAuthApiService() : AuthApiService(),
  );

  getIt.registerLazySingleton<AuthenticationService>(
    () => AuthenticationService(
      userRepository: getIt(),
      sessionRepository: getIt(),
      authApiService: getIt(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));

  getIt.registerLazySingleton<GetEmployeeTradingPointsUseCase>(
    () => GetEmployeeTradingPointsUseCase(getIt<TradingPointRepository>()),
  );

  getIt.registerLazySingleton<AppUserLoginUseCase>(() => AppUserLoginUseCase());

  getIt.registerLazySingleton<AppUserLogoutUseCase>(
    () => AppUserLogoutUseCase(),
  );

  getIt.registerLazySingleton<SimpleUpdateService>(() => SimpleUpdateService());

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

  getIt.registerLazySingleton<AppLifecycleManager>(() => AppLifecycleManager());

  RouteDI.registerDependencies();

  getIt.registerLazySingleton<UserTrackRepository>(
    () => UserTrackRepositoryDrift(
      getIt<AppDatabase>(),
      getIt<EmployeeRepositoryDrift>(),
    ),
  );

  // TrackManager как синглтон для управления GPS треками
  getIt.registerLazySingleton<TrackManager>(
    () => TrackManager(getIt<UserTrackRepository>()),
  );

  getIt.registerLazySingleton<LocationTrackingServiceBase>(
    () =>
        LocationTrackingService(getIt<GpsDataManager>(), getIt<TrackManager>()),
  );

  // TrackingBloc как синглтон для сохранения состояния между экранами
  getIt.registerLazySingleton<TrackingBloc>(() => TrackingBloc());

  // UserTracksBloc as a singleton so its subscriptions and state survive
  // navigation and don't get disposed when pages are popped/pushed.
  getIt.registerLazySingleton<UserTracksBloc>(() => UserTracksBloc());

  // GPS initialization based on environment
  final gpsManager = GpsDataManager();
  if (AppConfig.isProd) {
    await gpsManager.initialize(mode: GpsMode.real);
  } else {
    await gpsManager.initialize(mode: GpsMode.mock);
  }
  getIt.registerSingleton<GpsDataManager>(gpsManager);

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

  // Session manager for handling HTTP sessions and cookies
  getIt.registerLazySingleton<SessionManager>(() => SessionManager.instance);

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
    ),
  );

  // Sync services for product synchronization
  // Удалены устаревшие SyncIsolateManager и SyncProgressManager

  // New isolate-based sync manager
  getIt.registerLazySingleton(
    () => IsolateSyncManager(
      productRepository: getIt<ProductRepository>(),
      stockItemRepository: getIt<StockItemRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      productsApiUrl: AppConfig.productsApiUrl,
      categoriesApiUrl: AppConfig.categoriesApiUrl,
      sessionManager: getIt<SessionManager>(),
    ),
  );

  // Product sync service implementation
  getIt.registerLazySingleton(
    () => ProductSyncServiceImpl(
      sessionManager: getIt<SessionManager>(),
      isolateManager: getIt<IsolateSyncManager>(),
    ),
  );

  unawaited(getIt<OrderSubmissionQueueTrigger>().start());
  // Kick off processing of any pending order submissions in the background.
  unawaited(getIt<JobQueueService<OrderSubmissionJob>>().triggerProcessing());
}
