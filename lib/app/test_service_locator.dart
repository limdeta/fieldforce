import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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

/// Тестовый service locator для интеграционных тестов
/// 
/// Переиспользует ту же структуру что и основной service locator,
/// но настроен для тестовой среды (in-memory база, моки и т.д.)
class TestServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static GetIt get instance => _getIt;
  
  /// Настраивает все зависимости для тестов
  static Future<void> setup() async {
    // Очищаем предыдущие регистрации
    await _getIt.reset();
    
    // ВАЖНО: Устанавливаем тестовое окружение для правильной базы данных
    AppConfig.setEnvironment(Environment.test);
    
    print('🧪 Настройка тестового окружения...');
    print('📁 База данных: ${AppConfig.databaseName}');
    
    // Регистрируем основные сервисы
    _registerCoreServices();
    _registerRepositories();
    _registerUseCases();
    _registerProviders();
    _registerBlocs();
    
    print('✅ TestServiceLocator настроен для ${AppConfig.environment}');
  }
  
  /// Очищает все зависимости после тестов
  static Future<void> tearDown() async {
    await _getIt.reset();
    print('🧹 TestServiceLocator очищен');
  }
  
  static void _registerCoreServices() {
    _getIt.registerLazySingleton<UserPreferencesService>(
      () {
        final service = UserPreferencesService();
        service.initialize();
        return service;
      },
    );
    
    _getIt.registerLazySingleton<SelectedRouteProvider>(() => SelectedRouteProvider());
    
    // ✅ Используем in-memory базу для тестов с отключенным логированием
    _getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.forTesting(
      DatabaseConnection(
        NativeDatabase.memory(logStatements: false),
        closeStreamsSynchronously: true,
      ),
    ));
    
    _getIt.registerLazySingleton<SessionRepository>(() => SessionRepositoryImpl());
    _getIt.registerLazySingleton<OsrmPathPredictionService>(() => OsrmPathPredictionService());
    _getIt.registerLazySingleton<LocationTrackingService>(() => LocationTrackingService());
    _getIt.registerLazySingleton<AppLifecycleManager>(() => AppLifecycleManager());
    
    _getIt.registerLazySingleton<AppUserLoginService>(() => AppUserLoginService());
    _getIt.registerLazySingleton<AppUserLogoutService>(() => AppUserLogoutService());
    _getIt.registerLazySingleton<SimpleUpdateService>(() => SimpleUpdateService());
  }
  
  static void _registerRepositories() {
    _getIt.registerLazySingleton<UserRepositoryImpl>(
      () => UserRepositoryImpl(database: _getIt()),
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
    
    _getIt.registerLazySingleton<UserTrackRepository>(
      () => UserTrackRepositoryDrift(
        _getIt<AppDatabase>(), 
        _getIt<EmployeeRepositoryDrift>(),
      ),
    );
    
    // Регистрируем Route зависимости
    RouteDI.registerDependencies();
  }
  
  static void _registerUseCases() {
    _getIt.registerLazySingleton<AuthenticationService>(
      () => AuthenticationService(
        userRepository: _getIt(),
        sessionRepository: _getIt(),
      ),
    );
    
    _getIt.registerLazySingleton<UserFixtureService>(
      () => UserFixtureService(_getIt()),
    );
    
    _getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(_getIt()),
    );
    
    _getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(authenticationService: _getIt()),
    );
    
    _getIt.registerLazySingleton<GetCurrentSessionUseCase>(
      () => GetCurrentSessionUseCase(sessionRepository: _getIt()),
    );
    
    _getIt.registerLazySingleton<GetEmployeeTradingPointsUseCase>(
      () => GetEmployeeTradingPointsUseCase(_getIt<TradingPointRepository>()),
    );
    
    _getIt.registerLazySingleton<GetUserTracksUseCase>(
      () => GetUserTracksUseCase(_getIt<UserTrackRepository>()),
    );
    
    _getIt.registerLazySingleton<LoadUserRoutesUseCase>(
      () => LoadUserRoutesUseCase(_getIt<RouteRepository>()),
    );
  }
  
  static void _registerProviders() {
    _getIt.registerLazySingleton<UserTracksProvider>(
      () => UserTracksProvider(_getIt<GetUserTracksUseCase>()),
    );
  }
  
  static void _registerBlocs() {
    _getIt.registerFactory<AuthenticationBloc>(
      () => AuthenticationBloc(
        loginUseCase: _getIt<LoginUseCase>(),
        logoutUseCase: _getIt<LogoutUseCase>(),
        getCurrentSessionUseCase: _getIt<GetCurrentSessionUseCase>(),
      ),
    );
  }
}
