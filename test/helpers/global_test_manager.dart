import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/di/test_service_locator.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:path/path.dart' as p;

const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
const MethodChannel connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');

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
    // Ensure Flutter bindings are initialized for MethodChannel mocking
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    final binaryMessenger = binding.defaultBinaryMessenger;

    // Mock path_provider for tests so AppDatabase can resolve a file-backed DB
    binaryMessenger.setMockMethodCallHandler(pathProviderChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        // Return a String path (not a Map) so the path_provider platform interface can
        // construct a Directory from it. Use the current working directory so the
        // DB file is visible in the repo workspace.
        return Directory.current.path;
      }
      return null;
    });

    binaryMessenger.setMockMethodCallHandler(connectivityChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return <String>[ConnectivityResult.wifi.name];
      }
      return null;
    });

    await setupTestServiceLocator(startBackgroundWorkers: false);
    _isInitialized = true;
  }
  
  Future<void> disposeGlobal() async {
    if (!_isInitialized) return;
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final binaryMessenger = binding.defaultBinaryMessenger;

  // Remove the mocked handler for path_provider
  binaryMessenger.setMockMethodCallHandler(pathProviderChannel, null);
  binaryMessenger.setMockMethodCallHandler(connectivityChannel, null);

    _isInitialized = false;
  }
  
  Future<void> clearDatabase() async {
    // If AppDatabase is registered, close it to ensure background connections
    // are torn down before we delete the file.
    final gi = GetIt.instance;
    if (gi.isRegistered<AppDatabase>()) {
      final db = gi<AppDatabase>();
      await db.close();
    }

    // Delete the physical DB file to ensure a fully fresh database.
    final dbFile = p.join(Directory.current.path, AppConfig.databaseName);
    final file = File(dbFile);
    if (await file.exists()) {
      await file.delete();
    }

    // Reset GetIt and recreate test registrations.
    await GetIt.instance.reset();
    await setupTestServiceLocator(startBackgroundWorkers: false);
  }
  
  bool get isInitialized => _isInitialized;
}
