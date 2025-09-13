import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/data/fixtures/category_fixture_service.dart';
import 'package:fieldforce/features/shop/data/services/category_parsing_service.dart';
import 'package:fieldforce/app/database/repositories/category_repository_drift.dart';

void main() {
  late CategoryParsingService parsingService;
  late DriftCategoryRepository repository;
  late CategoryFixtureService fixtureService;

  setUp(() async {
    // Используем уже зарегистрированную базу данных из setupTestServiceLocator
    parsingService = CategoryParsingService();
    repository = DriftCategoryRepository();
    fixtureService = CategoryFixtureService(parsingService, repository);
  });

  test('CategoryFixtureService loads categories successfully', () async {
    // Act
    await fixtureService.loadCategories();

    // Assert
    final categories = await repository.getAllCategories();
    categories.fold(
      (failure) => fail('Failed to get categories: ${failure.message}'),
      (categoryList) {
        expect(categoryList, isNotEmpty);
        expect(categoryList.length, greaterThanOrEqualTo(2)); // У нас 2 корневые категории
        
        // Проверяем, что есть категории с детьми
        final rootCategories = categoryList.where((c) => c.children.isNotEmpty);
        expect(rootCategories, isNotEmpty);
      },
    );
  });
}