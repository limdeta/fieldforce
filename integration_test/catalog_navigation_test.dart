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
  Когда я нажимаю на стрелку На Строительство и Ремонт
    Тогда я раскрываю категории ниже уровнем
    И вижу в список дочерних категорий
    И вижу среди них Лакокрасочные материалы
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
    
    // Ждем дополнительно для загрузки категорий
    await tester.pumpAndSettle();
    
    // Находим категорию "Строительство и ремонт"
    final constructionCategoryFinder = find.text('Строительство и ремонт');
    expect(constructionCategoryFinder, findsOneWidget, reason: 'Категория "Строительство и ремонт" должна быть видна');
    
    // Проверяем что категория действительно имеет дочерние элементы (иконка или стрелка)
    final constructionCardFinder = find.ancestor(
      of: constructionCategoryFinder,
      matching: find.byType(Card),
    );
    expect(constructionCardFinder, findsOneWidget, reason: 'Должен найти карточку категории');
    
    // Ищем все InkWell внутри карточки
    find.descendant(
      of: constructionCardFinder,
      matching: find.byType(InkWell),
    );
        
    // Проверим все текстовые виджеты ДО клика
    final allTextWidgetsBefore = find.byType(Text);
    final textWidgetsBefore = tester.widgetList<Text>(allTextWidgetsBefore);
    textWidgetsBefore.map((w) => w.data).where((text) => text != null).toList();
    
    // Кликаем на ПОСЛЕДНИЙ InkWell (основная кликабельная область для всей строки)
    final allInkWellFinders = find.descendant(
      of: constructionCardFinder,
      matching: find.byType(InkWell),
    );
        
    // Кликаем на последний InkWell (это должен быть основной для всей строки)
    final lastInkWellFinder = allInkWellFinders.last;
    
    await tester.tap(lastInkWellFinder);
    await tester.pumpAndSettle();
    
    // Проверим все текстовые виджеты ПОСЛЕ клика
    final allTextWidgetsAfter = find.byType(Text);
    final textWidgetsAfter = tester.widgetList<Text>(allTextWidgetsAfter);
    textWidgetsAfter.map((w) => w.data).where((text) => text != null).toList();
    
    // Ждем дополнительно для анимации раскрытия
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Ищем "Лакокрасочные материалы" среди всех текстов
    final paintMaterialsFinder = find.text('Лакокрасочные материалы');
    expect(paintMaterialsFinder, findsWidgets, 
           reason: 'После раскрытия категории "Строительство и ремонт" должна появиться хотя бы одна дочерняя категория "Лакокрасочные материалы"');
    
    // Проверяем что количество виджетов с "Лакокрасочные материалы" увеличилось
    final paintMaterialsCount = paintMaterialsFinder.evaluate().length;
    
    // Должно быть как минимум 2 виджета (один был до раскрытия, плюс новый после раскрытия)
    expect(paintMaterialsCount, greaterThanOrEqualTo(2), 
           reason: 'Количество виджетов "Лакокрасочные материалы" должно увеличиться после раскрытия');
    
    // Если есть популярные категории, проверяем их отображение
    // TODO реализовать часто используемые категории
    // if (find.text('Популярные категории').evaluate().isNotEmpty) {
    //   expect(find.text('Популярные категории'), findsOneWidget);
    // }
  });
}