import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/di/test_service_locator.dart';
import 'package:fieldforce/app/database/app_database.dart';

class GlobalTestManager {
  static GlobalTestManager? _instance;
  static GlobalTestManager get instance => _instance ??= GlobalTestManager._();
  
  GlobalTestManager._();
  
  bool _isInitialized = false;
  
  /// Статический метод для удобства
  static Future<void> initialize() async {
    await instance.initializeGlobal();
  }
  
  /// Статический метод для удобства
  static Future<void> cleanup() async {
    await instance.disposeGlobal();
  }
  
  Future<void> initializeGlobal() async {
    if (_isInitialized) return;
    
    await setupTestServiceLocator();
    _isInitialized = true;
  }
  
  Future<void> disposeGlobal() async {
    if (!_isInitialized) return;
    _isInitialized = false;
  }
  
  Future<void> clearDatabase() async {
    final database = GetIt.instance<AppDatabase>();
    await database.transaction(() async {
      // Динамическая очистка всех таблиц
      for (final table in database.allTables) {
        await database.delete(table).go();
      }
    });
  }
  
  bool get isInitialized => _isInitialized;
}
