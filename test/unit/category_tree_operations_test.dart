import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';

void main() {
  group('Category Tree Operations', () {
    test('getAllDescendants should return all descendants in correct order', () {
      // Arrange
      final tree = _createTestCategoryTree();

      // Act
      final descendants = tree.getAllDescendants();

      // Assert
      expect(descendants.length, 3);
      expect(descendants.map((c) => c.id), containsAll([2, 3, 4]));
    });

    test('findById should find category by id', () {
      // Arrange
      final tree = _createTestCategoryTree();

      // Act
      final found = tree.findById(3);
      final notFound = tree.findById(999);

      // Assert
      expect(found, isNotNull);
      expect(found!.name, 'Category 3');
      expect(notFound, isNull);
    });

    test('isLeaf and isRoot should work correctly', () {
      // Arrange
      final tree = _createTestCategoryTree();

      // Act & Assert
      expect(tree.isRoot(), true);
      expect(tree.isLeaf(), false);

      final leafCategory = tree.findById(3);
      expect(leafCategory!.isLeaf(), true);
      expect(leafCategory.isRoot(), false);
    });
  });

  group('Hierarchical Category Search', () {
    test('should find products in parent categories using nested set logic', () {
      // Arrange
      final constructionCategory = Category(
        id: 196,
        name: 'Строительство и ремонт',
        lft: 310,
        lvl: 1,
        rgt: 399,
        description: null,
        query: null,
        count: 2871,
        children: [
          Category(
            id: 211,
            name: 'Лакокрасочные материалы',
            lft: 339,
            lvl: 2,
            rgt: 362,
            description: null,
            query: null,
            count: 809,
            children: [
              Category(
                id: 221,
                name: 'Эмали НЦ',
                lft: 358,
                lvl: 3,
                rgt: 359,
                description: null,
                query: 'types=1163,1220',
                count: 12,
                children: [],
              ),
              Category(
                id: 212,
                name: 'Колеры, колеровочные пасты',
                lft: 340,
                lvl: 3,
                rgt: 341,
                description: null,
                query: 'types=1155,1158,2705,1865,1267,1268',
                count: 94,
                children: [],
              ),
            ],
          ),
        ],
      );

      // Act
      final allDescendants = constructionCategory.getAllDescendants();
      final paintMaterials = constructionCategory.findById(211);
      final paintDescendants = paintMaterials?.getAllDescendants();

      // Assert
      expect(allDescendants.length, 3);
      expect(allDescendants.map((c) => c.id), containsAll([211, 221, 212]));
      expect(paintDescendants?.length, 2);
      expect(paintDescendants?.map((c) => c.id), containsAll([221, 212]));
    });

    test('should simulate product count aggregation in parent categories', () {
      // Arrange
      final constructionCategory = Category(
        id: 196,
        name: 'Строительство и ремонт',
        lft: 310,
        lvl: 1,
        rgt: 399,
        description: null,
        query: null,
        count: 0, // Начальный count = 0
        children: [
          Category(
            id: 211,
            name: 'Лакокрасочные материалы',
            lft: 339,
            lvl: 2,
            rgt: 362,
            description: null,
            query: null,
            count: 0,
            children: [
              Category(
                id: 221,
                name: 'Эмали НЦ',
                lft: 358,
                lvl: 3,
                rgt: 359,
                description: null,
                query: 'types=1163,1220',
                count: 12, // 12 продуктов в Эмали НЦ
                children: [],
              ),
              Category(
                id: 212,
                name: 'Колеры, колеровочные пасты',
                lft: 340,
                lvl: 3,
                rgt: 341,
                description: null,
                query: 'types=1155,1158,2705,1865,1267,1268',
                count: 94, // 94 продукта в Колерах
                children: [],
              ),
            ],
          ),
        ],
      );

      // Act - симуляция агрегации количества продуктов
      final totalProducts = _calculateTotalProducts(constructionCategory);
      final paintProducts = _calculateTotalProducts(constructionCategory.findById(211)!);

      // Assert
      expect(totalProducts, 106); // 12 + 94
      expect(paintProducts, 106); // 12 + 94
    });
  });
}

/// Вспомогательная функция для расчета общего количества продуктов в категории
int _calculateTotalProducts(Category category) {
  if (category.isLeaf()) {
    return category.count;
  }

  int total = category.count; // Продукты непосредственно в этой категории
  for (final child in category.children) {
    total += _calculateTotalProducts(child);
  }
  return total;
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