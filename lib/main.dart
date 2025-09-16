import 'package:fieldforce/app/di/test_service_locator.dart' as test_di;
import 'package:fieldforce/features/shop/presentation/trading_points_list_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/presentation/pages/main_menu_page.dart';
import 'package:fieldforce/app/presentation/pages/sales_rep_home/sales_rep_home_page.dart';
import 'package:fieldforce/app/presentation/pages/splash_page.dart';
import 'package:fieldforce/app/presentation/pages/login_page.dart';
import 'package:fieldforce/app/presentation/widgets/dev_data_loading_overlay.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:logging/logging.dart';
import 'app/config/app_config.dart';
import 'app/di/service_locator.dart' as prod_di;
import 'app/fixtures/dev_fixture_orchestrator.dart';
import 'app/services/app_lifecycle_manager.dart';
import 'app/services/simple_update_service.dart';
import 'app/presentation/pages/routes_page.dart';
import 'features/shop/presentation/product_catalog_page.dart';
import 'features/shop/presentation/product_categories_page.dart';
import 'features/shop/presentation/promotions_page.dart';
import 'app/fixtures/user_fixture.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка логирования
  Logger.root.level = Level.SEVERE;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  AppConfig.configureFromArgs();

  if (AppConfig.isProd) {
    await prod_di.setupServiceLocator();
    final userFixture = GetIt.instance<UserFixture>();
    await userFixture.getBasicUser(userData: userFixture.admin);
  } else {
    await test_di.setupTestServiceLocator();
  }

  if (AppConfig.isDev) {
    // Небольшая задержка для обеспечения готовности assets
    await Future.delayed(const Duration(milliseconds: 200));

    final orchestrator = GetIt.instance<DevFixtureOrchestrator>();
    await orchestrator.createFullDevDataset();
  }

  // Инициализируем менеджер жизненного цикла для GPS трекинга
  final lifecycleManager = GetIt.instance<AppLifecycleManager>();
  await lifecycleManager.initialize();

  runApp(const FieldforceApp());
}

class FieldforceApp extends StatelessWidget {
  final String initialRoute;
  const FieldforceApp({super.key,  this.initialRoute = '/'});

  @override
  Widget build(BuildContext context) {
    return DevDataLoadingOverlay(
      child: UpgraderWrapper(
        child: MaterialApp(
          title: 'fieldforce',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/sales-home': (context) => SalesRepHomePage(
              gpsDataManager: GetIt.instance<GpsDataManager>(),
            ),
            '/menu': (context) => const MainMenuPage(),
            '/routes': (context) => const RoutesPage(),
            '/outlets': (context) => const TradingPointsListPage(),
            '/products/catalog': (context) => const ProductCatalogPage(),
            '/products/categories': (context) => const ProductCategoriesPage(),
            '/products/promotions': (context) => const PromotionsPage(),
          },
        ),
      ),
    );
  }
}
