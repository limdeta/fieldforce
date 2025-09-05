import 'package:fieldforce/app/di/test_service_locator.dart';
import 'package:fieldforce/app/presentation/pages/trading_points_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/presentation/pages/main_menu_page.dart';
import 'package:fieldforce/app/presentation/pages/sales_rep_home/sales_rep_home_page.dart';
import 'package:fieldforce/app/presentation/pages/splash_page.dart';
import 'package:fieldforce/app/presentation/pages/login_page.dart';
import 'package:fieldforce/app/presentation/widgets/dev_data_loading_overlay.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'app/config/app_config.dart';
import 'app/di/service_locator.dart';
import 'app/fixtures/dev_fixture_orchestrator.dart';
import 'app/providers/selected_route_provider.dart';
import 'app/providers/work_day_provider.dart';
import 'features/navigation/tracking/presentation/providers/user_tracks_provider.dart';
import 'app/services/app_lifecycle_manager.dart';
import 'app/services/simple_update_service.dart';
import 'app/presentation/pages/routes_page.dart';
import 'features/shop/presentation/product_catalog_page.dart';
import 'features/shop/presentation/product_categories_page.dart';
import 'features/shop/presentation/promotions_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.configureFromArgs();

  if (AppConfig.isProd) {
    await setupServiceLocator();
  } else {
    print("Запускаем тестовый контейнер");
    await setupTestServiceLocator();
  }

  if (!AppConfig.isProd) {
    final orchestrator = DevFixtureOrchestratorFactory.create();
    await orchestrator.createFullDevDataset();
  }

  // Инициализируем менеджер жизненного цикла для GPS трекинга
  final lifecycleManager = GetIt.instance<AppLifecycleManager>();
  await lifecycleManager.initialize();

  runApp(const FieldforceApp());
}

class FieldforceApp extends StatelessWidget {
  const FieldforceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GetIt.instance<SelectedRouteProvider>()),
        ChangeNotifierProvider.value(value: GetIt.instance<UserTracksProvider>()),
        ChangeNotifierProvider(create: (_) => WorkDayProvider()),
      ],
      child: DevDataLoadingOverlay(
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
      ),
    );
  }
}
