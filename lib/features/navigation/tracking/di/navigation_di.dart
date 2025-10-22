import 'package:fieldforce/app/di/route_di.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/sync_log_repository.dart';
import 'package:fieldforce/app/database/repositories/user_track_repository_drift.dart';
import 'package:fieldforce/app/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/domain/usecases/load_user_routes_usecase.dart';
import 'package:fieldforce/app/presentation/bloc/data_sync/data_sync_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/device_orientation_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_track_for_date_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_tracks_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/user_tracks_bloc.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_categories_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_outlet_prices_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_region_products_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_region_stock_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_trading_points_usecase.dart';
import 'package:get_it/get_it.dart';

Future<void> registerNavigationDependencies(
  GetIt getIt, {
  required GpsMode gpsMode,
}) async {
  RouteDI.registerDependencies();

  getIt
    ..registerLazySingleton<UserTrackRepository>(
      () => UserTrackRepositoryDrift(
        getIt<AppDatabase>(),
        getIt<EmployeeRepositoryDrift>(),
      ),
    )
    ..registerLazySingleton<SyncLogRepository>(
      () => SyncLogRepository(getIt<AppDatabase>()),
    )
    ..registerLazySingleton<DeviceOrientationService>(
      () => createDeviceOrientationService(),
      dispose: (service) => service.dispose(),
    )
    ..registerLazySingleton<DataSyncBloc>(
      () => DataSyncBloc(
        syncTradingPointsUseCase: getIt<SyncTradingPointsUseCase>(),
        syncCategoriesUseCase: getIt<SyncCategoriesUseCase>(),
        syncRegionProductsUseCase: getIt<SyncRegionProductsUseCase>(),
        syncRegionStockUseCase: getIt<SyncRegionStockUseCase>(),
        syncOutletPricesUseCase: getIt<SyncOutletPricesUseCase>(),
        syncLogRepository: getIt<SyncLogRepository>(),
      )..add(const DataSyncInitialize()),
      dispose: (bloc) => bloc.close(),
    )
    ..registerLazySingleton<TrackManager>(
      () => TrackManager(getIt<UserTrackRepository>()),
    )
    ..registerLazySingleton<LocationTrackingServiceBase>(
      () => LocationTrackingService(
        getIt<GpsDataManager>(),
        getIt<TrackManager>(),
        getIt<DeviceOrientationService>(),
      ),
    )
    ..registerLazySingleton<TrackingBloc>(() => TrackingBloc())
    ..registerLazySingleton<UserTracksBloc>(() => UserTracksBloc())
    ..registerLazySingleton<GetUserTrackForDateUseCase>(
      () => GetUserTrackForDateUseCase(
        userTrackRepository: getIt<UserTrackRepository>(),
      ),
    )
    ..registerLazySingleton<GetUserTracksUseCase>(
      () => GetUserTracksUseCase(getIt<UserTrackRepository>()),
    )
    ..registerLazySingleton<LoadUserRoutesUseCase>(
      () => LoadUserRoutesUseCase(getIt<RouteRepository>()),
    );

  final gpsManager = GpsDataManager();
  await gpsManager.initialize(mode: gpsMode);
  getIt.registerSingleton<GpsDataManager>(gpsManager);
}
