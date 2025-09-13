import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/data/services/category_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';

void main() {
  late CategoryParsingService service;

  setUp(() {
    service = CategoryParsingService();
  });

  group('CategoryParsingService Tests', () {
    test('parseCategoriesFromJsonString should parse valid JSON correctly', () {
      // Arrange
      const jsonString = '''
      [
        {
          "id": 1,
          "name": "Test Category",
          "lft": 1,
          "lvl": 1,
          "rgt": 4,
          "description": "Test description",
          "query": "types=123",
          "count": 10,
          "children": [
            {
              "id": 2,
              "name": "Child Category",
              "lft": 2,
              "lvl": 2,
              "rgt": 3,
              "description": null,
              "query": "types=456",
              "count": 5,
              "children": []
            }
          ]
        }
      ]
      ''';

      // Act
      final categories = service.parseCategoriesFromJsonString(jsonString);

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 1);
      expect(categories[0].name, 'Test Category');
      expect(categories[0].description, 'Test description');
      expect(categories[0].query, 'types=123');
      expect(categories[0].count, 10);
      expect(categories[0].children.length, 1);
      expect(categories[0].children[0].id, 2);
      expect(categories[0].children[0].name, 'Child Category');
    });

    test('parseCategoriesFromJsonString should handle empty list', () {
      // Arrange
      const jsonString = '[]';

      // Act
      final categories = service.parseCategoriesFromJsonString(jsonString);

      // Assert
      expect(categories, isEmpty);
    });

    test('parseCategoriesFromJsonString should throw exception for invalid JSON', () {
      // Arrange
      const invalidJsonString = '{ invalid json }';

      // Act & Assert
      expect(
        () => service.parseCategoriesFromJsonString(invalidJsonString),
        throwsA(isA<Exception>()),
      );
    });

    test('parseCategoriesFromJsonString should throw exception for non-list JSON', () {
      // Arrange
      const nonListJsonString = '{"id": 1, "name": "Test"}';

      // Act & Assert
      expect(
        () => service.parseCategoriesFromJsonString(nonListJsonString),
        throwsA(isA<Exception>()),
      );
    });

    test('parseCategoriesFromJsonString should handle categories without children', () {
      // Arrange
      const jsonString = '''
      [
        {
          "id": 1,
          "name": "Category 1",
          "lft": 1,
          "lvl": 1,
          "rgt": 2,
          "count": 5,
          "children": []
        },
        {
          "id": 2,
          "name": "Category 2",
          "lft": 3,
          "lvl": 1,
          "rgt": 4,
          "count": 8,
          "children": []
        }
      ]
      ''';

      // Act
      final categories = service.parseCategoriesFromJsonString(jsonString);

      // Assert
      expect(categories.length, 2);
      expect(categories[0].id, 1);
      expect(categories[0].name, 'Category 1');
      expect(categories[0].children, isEmpty);
      expect(categories[1].id, 2);
      expect(categories[1].name, 'Category 2');
      expect(categories[1].children, isEmpty);
    });
  });
}