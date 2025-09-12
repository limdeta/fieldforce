import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/usecases/create_work_day_usecase.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/app/fixtures/route_fixture_service.dart';
import 'package:fieldforce/features/navigation/tracking/data/fixtures/track_fixtures.dart';
import 'package:fieldforce/features/shop/data/fixtures/trading_points_fixture_service.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

/// Центральный оркестратор для создания всех dev фикстур
class DevFixtureOrchestrator {
  final UserFixture _userFixture;
  final RouteFixtureService _routeFixtureService;
  final TradingPointsFixtureService _tradingPointsService;
  final CreateWorkDayUseCase _createWorkDayUseCase;

  DevFixtureOrchestrator(
      this. _userFixture,
      this._routeFixtureService,
      this._tradingPointsService,
      this._createWorkDayUseCase,
      );

  /// Создает полный набор dev данных
  Future<void> createFullDevDataset() async {
    await _clearAllData();
    await _tradingPointsService.createBaseTradingPoints();
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

