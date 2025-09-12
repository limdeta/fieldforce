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

  // API Configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev-api.fieldforce.com';
      case Environment.prod:
        return 'https://api.fieldforce.com';
      case Environment.test:
        return 'https://test-api.fieldforce.com';
    }
  }
  
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
    print('Database Name: $databaseName');
    print('Use Mock Data: $useMockData');
    print('Debug Tools: $enableDebugTools');
    print('Detailed Logging: $enableDetailedLogging');
    print('Check for Updates: $checkForUpdates');
    print('========================');
  }
}
