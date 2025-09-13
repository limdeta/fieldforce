import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';

void main() {
  group('Category Repository Integration Tests', () {
    test('Category entity should serialize and deserialize correctly', () {
      // Arrange
      final originalCategory = Category(
        id: 1,
        name: 'Test Category',
        lft: 1,
        lvl: 1,
        rgt: 4,
        description: 'Test description',
        query: 'types=123',
        count: 10,
        children: [
          Category(
            id: 2,
            name: 'Child Category',
            lft: 2,
            lvl: 2,
            rgt: 3,
            count: 5,
            children: [],
          ),
        ],
      );

      // Act
      final json = originalCategory.toJson();
      final deserializedCategory = Category.fromJson(json);

      // Assert
      expect(deserializedCategory.id, originalCategory.id);
      expect(deserializedCategory.name, originalCategory.name);
      expect(deserializedCategory.lft, originalCategory.lft);
      expect(deserializedCategory.lvl, originalCategory.lvl);
      expect(deserializedCategory.rgt, originalCategory.rgt);
      expect(deserializedCategory.description, originalCategory.description);
      expect(deserializedCategory.query, originalCategory.query);
      expect(deserializedCategory.count, originalCategory.count);
      expect(deserializedCategory.children.length, originalCategory.children.length);
      expect(deserializedCategory.children[0].id, originalCategory.children[0].id);
    });

    test('Category tree operations should work correctly', () {
      // Arrange
      final tree = _createTestCategoryTree();

      // Act & Assert
      expect(tree.isRoot(), true);
      expect(tree.isLeaf(), false);
      expect(tree.getAllDescendants().length, 3);

      final foundCategory = tree.findById(3);
      expect(foundCategory, isNotNull);
      expect(foundCategory!.name, 'Category 3');

      final notFoundCategory = tree.findById(999);
      expect(notFoundCategory, null);
    });
  });
}

Category _createTestCategoryTree() {
  return Category(
    id: 1,
    name: 'Root Category',
    lft: 1,
    lvl: 1,
    rgt: 8,
    count: 25,
    children: [
      Category(
        id: 2,
        name: 'Category 2',
        lft: 2,
        lvl: 2,
        rgt: 5,
        count: 10,
        children: [
          Category(
            id: 3,
            name: 'Category 3',
            lft: 3,
            lvl: 3,
            rgt: 4,
            count: 5,
            children: [],
          ),
        ],
      ),
      Category(
        id: 4,
        name: 'Category 4',
        lft: 6,
        lvl: 2,
        rgt: 7,
        count: 10,
        children: [],
      ),
    ],
  );
}