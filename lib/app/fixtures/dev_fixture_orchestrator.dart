import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/usecases/create_work_day_usecase.dart';
import 'package:fieldforce/app/fixtures/route_fixture_service.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/features/navigation/tracking/data/fixtures/track_fixtures.dart';
import 'package:fieldforce/features/shop/data/fixtures/trading_points_fixture_service.dart';
import 'package:fieldforce/features/shop/data/fixtures/category_fixture_service.dart';
import 'package:fieldforce/features/shop/data/fixtures/product_fixture_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

/// Центральный оркестратор для создания всех dev фикстур
class DevFixtureOrchestrator {
  final UserFixture _userFixture;
  final RouteFixtureService _routeFixtureService;
  final TradingPointsFixtureService _tradingPointsFixture;
  final CategoryFixtureService _categoryFixture;
  final ProductFixtureService _productFixture;
  final CreateWorkDayUseCase _createWorkDayUseCase;

  DevFixtureOrchestrator(
      this. _userFixture,
      this._routeFixtureService,
      this._tradingPointsFixture,
      this._categoryFixture,
      this._productFixture,
      this._createWorkDayUseCase,
      );

  /// Создает полный набор dev данных
  Future<void> createFullDevDataset() async {
    // Добавляем небольшую задержку для обеспечения готовности assets
    await Future.delayed(const Duration(milliseconds: 100));

    await _clearAllData();
    final user = await _userFixture.getBasicUser(userData: _userFixture.saddam);
    await createScenarioWithUser(user);
    print("Загрузил все dev фикстуры");
  }

  Future<void> _clearAllData() async {
    final database = GetIt.instance<AppDatabase>();
    await database.customStatement('PRAGMA foreign_keys = OFF');
    for (final table in database.allTables) {
      await database.delete(table).go();
    }
    await database.customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> createScenarioWithUser(AppUser user) async {
  try {
      // Привязываем точки к сотруднику
      await _tradingPointsFixture.assignTradingPointsToEmployee(user.employee);

      // 0. Категории товаров
      await _categoryFixture.loadCategories(fixtureType: FixtureType.full);

      // 0.1. Продукты
      final productsResult = await _productFixture.loadProducts(ProductFixtureType.full);
      if (productsResult.isLeft()) {
        throw StateError('Failed to load products: ${productsResult.fold((l) => l, (r) => '')}');
      }
      final products = productsResult.fold((l) => throw StateError(l.toString()), (r) => r);
      // Сохраняем продукты в базу данных
      final productRepository = GetIt.instance<ProductRepository>();
      await productRepository.saveProducts(products);

      // 1. Маршруты
      final yesterdayRoute = await unwrapOrThrow(
          _routeFixtureService.createYesterdayRoute(user.employee),
          'Yesterday Route creation failed'
      );

      final todayRoute = await unwrapOrThrow(
          _routeFixtureService.createTodayRoute(user.employee),
          'Today Route creation failed'
      );

      // 2. Треки
      final todayTrack = await TrackFixtures.createTodayTrack(
          user: user, route: todayRoute
      );

      // 3. WorkDay
      _createWorkDayUseCase.call(
        user: user,
        route: yesterdayRoute,
        track: null,
        date: DateTime.now().subtract(const Duration(days: 1)),
      );

      _createWorkDayUseCase.call(
        user: user,
        track: todayTrack,
        route: todayRoute,
        date: DateTime.now(),
      );

      // Обновляем количество продуктов в категориях после загрузки всех данных
      final categoryRepository = GetIt.instance<CategoryRepository>();
      await categoryRepository.updateCategoryCounts();
    } catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'DevFixtureOrchestrator',
        context: ErrorDescription('Ошибка при создании сценария пользователя'),
      ));
      rethrow;
    }
  }
}

