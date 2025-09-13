import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/data/services/category_parsing_service.dart';

void main() {
  late CategoryParsingService service;

  setUp(() {
    service = CategoryParsingService();
  });

  group('CategoryParsingService Integration Tests', () {
    test('parseCategoriesFromJsonString should handle real category data', () {
      // Arrange - используем упрощенные тестовые данные в формате реального JSON
      const jsonString = '''
      [
        {
          "id": 83,
          "name": "Гигиена и уход",
          "lft": 2,
          "lvl": 1,
          "rgt": 117,
          "description": null,
          "query": null,
          "count": 2950,
          "children": [
            {
              "id": 113,
              "name": "Мыло",
              "lft": 3,
              "lvl": 2,
              "rgt": 8,
              "description": null,
              "query": null,
              "count": 240,
              "children": [
                {
                  "id": 114,
                  "name": "Жидкое мыло",
                  "lft": 4,
                  "lvl": 3,
                  "rgt": 5,
                  "description": null,
                  "query": "types=605,514,113,606",
                  "count": 120,
                  "children": []
                }
              ]
            }
          ]
        }
      ]
      ''';

      // Act
      final categories = service.parseCategoriesFromJsonString(jsonString);

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 83);
      expect(categories[0].name, 'Гигиена и уход');
      expect(categories[0].lft, 2);
      expect(categories[0].lvl, 1);
      expect(categories[0].rgt, 117);
      expect(categories[0].count, 2950);
      expect(categories[0].children.length, 1);

      final child = categories[0].children[0];
      expect(child.id, 113);
      expect(child.name, 'Мыло');
      expect(child.children.length, 1);

      final grandchild = child.children[0];
      expect(grandchild.id, 114);
      expect(grandchild.name, 'Жидкое мыло');
      expect(grandchild.query, 'types=605,514,113,606');
      expect(grandchild.children, isEmpty);
    });

    test('parseCategoriesFromJsonString should handle multiple root categories', () {
      // Arrange
      const jsonString = '''
      [
        {
          "id": 83,
          "name": "Гигиена и уход",
          "lft": 2,
          "lvl": 1,
          "rgt": 10,
          "count": 100,
          "children": []
        },
        {
          "id": 34,
          "name": "Бытовая химия",
          "lft": 11,
          "lvl": 1,
          "rgt": 20,
          "count": 200,
          "children": []
        }
      ]
      ''';

      // Act
      final categories = service.parseCategoriesFromJsonString(jsonString);

      // Assert
      expect(categories.length, 2);
      expect(categories[0].id, 83);
      expect(categories[0].name, 'Гигиена и уход');
      expect(categories[1].id, 34);
      expect(categories[1].name, 'Бытовая химия');
    });

    test('parseCategoriesFromJsonString should handle categories with HTML descriptions', () {
      // Arrange
      const jsonString = '''
      [
        {
          "id": 99,
          "name": "Туалетная бумага",
          "lft": 28,
          "lvl": 3,
          "rgt": 29,
          "description": "<h3>Туалетная бумага купить оптом</h3><p>В каталоге оптовой продажи...</p>",
          "query": "types=229,1121",
          "count": 62,
          "children": []
        }
      ]
      ''';

      // Act
      final categories = service.parseCategoriesFromJsonString(jsonString);

      // Assert
      expect(categories.length, 1);
      expect(categories[0].id, 99);
      expect(categories[0].name, 'Туалетная бумага');
      expect(categories[0].description, contains('<h3>'));
      expect(categories[0].query, 'types=229,1121');
    });
  });
}