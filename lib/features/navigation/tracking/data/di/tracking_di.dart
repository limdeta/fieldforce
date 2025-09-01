import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/app/database/repositories/user_track_repository_drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';

/// Dependency Injection для Tracking feature
/// 
/// Регистрирует все зависимости для работы с GPS треками:
/// - Repository
/// - Services
class TrackingDI {
  
  /// Регистрация всех зависимостей
  static void registerDependencies() {
    final GetIt getIt = GetIt.instance;
    
    // =====================================================
    // DATA LAYER - Слой данных
    // =====================================================
    
    // Repository - реализация через Drift (использует общую базу)
    if (!getIt.isRegistered<UserTrackRepositoryDrift>()) {
      getIt.registerLazySingleton<UserTrackRepositoryDrift>(
        () => UserTrackRepositoryDrift(
          getIt<AppDatabase>(),
          getIt<EmployeeRepositoryDrift>(),
        ),
      );
    }
  }
  
  /// Выгрузка зависимостей
  static void unregisterDependencies() {
    final GetIt getIt = GetIt.instance;
    
    if (getIt.isRegistered<UserTrackRepository>()) {
      getIt.unregister<UserTrackRepository>();
    }
  }
}
