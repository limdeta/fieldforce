// ignore_for_file: avoid_print
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/app/domain/usecases/create_work_day_usecase.dart';
import 'package:fieldforce/app/fixtures/route_fixture_service.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/features/navigation/tracking/data/fixtures/track_fixtures.dart';
import 'package:fieldforce/features/shop/data/fixtures/trading_points_fixture_service.dart';
import 'package:fieldforce/features/shop/data/fixtures/category_fixture_service.dart';
import 'package:fieldforce/features/shop/data/fixtures/product_fixture_service.dart';
import 'package:fieldforce/features/shop/data/fixtures/order_fixture_service.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/app/services/category_tree_cache_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
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
  final OrderFixtureService _orderFixture;
  final CreateWorkDayUseCase _createWorkDayUseCase;

  DevFixtureOrchestrator(
      this. _userFixture,
      this._routeFixtureService,
      this._tradingPointsFixture,
      this._categoryFixture,
      this._productFixture,
      this._orderFixture,
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

      // Устанавливаем selectedTradingPoint для пользователя
      await _selectFirstTradingPointForUser(user);

      // 0. Категории товаров
      await _categoryFixture.loadCategories();

      // 0.1. Продукты
      final productsResult = await _productFixture.loadProducts(ProductFixtureType.full);
      final products = productsResult.fold((l) => throw StateError(l.toString()), (r) => r);
      final productRepository = GetIt.instance<ProductRepository>();
      await productRepository.saveProducts(products);
   
      await _productFixture.createStockItemsForProducts(products);
      
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

      // 4. Заказы - используем репозиторий для получения торговых точек и сотрудника с корректными ID
      final employeeRepository = GetIt.instance<EmployeeRepository>();
      final tradingPointRepository = GetIt.instance<TradingPointRepository>();
      
      // Получаем сотрудника из базы с корректным ID
      final employeeResult = await employeeRepository.getById(user.employee.id);
      final employee = employeeResult.fold(
        (failure) {
          return user.employee; // fallback к оригинальному
        },
        (emp) => emp, // используем из базы
      );
      
      // Получаем торговые точки из базы с корректными ID
      final tradingPointsResult = await tradingPointRepository.getEmployeePoints(employee);
      final tradingPoints = tradingPointsResult.fold(
        (failure) {
          return <TradingPoint>[];
        },
        (points) => points,
      );
      
      if (tradingPoints.isNotEmpty) {
        await _orderFixture.createFixtureOrders(
          employee: employee,
          tradingPoints: tradingPoints,
        );
      } else {
        debugPrint('❌ Нет торговых точек - пропускаем создание заказов');
      }

      // Обновляем количество продуктов в категориях после загрузки всех данных
  final categoryRepository = GetIt.instance<CategoryRepository>();
  await categoryRepository.updateCategoryCounts();

  final categoryCacheService = GetIt.instance<CategoryTreeCacheService>();
  await categoryCacheService.refreshCurrentRegion();
      
      // Автоматически выбираем первую доступную торговую точку
      await _selectFirstTradingPointForUser(user);
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

  /// Устанавливает первую доступную торговую точку как выбранную для пользователя
  Future<void> _selectFirstTradingPointForUser(AppUser user) async {
    try {
      final tradingPointRepository = GetIt.instance<TradingPointRepository>();
      final appUserRepository = GetIt.instance<AppUserRepository>();
      
      // Получаем назначенные торговые точки из базы
      final tradingPointsResult = await tradingPointRepository.getEmployeePoints(user.employee);
      
      await tradingPointsResult.fold(
        (failure) async {
          debugPrint('❌ Не удалось получить торговые точки для выбора: $failure');
        },
        (tradingPoints) async {
          if (tradingPoints.isNotEmpty) {
            // Приоритезируем выбор торговой точки: P3V > K3V > M3V
            TradingPoint firstPoint;
            final p3vPoints = tradingPoints.where((tp) => tp.region == 'P3V').toList();
            final k3vPoints = tradingPoints.where((tp) => tp.region == 'K3V').toList();
            
            if (p3vPoints.isNotEmpty) {
              firstPoint = p3vPoints.first;
            } else if (k3vPoints.isNotEmpty) {
              firstPoint = k3vPoints.first;
            } else {
              firstPoint = tradingPoints.first;
            }
            
            debugPrint('📍 Выбираем торговую точку: ${firstPoint.name} (${firstPoint.region}, ID: ${firstPoint.id})');
            
            // Обновляем пользователя с выбранной торговой точкой
            final updatedUser = user.selectTradingPoint(firstPoint);
            
            // Сохраняем в базу данных
            final updateResult = await appUserRepository.updateAppUser(updatedUser);
            updateResult.fold(
              (failure) => debugPrint('❌ Ошибка сохранения selectedTradingPoint: $failure'),
              (savedUser) => debugPrint('✅ Торговая точка сохранена в базе данных'),
            );
          } else {
            debugPrint('⚠️ Нет доступных торговых точек для выбора');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Ошибка установки выбранной торговой точки: $e');
    }
  }


}

