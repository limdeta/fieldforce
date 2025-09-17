// dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/fixtures/dev_fixture_orchestrator.dart';
import 'package:fieldforce/features/shop/presentation/trading_points_list_page.dart';
import 'package:fieldforce/features/shop/presentation/trading_point_detail_page.dart';
import 'package:fieldforce/app/di/test_service_locator.dart' as test_di;
import './helpers/session_test_helper.dart' as h;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await test_di.setupTestServiceLocator();
    final orchestrator = GetIt.instance<DevFixtureOrchestrator>();
    await orchestrator.createFullDevDataset(); // Сначала фикстуры
    await h.ensureLoggedInAsDevUser(); // Потом session helper
  });

  testWidgets('Outlets page: search present, list populated, navigation works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const TradingPointsListPage(),
      ),
    );

    await tester.pumpAndSettle();

    // Проверяем что нет доменных ошибок
    expect(find.text('Не удалось получить сессию пользователя'), findsNothing);
    expect(find.text('Пользователь не найден в сессии'), findsNothing);
    expect(find.text('Ошибка'), findsNothing);
    expect(find.text('Торговые точки не найдены'), findsNothing);
    expect(find.text('Торговые точки не назначены'), findsNothing);

    // Ищем поисковое поле
    final searchFinder = find.byType(TextField);
    expect(searchFinder, findsOneWidget);

    // Должны быть карточки в списке
    final tileFinder = find.byType(ListTile);
    expect(tileFinder, findsAtLeastNWidgets(3));

    // Должны найти известный элемент в списке
    final knownName = 'ООО "Океан"';
    expect(find.text(knownName), findsOneWidget);

    // Пишем в поиск часть названия и проверяем что список отфильтровался
    final initialCount = tileFinder.evaluate().length;
    await tester.enterText(searchFinder, 'Океан');
    await tester.pumpAndSettle();
    final filteredCount = find.byType(ListTile).evaluate().length;
    expect(filteredCount, greaterThanOrEqualTo(1));
    expect(filteredCount, lessThan(initialCount));

    // Проверяем что можем перейти на детали торговой точки
    await tester.tap(find.text(knownName));
    await tester.pumpAndSettle();
    expect(find.byType(TradingPointDetailPage), findsOneWidget);
  });
}
