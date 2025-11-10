import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/stock_item_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/warehouse_repository_drift.dart';
import 'package:fieldforce/app/jobs/job_queue_repository.dart';
import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/app/presentation/widgets/trading_point_map/trading_point_map_factory.dart';
import 'package:fieldforce/app/services/category_tree_cache_service.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/app/services/trading_point_sync_service.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/data/repositories/order_job_repository_impl.dart';
import 'package:fieldforce/features/shop/data/repositories/order_repository_drift.dart';
import 'package:fieldforce/features/shop/data/services/mock_order_api_service.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/data/sync/repositories/protobuf_sync_repository.dart';
import 'package:fieldforce/features/shop/data/sync/services/outlet_pricing_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/protobuf_sync_coordinator.dart';
import 'package:fieldforce/features/shop/data/sync/services/regional_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/stock_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/warehouse_sync_service.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/data/services/isolate_sync_manager.dart';
import 'package:fieldforce/features/shop/data/services/product_sync_service_impl.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_trigger.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_service.dart';
import 'package:fieldforce/features/shop/domain/usecases/add_product_to_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/clear_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/create_employee_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_current_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_order_by_id_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_orders_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_trading_point_orders_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_employee_trading_points_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/perform_protobuf_sync_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/remove_from_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/retry_order_submission_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/submit_order_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_categories_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_outlet_prices_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_region_products_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_region_stock_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_trading_points_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_warehouses_only_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_item_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_stock_item_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_order_state_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/orders_bloc.dart';
import 'package:get_it/get_it.dart';

void registerShopDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryDrift(getIt<AppDatabase>(), getIt<ProductRepository>()),
    )
    ..registerLazySingleton<StockItemRepository>(
      () => DriftStockItemRepository(),
    )
    ..registerLazySingleton<WarehouseRepository>(
      () => DriftWarehouseRepository(),
    )
    ..registerLazySingleton<WarehouseFilterService>(
      () => WarehouseFilterService(warehouseRepository: getIt<WarehouseRepository>()),
    )
    ..registerLazySingleton<CategoryTreeCacheService>(
      () => CategoryTreeCacheService(),
    )
    ..registerLazySingleton<JobQueueRepository<OrderSubmissionJob>>(
      () => OrderJobRepositoryImpl(getIt<AppDatabase>()),
    )
    ..registerLazySingleton<OrderApiService>(
      () => MockOrderApiService(),
    )
    ..registerLazySingleton<OrderSubmissionService>(
      () => OrderSubmissionService(apiService: getIt<OrderApiService>()),
    )
    ..registerLazySingleton<JobQueueService<OrderSubmissionJob>>(
      () => OrderSubmissionQueueService(
        repository: getIt<JobQueueRepository<OrderSubmissionJob>>(),
        orderRepository: getIt<OrderRepository>(),
        submissionService: getIt<OrderSubmissionService>(),
      ),
    )
    ..registerLazySingleton<RetryOrderSubmissionUseCase>(
      () => RetryOrderSubmissionUseCase(
        orderRepository: getIt<OrderRepository>(),
        queueService: getIt<JobQueueService<OrderSubmissionJob>>(),
      ),
    )
    ..registerLazySingleton<OrderSubmissionQueueTrigger>(
      () => ConnectivityOrderSubmissionQueueTrigger(
        connectivity: getIt<Connectivity>(),
        queueService: getIt<JobQueueService<OrderSubmissionJob>>(),
      ),
    )
    ..registerLazySingleton<TradingPointMapFactory>(
      () => DefaultTradingPointMapFactory(),
    )
    ..registerLazySingleton<RegionalSyncService>(
      () => RegionalSyncService(baseUrl: AppConfig.apiBaseUrl),
    )
    ..registerLazySingleton<StockSyncService>(
      () => StockSyncService(baseUrl: AppConfig.apiBaseUrl),
    )
    ..registerLazySingleton<OutletPricingSyncService>(
      () => OutletPricingSyncService(baseUrl: AppConfig.apiBaseUrl),
    )
    ..registerLazySingleton<WarehouseSyncService>(
      () => WarehouseSyncService(baseUrl: AppConfig.apiBaseUrl),
    )
    ..registerLazySingleton<ProtobufSyncRepository>(
      () => ProtobufSyncRepository(),
    )
    ..registerLazySingleton<ProtobufSyncCoordinator>(
      () => ProtobufSyncCoordinator(
        regionalSyncService: getIt<RegionalSyncService>(),
        stockSyncService: getIt<StockSyncService>(),
        outletPricingSyncService: getIt<OutletPricingSyncService>(),
        warehouseSyncService: getIt<WarehouseSyncService>(),
        syncRepository: getIt<ProtobufSyncRepository>(),
        productRepository: getIt<ProductRepository>(),
        stockItemRepository: getIt<StockItemRepository>(),
        warehouseRepository: getIt<WarehouseRepository>(),
        categoryTreeCacheService: getIt<CategoryTreeCacheService>(),
      ),
    )
    ..registerLazySingleton<ProductParsingService>(
      () => ProductParsingService(),
    )
    ..registerLazySingleton<CreateOrderUseCase>(
      () => CreateOrderUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<AddProductToOrderUseCase>(
      () => AddProductToOrderUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<UpdateOrderStateUseCase>(
      () => UpdateOrderStateUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<GetCurrentCartUseCase>(
      () => GetCurrentCartUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<SearchProductsUseCase>(
      () => SearchProductsUseCase(getIt<ProductRepository>()),
    )
    ..registerLazySingleton<UpdateCartItemUseCase>(
      () => UpdateCartItemUseCase(
        getIt<OrderRepository>(),
        getIt<StockItemRepository>(),
      ),
    )
    ..registerLazySingleton<UpdateCartStockItemUseCase>(
      () => UpdateCartStockItemUseCase(
        getIt<OrderRepository>(),
        getIt<StockItemRepository>(),
      ),
    )
    ..registerLazySingleton<RemoveFromCartUseCase>(
      () => RemoveFromCartUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<UpdateCartUseCase>(
      () => UpdateCartUseCase(
        getIt<OrderRepository>(),
        getIt<StockItemRepository>(),
      ),
    )
    ..registerLazySingleton<ClearCartUseCase>(
      () => ClearCartUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<SubmitOrderUseCase>(
      () => SubmitOrderUseCase(
        orderRepository: getIt<OrderRepository>(),
        queueService: getIt<JobQueueService<OrderSubmissionJob>>(),
      ),
    )
    ..registerLazySingleton<CreateEmployeeUseCase>(
      () => CreateEmployeeUseCase(getIt<EmployeeRepository>()),
    )
    ..registerLazySingleton<GetOrdersUseCase>(
      () => GetOrdersUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<GetOrderByIdUseCase>(
      () => GetOrderByIdUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<GetTradingPointOrdersUseCase>(
      () => GetTradingPointOrdersUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<GetEmployeeTradingPointsUseCase>(
      () => GetEmployeeTradingPointsUseCase(getIt<TradingPointRepository>()),
    )
    ..registerLazySingleton<PerformProtobufSyncUseCase>(
      () => PerformProtobufSyncUseCase(getIt<ProtobufSyncCoordinator>()),
    )
    ..registerLazySingleton<SyncWarehousesOnlyUseCase>(
      () => SyncWarehousesOnlyUseCase(
        warehouseSyncService: getIt<WarehouseSyncService>(),
        warehouseRepository: getIt<WarehouseRepository>(),
      ),
    )
    ..registerLazySingleton<SyncTradingPointsUseCase>(
      () => SyncTradingPointsUseCase(getIt<TradingPointSyncService>()),
    )
    ..registerLazySingleton<SyncCategoriesUseCase>(
      () => SyncCategoriesUseCase(
        sessionManager: getIt<SessionManager>(),
        categoryRepository: getIt<CategoryRepository>(),
      ),
    )
    ..registerLazySingleton<SyncRegionProductsUseCase>(
      () => SyncRegionProductsUseCase(getIt<ProtobufSyncCoordinator>()),
    )
    ..registerLazySingleton<SyncRegionStockUseCase>(
      () => SyncRegionStockUseCase(getIt<ProtobufSyncCoordinator>()),
    )
    ..registerLazySingleton<SyncOutletPricesUseCase>(
      () => SyncOutletPricesUseCase(getIt<ProtobufSyncCoordinator>()),
    )
    ..registerLazySingleton<IsolateSyncManager>(
      () => IsolateSyncManager(
        productRepository: getIt<ProductRepository>(),
        stockItemRepository: getIt<StockItemRepository>(),
        categoryRepository: getIt<CategoryRepository>(),
        productsApiUrl: AppConfig.productsApiUrl,
        categoriesApiUrl: AppConfig.categoriesApiUrl,
        sessionManager: getIt<SessionManager>(),
      ),
    )
    ..registerLazySingleton<ProductSyncServiceImpl>(
      () => ProductSyncServiceImpl(
        sessionManager: getIt<SessionManager>(),
        isolateManager: getIt<IsolateSyncManager>(),
      ),
    )
    ..registerLazySingleton<CartBloc>(
      () => CartBloc(
        getCurrentCartUseCase: getIt<GetCurrentCartUseCase>(),
        updateCartItemUseCase: getIt<UpdateCartItemUseCase>(),
        updateCartStockItemUseCase: getIt<UpdateCartStockItemUseCase>(),
        removeFromCartUseCase: getIt<RemoveFromCartUseCase>(),
        updateCartUseCase: getIt<UpdateCartUseCase>(),
        clearCartUseCase: getIt<ClearCartUseCase>(),
        submitOrderUseCase: getIt<SubmitOrderUseCase>(),
      ),
    )
    ..registerFactory<OrdersBloc>(
      () => OrdersBloc(
        getOrdersUseCase: getIt<GetOrdersUseCase>(),
        getOrderByIdUseCase: getIt<GetOrderByIdUseCase>(),
        retryOrderSubmissionUseCase: getIt<RetryOrderSubmissionUseCase>(),
      ),
    );
}
