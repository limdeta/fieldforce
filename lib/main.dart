import 'package:fieldforce/app/di/test_service_locator.dart' as test_di;
import 'package:fieldforce/features/shop/presentation/pages/trading_points_list_page.dart';
import 'package:fieldforce/features/shop/presentation/pages/cart_page.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/presentation/pages/main_menu_page.dart';
import 'package:fieldforce/app/presentation/pages/sales_rep_home/sales_rep_home_page.dart';
import 'package:fieldforce/app/presentation/pages/splash_page.dart';
import 'package:fieldforce/app/presentation/pages/login_page.dart';
import 'package:fieldforce/app/presentation/widgets/dev_data_loading_overlay.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/app/services/category_tree_cache_service.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'app/config/app_config.dart';
import 'app/di/service_locator.dart' as prod_di;
import 'app/fixtures/dev_fixture_orchestrator.dart';
import 'app/theme/app_theme.dart';
import 'app/services/app_lifecycle_manager.dart';
import 'app/services/update_service.dart';
import 'app/services/upgrader_wrapper.dart';
import 'app/presentation/pages/routes_page.dart';
import 'app/presentation/pages/profile_page.dart';
import 'app/presentation/pages/data_page.dart';
import 'app/presentation/pages/sync_log_page.dart';
import 'app/presentation/pages/dashboard_page.dart';
import 'app/presentation/pages/settings_page.dart';
import 'features/shop/presentation/pages/catalog_router_page.dart';
import 'features/shop/presentation/pages/product_catalog_split_page.dart';
import 'features/shop/presentation/pages/product_categories_page.dart';
import 'features/shop/presentation/pages/product_search_page.dart';
import 'features/shop/presentation/pages/orders_page.dart';
import 'features/shop/presentation/pages/promotions_page.dart';

/// Удаляет старую базу данных в dev режиме для чистого старта
Future<void> _cleanDatabaseInDevMode() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, AppConfig.databaseName));
    
    if (await dbFile.exists()) {
      await dbFile.delete();
      debugPrint('🗑️ Старая база данных удалена: ${dbFile.path}');
    } else {
      debugPrint('✅ База данных не существует, создастся новая');
    }
  } catch (e) {
    debugPrint('⚠️ Ошибка при удалении базы данных: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  hierarchicalLoggingEnabled = true;
  
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      debugPrint('ERROR: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('STACK: ${record.stackTrace}');
    }
  });

  AppConfig.configureFromArgs();

  // В dev режиме удаляем старую базу данных для чистого старта
  if (AppConfig.isDev) {
    await _cleanDatabaseInDevMode();
  }

  if (AppConfig.isProd) {
    await prod_di.setupServiceLocator();
  } else {
    await test_di.setupTestServiceLocator();
  }

  if (AppConfig.isDev) {
    // Небольшая задержка для обеспечения готовности assets
    await Future.delayed(const Duration(milliseconds: 200));

    final orchestrator = GetIt.instance<DevFixtureOrchestrator>();
    await orchestrator.createFullDevDataset();
    
    // Фоновое прогревание кеша категорий после создания фикстур
    _warmupCategoryCache();
  } else {
    // В prod режиме прогреваем кеш сразу после setup DI
    _warmupCategoryCache();
  }

  // Инициализируем менеджер жизненного цикла для GPS трекинга
  final lifecycleManager = GetIt.instance<AppLifecycleManager>();
  await lifecycleManager.initialize();


  await UpdateService.initialize();

  runApp(const FieldforceApp());
}

/// Фоновое прогревание кеша дерева категорий
/// 
/// Выполняется асинхронно (fire-and-forget) чтобы не блокировать старт приложения.
/// Когда пользователь откроет каталог, данные уже будут готовы.
void _warmupCategoryCache() {
  // Импортируем сервис только здесь, чтобы избежать циклических зависимостей
  final cacheService = GetIt.instance.get<CategoryTreeCacheService>();
  
  // Запускаем прогрев в фоне без ожидания
  cacheService.warmupCache().then((_) {
    debugPrint('✅ Фоновый прогрев кеша категорий завершён');
  }).catchError((e) {
    debugPrint('⚠️ Ошибка фонового прогрева кеша категорий: $e');
  });
}

class FieldforceApp extends StatelessWidget {
  final String initialRoute;
  const FieldforceApp({super.key,  this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return DevDataLoadingOverlay(
      child: UpgraderWrapper(
        child: BlocProvider<CartBloc>(
          create: (context) => GetIt.instance<CartBloc>(),
          child: MaterialApp(
            title: 'fieldforce',
            theme: AppTheme.lightTheme,
            initialRoute: '/',
            routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/sales-home': (context) => SalesRepHomePage(
              gpsDataManager: GetIt.instance<GpsDataManager>(),
            ),
            '/menu': (context) => const MainMenuPage(),
            '/dashboard': (context) => const DashboardPage(),
            '/routes': (context) => const RoutesPage(),
            '/profile': (context) => const ProfilePage(),
            '/outlets': (context) => const TradingPointsListPage(),
            '/products/catalog': (context) => const CatalogRouterPage(),
            '/products/catalog-split': (context) => const ProductCatalogSplitPage(),
            '/products/search': (context) => const ProductSearchPage(),
            '/products/categories': (context) => const ProductCategoriesPage(),
            '/products/promotions': (context) => const PromotionsPage(),
            '/cart': (context) => const CartPage(),
            '/orders': (context) => const OrdersPage(),
            '/data-sync': (context) => const DataPage(),
            '/settings': (context) => const SettingsPage(),
            '/sync-log': (context) => const SyncLogPage(),
          },
          ),
        ),
      ),
    );
  }
}
