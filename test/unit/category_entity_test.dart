import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';

void main() {
  group('Category Entity Tests', () {
    test('fromJson should parse simple category correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Test Category',
        'lft': 1,
        'lvl': 1,
        'rgt': 2,
        'description': 'Test description',
        'query': 'types=123',
        'count': 10,
        'children': <dynamic>[],
      };

      // Act
      final category = Category.fromJson(json);

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Test Category');
      expect(category.lft, 1);
      expect(category.lvl, 1);
      expect(category.rgt, 2);
      expect(category.description, 'Test description');
      expect(category.query, 'types=123');
      expect(category.count, 10);
      expect(category.children, isEmpty);
    });

    test('fromJson should parse category with children correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Parent Category',
        'lft': 1,
        'lvl': 1,
        'rgt': 6,
        'description': null,
        'query': null,
        'count': 20,
        'children': [
          {
            'id': 2,
            'name': 'Child Category',
            'lft': 2,
            'lvl': 2,
            'rgt': 3,
            'description': 'Child description',
            'query': 'types=456',
            'count': 5,
            'children': [],
          },
        ],
      };

      // Act
      final category = Category.fromJson(json);

      // Assert
      expect(category.id, 1);
      expect(category.name, 'Parent Category');
      expect(category.children.length, 1);
      expect(category.children[0].id, 2);
      expect(category.children[0].name, 'Child Category');
      expect(category.children[0].description, 'Child description');
    });

    test('toJson should serialize category correctly', () {
      // Arrange
      final category = Category(
        id: 1,
        name: 'Test Category',
        lft: 1,
        lvl: 1,
        rgt: 2,
        description: 'Test description',
        query: 'types=123',
        count: 10,
        children: [],
      );

      // Act
      final json = category.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Test Category');
      expect(json['lft'], 1);
      expect(json['lvl'], 1);
      expect(json['rgt'], 2);
      expect(json['description'], 'Test description');
      expect(json['query'], 'types=123');
      expect(json['count'], 10);
      expect(json['children'], isEmpty);
    });

    test('isLeaf should return true for category without children', () {
      // Arrange
      final category = Category(
        id: 1,
        name: 'Leaf Category',
        lft: 1,
        lvl: 1,
        rgt: 2,
        count: 5,
        children: [],
      );

      // Act & Assert
      expect(category.isLeaf(), true);
    });

    test('isLeaf should return false for category with children', () {
      // Arrange
      final category = Category(
        id: 1,
        name: 'Parent Category',
        lft: 1,
        lvl: 1,
        rgt: 4,
        count: 10,
        children: [
          Category(
            id: 2,
            name: 'Child',
            lft: 2,
            lvl: 2,
            rgt: 3,
            count: 5,
            children: [],
          ),
        ],
      );

      // Act & Assert
      expect(category.isLeaf(), false);
    });

    test('isRoot should return true for root category', () {
      // Arrange
      final category = Category(
        id: 1,
        name: 'Root Category',
        lft: 1,
        lvl: 1,
        rgt: 10,
        count: 100,
        children: [],
      );

      // Act & Assert
      expect(category.isRoot(), true);
    });

    test('isRoot should return false for non-root category', () {
      // Arrange
      final category = Category(
        id: 2,
        name: 'Child Category',
        lft: 2,
        lvl: 2,
        rgt: 3,
        count: 10,
        children: [],
      );

      // Act & Assert
      expect(category.isRoot(), false);
    });

    test('getAllDescendants should return all nested children', () {
      // Arrange
      final child1 = Category(
        id: 2,
        name: 'Child 1',
        lft: 2,
        lvl: 2,
        rgt: 5,
        count: 15,
        children: [
          Category(
            id: 4,
            name: 'Grandchild',
            lft: 3,
            lvl: 3,
            rgt: 4,
            count: 5,
            children: [],
          ),
        ],
      );

      final child2 = Category(
        id: 3,
        name: 'Child 2',
        lft: 6,
        lvl: 2,
        rgt: 7,
        count: 10,
        children: [],
      );

      final parent = Category(
        id: 1,
        name: 'Parent',
        lft: 1,
        lvl: 1,
        rgt: 8,
        count: 30,
        children: [child1, child2],
      );

      // Act
      final descendants = parent.getAllDescendants();

      // Assert
      expect(descendants.length, 3);
      expect(descendants.map((c) => c.id), containsAll([2, 3, 4]));
    });

    test('findById should return correct category', () {
      // Arrange
      final grandchild = Category(
        id: 4,
        name: 'Grandchild',
        lft: 3,
        lvl: 3,
        rgt: 4,
        count: 5,
        children: [],
      );

      final child = Category(
        id: 2,
        name: 'Child',
        lft: 2,
        lvl: 2,
        rgt: 5,
        count: 15,
        children: [grandchild],
      );

      final parent = Category(
        id: 1,
        name: 'Parent',
        lft: 1,
        lvl: 1,
        rgt: 6,
        count: 20,
        children: [child],
      );

      // Act & Assert
      expect(parent.findById(1), parent);
      expect(parent.findById(2), child);
      expect(parent.findById(4), grandchild);
      expect(parent.findById(999), null);
    });
  });
}