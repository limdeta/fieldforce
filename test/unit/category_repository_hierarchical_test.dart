import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/category_repository_drift.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:convert';

void main() {
  late CategoryRepository categoryRepository;

  setUpAll(() async {
    // Создаем in-memory базу данных для тестов
    final inMemoryDb = NativeDatabase.memory();
    final database = AppDatabase.forTesting(DatabaseConnection(inMemoryDb));

    // Регистрируем сервисы вручную для теста, если они не зарегистрированы
    if (!GetIt.instance.isRegistered<AppDatabase>()) {
      GetIt.instance.registerSingleton<AppDatabase>(database);
    }
    if (!GetIt.instance.isRegistered<CategoryRepository>()) {
      GetIt.instance.registerLazySingleton<CategoryRepository>(
        () => DriftCategoryRepository(),
      );
    }

    categoryRepository = GetIt.instance<CategoryRepository>();
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  group('CategoryRepository Hierarchical Methods Integration Tests', () {
    setUp(() async {
      // Очищаем базу данных перед каждым тестом
      final database = GetIt.instance<AppDatabase>();
      await database.transaction(() async {
        for (final table in database.allTables) {
          await database.delete(table).go();
        }
      });

      // Создаем тестовую иерархию категорий
      await _setupTestCategories();
    });

    test('getAllDescendants should return all descendants of a category', () async {
      // Act
      final result = await categoryRepository.getAllDescendants(196); // Строительство и ремонт

      // Assert
      expect(result.isRight(), true);
      final descendants = result.getOrElse(() => []);
      expect(descendants.length, 3);
      expect(descendants.map((c) => c.id), containsAll([211, 221, 212]));
    });

    test('getAllDescendants should return empty list for leaf category', () async {
      // Act
      final result = await categoryRepository.getAllDescendants(221); // Эмали НЦ (лист)

      // Assert
      expect(result.isRight(), true);
      final descendants = result.getOrElse(() => []);
      expect(descendants.length, 0);
    });

    test('getAllAncestors should return all ancestors of a category', () async {
      // Act
      final result = await categoryRepository.getAllAncestors(221); // Эмали НЦ

      // Assert
      expect(result.isRight(), true);
      final ancestors = result.getOrElse(() => []);
      expect(ancestors.length, 2);
      expect(ancestors.map((c) => c.id), containsAll([211, 196]));
    });

    test('getAllAncestors should return empty list for root category', () async {
      // Act
      final result = await categoryRepository.getAllAncestors(196); // Строительство и ремонт (корень)

      // Assert
      expect(result.isRight(), true);
      final ancestors = result.getOrElse(() => []);
      expect(ancestors.length, 0);
    });

    test('getAllDescendants should handle non-existent category', () async {
      // Act
      final result = await categoryRepository.getAllDescendants(99999);

      // Assert
      expect(result.isRight(), true);
      final descendants = result.getOrElse(() => []);
      expect(descendants.length, 0);
    });

    test('getAllAncestors should handle non-existent category', () async {
      // Act
      final result = await categoryRepository.getAllAncestors(99999);

      // Assert
      expect(result.isRight(), true);
      final ancestors = result.getOrElse(() => []);
      expect(ancestors.length, 0);
    });
  });
}

/// Вспомогательная функция для создания тестовой иерархии категорий
Future<void> _setupTestCategories() async {
  final database = GetIt.instance<AppDatabase>();

  // Создаем тестовые категории в правильном порядке (сначала родители)
  final categoriesData = [
    // Строительство и ремонт (корень)
    {
      'id': 196,
      'name': 'Строительство и ремонт',
      'lft': 310,
      'lvl': 1,
      'rgt': 399,
      'description': null,
      'query': null,
      'count': 0,
      'parentId': null,
    },
    // Лакокрасочные материалы
    {
      'id': 211,
      'name': 'Лакокрасочные материалы',
      'lft': 339,
      'lvl': 2,
      'rgt': 362,
      'description': null,
      'query': null,
      'count': 0,
      'parentId': 196,
    },
    // Эмали НЦ
    {
      'id': 221,
      'name': 'Эмали НЦ',
      'lft': 358,
      'lvl': 3,
      'rgt': 359,
      'description': null,
      'query': 'types=1163,1220',
      'count': 12,
      'parentId': 211,
    },
    // Колеры, колеровочные пасты
    {
      'id': 212,
      'name': 'Колеры, колеровочные пасты',
      'lft': 340,
      'lvl': 3,
      'rgt': 341,
      'description': null,
      'query': 'types=1155,1158,2705,1865,1267,1268',
      'count': 94,
      'parentId': 211,
    },
  ];

  for (final categoryData in categoriesData) {
    await database.into(database.categories).insert(
      CategoriesCompanion(
        name: Value(categoryData['name'] as String),
        categoryId: Value(categoryData['id'] as int),
        lft: Value(categoryData['lft'] as int),
        lvl: Value(categoryData['lvl'] as int),
        rgt: Value(categoryData['rgt'] as int),
        description: Value(categoryData['description'] as String?),
        query: Value(categoryData['query'] as String?),
        count: Value(categoryData['count'] as int),
        parentId: Value(categoryData['parentId'] as int?),
        rawJson: Value(jsonEncode(categoryData)),
      ),
    );
  }
}