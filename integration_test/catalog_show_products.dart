/*
BDD Сценарий: Переход в категорию, проверка количества продуктов и списка продуктов
Дано я авторизирован
  И нахожусь в меню Каталог
  И количество продуктов в категориях обновлено
Когда нажимаю на Строительство и ремонт (3)
  Тогда я раскрываю категорию
  И вижу среди раскрывшихся категорий Лакокрасочные материалы с указанием количества продуктов (3)
  Тогда я раскрываю категорию Лакокрасочные материалы
  И вижу подкатегорию Эмали НЦ с указанием количества продуктов (3)
Тогда я нажимаю на эту подкатегорию
  И попадаю на список продуктов
  И количество продуктов соответствует указанному в подкатегории
  И вижу наверху кнопку со стрелкой Вернуться в каталог
  И вижу ниже список Компактных карточек продукта (картинка, имя, код, вес, количество в ящике, цена)
  И вижу кнопку добавить в корзине с правой стороны карточки
Когда нажимаю на название продукта в карточке
  Тогда попадаю на страницу с полным описанием продукта
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/fixtures/dev_fixture_orchestrator.dart';
import 'package:fieldforce/features/shop/presentation/product_catalog_page.dart';
import 'package:fieldforce/app/di/test_service_locator.dart' as test_di;
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import './helpers/session_test_helper.dart' as h;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await test_di.setupTestServiceLocator();
    final orchestrator = GetIt.instance<DevFixtureOrchestrator>();
    await orchestrator.createFullDevDataset(); // Фикстуры
    await h.ensureLoggedInAsDevUser(); // Сессия

    // Добавляем отладку после загрузки фикстур
    final categoryRepository = GetIt.instance<CategoryRepository>();
    final productRepository = GetIt.instance<ProductRepository>();

    print('=== ОТЛАДКА ПОСЛЕ ЗАГРУЗКИ ФИКСТУР ===');

    // Проверяем категории
    final categoriesResult = await categoryRepository.getAllCategories();
    categoriesResult.fold(
      (failure) => print('❌ Ошибка загрузки категорий: ${failure.message}'),
      (categories) {
        print('📂 Загружено ${categories.length} корневых категорий');
        for (final category in categories) {
          print('  📂 ${category.name} (id: ${category.id}, count: ${category.count})');
          _printCategoryTree(category, 1);
        }
      }
    );

    // Проверяем продукты
    final productsResult = await productRepository.getAllProducts();
    productsResult.fold(
      (failure) => print('❌ Ошибка загрузки продуктов: ${failure.message}'),
      (products) {
        print('📦 Загружено ${products.length} продуктов');
        for (final product in products) {
          print('  📦 ${product.title} (код: ${product.code})');
          print('     Категории: ${product.categoriesInstock.map((c) => '${c.name}(${c.id})').join(', ')}');
        }
      }
    );

    print('=====================================');
  });

  group('Catalog Show Products Integration Test', () {
    testWidgets('Navigate to category and show product list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductCatalogPage(),
        ),
      );

      // Ждем загрузки категорий и обновления количеств
      await tester.pumpAndSettle();

      // Отладка: посмотрим на все текстовые виджеты
      final allTexts = find.byType(Text);
      final textWidgets = allTexts.evaluate();
      print('=== Все текстовые виджеты ===');
      for (final widget in textWidgets) {
        final textWidget = widget.widget as Text;
        print('Текст: "${textWidget.data}"');
      }
      print('==============================');

      // Проверяем, что категории загружены
      expect(find.text('Строительство и ремонт'), findsOneWidget);
      expect(find.text('3'), findsOneWidget, reason: 'Количество 3 должно отображаться для Строительство и ремонт (сумма от всех дочерних)');

      // Раскрываем категорию "Строительство и ремонт" (кликаем на правую половину)
      final constructionCard = find.ancestor(
        of: find.text('Строительство и ремонт'),
        matching: find.byType(Card),
      );

      // Прокручиваем к карточке, чтобы она была видима
      await tester.scrollUntilVisible(constructionCard, 50.0);

      // Находим правую половину карточки (второй Expanded с InkWell для expand/collapse)
      final rightPart = find.descendant(
        of: constructionCard,
        matching: find.byType(InkWell),
      ).last; // Второй InkWell - правая половина для expand/collapse

      await tester.tap(rightPart);
      await tester.pumpAndSettle();

      // Проверяем, что среди раскрывшихся категорий есть "Лакокрасочные материалы" с количеством (3)
      // количество поднимается по дереву от подкатегорий
      final paintMaterialsFinder = find.text('Лакокрасочные материалы');
      expect(paintMaterialsFinder, findsWidgets);

      // Ищем количество (3) рядом с "Лакокрасочные материалы" среди дочерних элементов
      // Сначала найдем контейнер с отступом (дочерний уровень)
      final indentedContainer = find.ancestor(
        of: find.text('Лакокрасочные материалы'),
        matching: find.byType(Container),
      ).last; // Берем последний (самый вложенный)

      final paintCard = find.ancestor(
        of: indentedContainer,
        matching: find.byType(Card),
      );
      expect(find.descendant(of: paintCard, matching: find.text('3')), findsWidgets,
        reason: 'Количество 3 должно отображаться для Лакокрасочные материалы (родительская категория)');

      // Раскрываем категорию "Лакокрасочные материалы" (кликаем на правую половину для expand/collapse)
      final paintMaterialsCard = find.ancestor(
        of: find.text('Лакокрасочные материалы'),
        matching: find.byType(Card),
      );

      // Прокручиваем к карточке, чтобы она была видима
      await tester.scrollUntilVisible(paintMaterialsCard, 50.0);

      // Находим правую половину карточки "Лакокрасочные материалы" (второй InkWell для expand/collapse)
      final paintRightPart = find.descendant(
        of: paintMaterialsCard,
        matching: find.byType(InkWell),
      ).last; // Второй InkWell - правая половина для expand/collapse

      await tester.tap(paintRightPart);
      await tester.pumpAndSettle();

      // Проверяем, что видим подкатегорию "Эмали НЦ" с количеством (3)
      expect(find.text('Эмали НЦ'), findsOneWidget);

      // Ищем количество (3) для подкатегории "Эмали НЦ"
      final enamelCard = find.ancestor(
        of: find.text('Эмали НЦ'),
        matching: find.byType(Card),
      );
      expect(find.descendant(of: enamelCard, matching: find.text('3')), findsWidgets,
        reason: 'Количество 3 должно отображаться для Эмали НЦ');

      // Нажимаем на подкатегорию "Эмали НЦ" (кликаем на правую половину для перехода к товарам)
      // Находим правую половину карточки "Эмали НЦ" (второй InkWell)
      final enamelRightPart = find.descendant(
        of: enamelCard,
        matching: find.byType(InkWell),
      ).last; // Последний InkWell - правая половина

      // Прокручиваем к элементу, чтобы он был виден
      await tester.scrollUntilVisible(enamelRightPart, 50.0);

      await tester.tap(enamelRightPart);
      await tester.pumpAndSettle();

      // Проверяем, что мы на странице списка продуктов "Эмали НЦ"
      expect(find.text('Эмали НЦ'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Проверяем, что есть карточки продуктов
      final productCards = find.byType(Card);
      expect(productCards, findsWidgets);

      // Проверяем, что количество карточек соответствует количеству в категории (3)
      final actualProductCount = productCards.evaluate().length;
      expect(actualProductCount, equals(3),
        reason: 'Количество продуктов в категории должно соответствовать отображаемому числу (3)');

      // Проверяем, что есть кнопка "Вернуться в каталог"
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Проверяем элементы карточки продукта (должна быть хотя бы одна)
      final firstCard = productCards.first;
      expect(find.descendant(of: firstCard, matching: find.byType(Text)), findsWidgets);

      // Проверяем, что в карточках есть кнопка добавить в корзину
      expect(find.byIcon(Icons.add_shopping_cart), findsWidgets, reason: 'Должны быть кнопки добавить в корзину в карточках продуктов');

      // Нажимаем на название продукта в первой карточке
      final productTitle = find.descendant(
        of: firstCard,
        matching: find.byType(Text),
      ).first;
      await tester.tap(productTitle);
      await tester.pumpAndSettle();

      // Проверяем, что попали на страницу с полным описанием продукта
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget, reason: 'Должна быть кнопка назад на странице продукта');
    });
  });
}

void _printCategoryTree(dynamic category, int depth) {
  final indent = '  ' * depth;
  print('$indent📂 ${category.name} (id: ${category.id}, count: ${category.count})');
  for (final child in category.children ?? []) {
    _printCategoryTree(child, depth + 1);
  }
}


