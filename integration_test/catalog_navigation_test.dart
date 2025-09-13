// dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/fixtures/dev_fixture_orchestrator.dart';
import 'package:fieldforce/features/shop/presentation/product_catalog_page.dart';
import 'package:fieldforce/app/presentation/pages/main_menu_page.dart';
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

  /*
  BDD Сценарий: Навигация к каталогу товаров
  Дано я авторизирован
  И нахожусь в главном меню
  Когда нажимаю на кнопку "Товары"
  Тогда выпадает меню выбора конкретных категорий: Каталог, Категории прайса, Акции
  Когда нажимаю на "Каталог"
  Тогда я попадаю на страницу каталога
  И вижу список корневых категорий
  И вижу стрелки с правой части имени категории
  Когда я нажимаю на стрелку
  Тогда я раскрываю категории ниже уровнем
  Когда я нажимаю на название категории
  Тогда попадаю на страницу продуктов (заглушка)
  */
  testWidgets('Catalog navigation: menu expansion, navigation to catalog page, category list display', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const MainMenuPage(),
        routes: {
          '/sales-home': (context) => const Scaffold(body: Center(child: Text('Главная карта'))),
          '/products/catalog': (context) => const ProductCatalogPage(),
        },
      ),
    );

    await tester.pumpAndSettle();

    // Проверяем что нет доменных ошибок
    expect(find.text('Не удалось получить сессию пользователя'), findsNothing);
    expect(find.text('Пользователь не найден в сессии'), findsNothing);
    expect(find.text('Ошибка'), findsNothing);

    // Находим кнопку "Товары" в главном меню
    final productsMenuFinder = find.text('Товары');
    expect(productsMenuFinder, findsOneWidget);

    // Нажимаем на "Товары" чтобы раскрыть подменю
    await tester.tap(productsMenuFinder);
    await tester.pumpAndSettle();

    // Проверяем что появилось подменю с "Каталог"
    final catalogSubMenuFinder = find.text('Каталог');
    expect(catalogSubMenuFinder, findsOneWidget);

    // Также проверяем другие пункты подменю
    expect(find.text('Категории прайса'), findsOneWidget);
    expect(find.text('Акции'), findsOneWidget);

    // Нажимаем на "Каталог"
    await tester.tap(catalogSubMenuFinder);
    await tester.pumpAndSettle();

    // Проверяем что перешли на страницу каталога
    expect(find.text('Каталог товаров'), findsOneWidget);
    
    // Проверяем наличие поля поиска
    expect(find.text('Поиск по категориям...'), findsOneWidget);
    
    // Ждем загрузки данных
    await tester.pumpAndSettle();
    
    // Проверяем что есть хотя бы одна категория (иконки категорий)
    expect(find.byIcon(Icons.category), findsWidgets);
    
    // Проверяем наличие кнопки корзины
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    
    // Если есть популярные категории, проверяем их отображение
    if (find.text('Популярные категории').evaluate().isNotEmpty) {
      expect(find.text('Популярные категории'), findsOneWidget);
    }
  });
}