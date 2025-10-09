import 'dart:io';

enum Environment {
  dev,
  prod,
  test,
}

class AppConfig {
  static Environment _environment = Environment.dev;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static bool get isDev => _environment == Environment.dev;
  static bool get isProd => _environment == Environment.prod;
  static bool get isTest => _environment == Environment.test;

  // Dev API host - используем localhost после adb reverse
  static String get _devApiHost {
    return 'localhost:8000';
  }

  // API Configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev-api.fieldforce.com';
      case Environment.prod:
        return 'https://api.instock-dv.ru/v1_api/';
      case Environment.test:
        return 'https://test-api.fieldforce.com';
    }
  }

    static String get tradingPointsApiUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://$_devApiHost/v1_api/trading-points';
      case Environment.prod:
        return 'https://api.instock-dv.ru/v1_api/trading-points';
      case Environment.test:
        return '';
    }
  }

  // Authentication API Configuration
  static String get authApiUrl {
    switch (_environment) {
      case Environment.dev:
        return ''; // Dev использует mock
      case Environment.prod:
        // return 'https://localhost:8000/v1_api/login';
        return 'https://api.instock-dv.ru/v1_api/login';
      case Environment.test:
        return ''; // Test использует mock
    }
  }

  // User Info API Configuration
  static String get userInfoApiUrl {
    switch (_environment) {
      case Environment.dev:
        return ''; // Dev использует mock
      case Environment.prod:
        // return 'https://localhost:8000/v1_api/users/me';
        return 'https://api.instock-dv.ru/v1_api/users/me';
      case Environment.test:
        return ''; // Test использует mock
    }
  }

  // Products API Configuration
  static String get productsApiUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://$_devApiHost/v1_api/products';
      case Environment.prod:
        return 'https://api.instock-dv.ru/v1_api/products';
      case Environment.test:
        return 'https://test-api.fieldforce.com/v1_api/products';
    }
  }

  // Categories API Configuration
  static String get categoriesApiUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://$_devApiHost/v1_api/categories';
      case Environment.prod:
        return 'https://api.instock-dv.ru/v1_api/categories';
      case Environment.test:
        return '';
    }
  }

    // ===== 🆕 PROTOBUF SYNC API CONFIGURATION =====
  
  // Mobile Sync Base URL (protobuf)
  static String get mobileSyncApiUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://$_devApiHost/v1_api/mobile-sync';
      case Environment.prod:
        return 'https://api.instock-dv.ru/v1_api/mobile-sync';
      case Environment.test:
        return 'http://localhost:8000/v1_api/mobile-sync';
    }
  }

  // Regional Sync (утром, 1 раз в день)
  static String regionalSyncUrl(String regionFiasId) {
    return '$mobileSyncApiUrl/regional/$regionFiasId';
  }

  // Regional Stock Sync (каждый час)
  static String regionalStockUrl(String regionFiasId) {
    return '$mobileSyncApiUrl/regional-stock/$regionFiasId';
  }

  // Outlet Pricing Sync (каждый час)
  static String outletPricingUrl(String outletVendorId) {
    return '$mobileSyncApiUrl/outlet-prices/$outletVendorId';
  }

  // Use mock authentication in dev/test modes
  static bool get useMockAuth => isDev || isTest;
  
  // Database Configuration
  static String get databaseName {
    switch (_environment) {
      case Environment.dev:
        return 'fieldforce_dev.db';
      case Environment.prod:
        return 'fieldforce.db';
      case Environment.test:
        return 'fieldforce_test.db';
    }
  }
  
  // Feature Flags
  static bool get useMockData => isDev;
  static bool get enableDebugTools => isDev || isTest;
  static bool get enableDetailedLogging => !isProd;
  static bool get checkForUpdates => isDev; // Включено только для dev пока
  static bool get enableTileCaching => true; // Включение кеширования тайлов карты (экономит трафик, ускоряет загрузку)
  
  // GPS Debug Flags 
  static bool get enableGpsDebugMode => const String.fromEnvironment('GPS_DEBUG', defaultValue: 'false') == 'true';
  static bool get showTrackingDebugInfo => enableGpsDebugMode || isDev;
  

  static void configureFromArgs() {
    // Автоматически определяем тестовое окружение
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _environment = Environment.test;
      return;
    }

    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    
    switch (envString.toLowerCase()) {
      case 'prod':
      case 'production':
        _environment = Environment.prod;
        break;
      case 'test':
      case 'testing':
        _environment = Environment.test;
        break;
      case 'dev':
      case 'development':
      default:
        _environment = Environment.dev;
        break;
    }
  }

  // Helper methods for debugging
  static void printConfig() {
    print('=== App Configuration ===');
    print('Environment: $_environment');
    print('API Base URL: $apiBaseUrl');
    print('Auth API URL: $authApiUrl');
    print('User Info API URL: $userInfoApiUrl');
    print('Products API URL: $productsApiUrl');
  print('Trading Points API URL: $tradingPointsApiUrl');
    print('Database Name: $databaseName');
    print('Use Mock Data: $useMockData');
    print('Use Mock Auth: $useMockAuth');
    print('Debug Tools: $enableDebugTools');
    print('Detailed Logging: $enableDetailedLogging');
    print('Check for Updates: $checkForUpdates');
    print('========================');
  }
}
