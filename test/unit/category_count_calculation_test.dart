import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart' as tree_category;

void main() {
  group('Category Count Calculation Tests', () {
    test('should calculate product counts for category tree', () {
      // Arrange
      final products = [
        _createEnamelProduct(),
        _createEnamelProduct(), // Второй продукт в Эмали НЦ
        _createColorantProduct(),
        _createColorantProduct(),
        _createColorantProduct(), // Три продукта в Колерах
      ];

      final constructionCategory = _createConstructionCategoryTree();

      // Act
      final categoryCounts = _calculateProductCountsForHierarchy(
        products,
        constructionCategory,
      );

      // Assert
      expect(categoryCounts[196], 5); // Строительство и ремонт: 5 продуктов
      expect(categoryCounts[211], 5); // Лакокрасочные материалы: 5 продуктов
      expect(categoryCounts[221], 2); // Эмали НЦ: 2 продукта
      expect(categoryCounts[212], 3); // Колеры: 3 продукта
    });

    test('should handle empty product list', () {
      // Arrange
      final products = <Product>[];
      final constructionCategory = _createConstructionCategoryTree();

      // Act
      final categoryCounts = _calculateProductCountsForHierarchy(
        products,
        constructionCategory,
      );

      // Assert
      expect(categoryCounts[196], 0); // Строительство и ремонт: 0 продуктов
      expect(categoryCounts[211], 0); // Лакокрасочные материалы: 0 продуктов
      expect(categoryCounts[221], 0); // Эмали НЦ: 0 продуктов
      expect(categoryCounts[212], 0); // Колеры: 0 продуктов
    });

    test('should handle products with multiple categories', () {
      // Arrange
      final multiCategoryProduct = _createMultiCategoryProduct();
      final constructionCategory = _createConstructionCategoryTree();

      // Act
      final categoryCounts = _calculateProductCountsForHierarchy(
        [multiCategoryProduct],
        constructionCategory,
      );

      // Assert
      expect(categoryCounts[196], 1); // Строительство и ремонт: 1 продукт
      expect(categoryCounts[211], 1); // Лакокрасочные материалы: 1 продукт
      expect(categoryCounts[221], 1); // Эмали НЦ: 1 продукт
      expect(categoryCounts[212], 1); // Колеры: 1 продукт
    });

    test('should calculate counts for complex hierarchy', () {
      // Arrange - создаем более сложную иерархию
      final complexTree = _createComplexCategoryTree();
      final products = [
        _createEnamelProduct(), // В Эмали НЦ
        _createColorantProduct(), // В Колерах
        _createToiletPaperProduct(), // В Туалетной бумаге (другая ветка)
      ];

      // Act
      final categoryCounts = _calculateProductCountsForHierarchy(
        products,
        complexTree,
      );

      // Assert
      expect(categoryCounts[1], 3); // Корень: 3 продукта
      expect(categoryCounts[196], 2); // Строительство и ремонт: 2 продукта
      expect(categoryCounts[211], 2); // Лакокрасочные материалы: 2 продукта
      expect(categoryCounts[221], 1); // Эмали НЦ: 1 продукт
      expect(categoryCounts[212], 1); // Колеры: 1 продукт
      expect(categoryCounts[83], 1); // Гигиена и уход: 1 продукт
      expect(categoryCounts[99], 1); // Туалетная бумага: 1 продукт
    });

    test('should update category counts in tree structure', () {
      // Arrange
      final products = [
        _createEnamelProduct(),
        _createColorantProduct(),
      ];

      final constructionCategory = _createConstructionCategoryTree();

      // Act
      final updatedTree = _updateCategoryCountsInTree(
        constructionCategory,
        products,
      );

      // Assert
      expect(updatedTree.count, 2); // Строительство и ремонт: 2 продукта
      expect(updatedTree.findById(211)!.count, 2); // Лакокрасочные материалы: 2 продукта
      expect(updatedTree.findById(221)!.count, 1); // Эмали НЦ: 1 продукт
      expect(updatedTree.findById(212)!.count, 1); // Колеры: 1 продукт
    });
  });
}

/// Вспомогательная функция для расчета количества продуктов по категориям
Map<int, int> _calculateProductCountsForHierarchy(
  List<Product> products,
  tree_category.Category rootCategory,
) {
  final counts = <int, int>{};

  // Получаем все категории в иерархии
  final allCategories = [rootCategory, ...rootCategory.getAllDescendants()];

  for (final category in allCategories) {
    final categoryProducts = _findProductsInCategoryAndDescendants(products, category);
    counts[category.id] = categoryProducts.length;
  }

  return counts;
}

/// Вспомогательная функция для поиска продуктов в категории и её потомках
List<Product> _findProductsInCategoryAndDescendants(
  List<Product> products,
  tree_category.Category category,
) {
  final result = <Product>[];
  final categoryIds = {category.id};

  // Добавляем ID всех потомков
  for (final descendant in category.getAllDescendants()) {
    categoryIds.add(descendant.id);
  }

  // Ищем продукты, у которых есть категории из нашего множества
  for (final product in products) {
    final productCategoryIds = product.categoriesInstock.map((c) => c.id).toSet();
    if (productCategoryIds.intersection(categoryIds).isNotEmpty) {
      result.add(product);
    }
  }

  return result;
}

/// Вспомогательная функция для обновления count в дереве категорий
tree_category.Category _updateCategoryCountsInTree(
  tree_category.Category rootCategory,
  List<Product> products,
) {
  final counts = _calculateProductCountsForHierarchy(products, rootCategory);

  // Создаем новое дерево с обновленными count
  tree_category.Category updateCategory(tree_category.Category category) {
    final updatedChildren = category.children.map(updateCategory).toList();
    final newCount = counts[category.id] ?? 0;

    return tree_category.Category(
      id: category.id,
      name: category.name,
      lft: category.lft,
      lvl: category.lvl,
      rgt: category.rgt,
      description: category.description,
      query: category.query,
      count: newCount,
      children: updatedChildren,
    );
  }

  return updateCategory(rootCategory);
}

tree_category.Category _createConstructionCategoryTree() {
  return tree_category.Category(
    id: 196,
    name: 'Строительство и ремонт',
    lft: 310,
    lvl: 1,
    rgt: 399,
    description: null,
    query: null,
    count: 0,
    children: [
      tree_category.Category(
        id: 211,
        name: 'Лакокрасочные материалы',
        lft: 339,
        lvl: 2,
        rgt: 362,
        description: null,
        query: null,
        count: 0,
        children: [
          tree_category.Category(
            id: 221,
            name: 'Эмали НЦ',
            lft: 358,
            lvl: 3,
            rgt: 359,
            description: null,
            query: 'types=1163,1220',
            count: 0,
            children: [],
          ),
          tree_category.Category(
            id: 212,
            name: 'Колеры, колеровочные пасты',
            lft: 340,
            lvl: 3,
            rgt: 341,
            description: null,
            query: 'types=1155,1158,2705,1865,1267,1268',
            count: 0,
            children: [],
          ),
        ],
      ),
    ],
  );
}

tree_category.Category _createComplexCategoryTree() {
  return tree_category.Category(
    id: 1,
    name: 'Все товары',
    lft: 1,
    lvl: 1,
    rgt: 1000,
    description: null,
    query: null,
    count: 0,
    children: [
      tree_category.Category(
        id: 196,
        name: 'Строительство и ремонт',
        lft: 310,
        lvl: 2,
        rgt: 399,
        description: null,
        query: null,
        count: 0,
        children: [
          tree_category.Category(
            id: 211,
            name: 'Лакокрасочные материалы',
            lft: 339,
            lvl: 3,
            rgt: 362,
            description: null,
            query: null,
            count: 0,
            children: [
              tree_category.Category(
                id: 221,
                name: 'Эмали НЦ',
                lft: 358,
                lvl: 3,
                rgt: 359,
                description: null,
                query: 'types=1163,1220',
                count: 0,
                children: [],
              ),
              tree_category.Category(
                id: 212,
                name: 'Колеры, колеровочные пасты',
                lft: 340,
                lvl: 3,
                rgt: 341,
                description: null,
                query: 'types=1155,1158,2705,1865,1267,1268',
                count: 0,
                children: [],
              ),
            ],
          ),
        ],
      ),
      tree_category.Category(
        id: 83,
        name: 'Гигиена и уход',
        lft: 100,
        lvl: 2,
        rgt: 200,
        description: null,
        query: null,
        count: 0,
        children: [
          tree_category.Category(
            id: 99,
            name: 'Туалетная бумага',
            lft: 150,
            lvl: 3,
            rgt: 151,
            description: null,
            query: null,
            count: 0,
            children: [],
          ),
        ],
      ),
    ],
  );
}

Product _createEnamelProduct() {
  return Product(
    title: 'Нитроэмаль Расцвет НЦ-132КП С золотисто-желтая 0.7 кг',
    barcodes: ['4605365042182', '4605365049587'],
    code: 102969,
    bcode: 102969,
    catalogId: 1,
    novelty: false,
    popular: true,
    isMarked: false,
    brand: null,
    manufacturer: null,
    colorImage: null,
    defaultImage: null,
    images: [],
    description: 'Высококачественная нитроэмаль',
    howToUse: null,
    ingredients: null,
    series: null,
    category: null,
    priceListCategoryId: null,
    amountInPackage: null,
    vendorCode: null,
    type: null,
    categoriesInstock: [
      Category(
        id: 221,
        name: 'Эмали НЦ',
        isPublish: true,
        description: null,
        query: null,
      ),
    ],
    numericCharacteristics: [],
    stringCharacteristics: [],
    boolCharacteristics: [],
    stockItems: [],
    canBuy: true,
  );
}

Product _createColorantProduct() {
  return Product(
    title: 'Колер универсальный синий 100 мл',
    barcodes: ['4601234567890'],
    code: 102970,
    bcode: 102970,
    catalogId: 1,
    novelty: false,
    popular: false,
    isMarked: false,
    brand: null,
    manufacturer: null,
    colorImage: null,
    defaultImage: null,
    images: [],
    description: 'Универсальный колер для смешивания красок',
    howToUse: null,
    ingredients: null,
    series: null,
    category: null,
    priceListCategoryId: null,
    amountInPackage: null,
    vendorCode: null,
    type: null,
    categoriesInstock: [
      Category(
        id: 212,
        name: 'Колеры, колеровочные пасты',
        isPublish: true,
        description: null,
        query: null,
      ),
    ],
    numericCharacteristics: [],
    stringCharacteristics: [],
    boolCharacteristics: [],
    stockItems: [],
    canBuy: true,
  );
}

Product _createToiletPaperProduct() {
  return Product(
    title: 'Туалетная бумага YOKO Takeshi Бамбук 3-х слойная 10 рулонов',
    barcodes: ['4601234567891'],
    code: 170094,
    bcode: 170094,
    catalogId: 1,
    novelty: false,
    popular: true,
    isMarked: false,
    brand: null,
    manufacturer: null,
    colorImage: null,
    defaultImage: null,
    images: [],
    description: 'Мягкая туалетная бумага',
    howToUse: null,
    ingredients: null,
    series: null,
    category: null,
    priceListCategoryId: null,
    amountInPackage: null,
    vendorCode: null,
    type: null,
    categoriesInstock: [
      Category(
        id: 99,
        name: 'Туалетная бумага',
        isPublish: true,
        description: null,
        query: null,
      ),
    ],
    numericCharacteristics: [],
    stringCharacteristics: [],
    boolCharacteristics: [],
    stockItems: [],
    canBuy: true,
  );
}

Product _createMultiCategoryProduct() {
  return Product(
    title: 'Универсальная краска для внутренних работ',
    barcodes: ['4609999999999'],
    code: 102971,
    bcode: 102971,
    catalogId: 1,
    novelty: true,
    popular: true,
    isMarked: false,
    brand: null,
    manufacturer: null,
    colorImage: null,
    defaultImage: null,
    images: [],
    description: 'Краска для внутренних работ на любой поверхности',
    howToUse: null,
    ingredients: null,
    series: null,
    category: null,
    priceListCategoryId: null,
    amountInPackage: null,
    vendorCode: null,
    type: null,
    categoriesInstock: [
      Category(
        id: 221,
        name: 'Эмали НЦ',
        isPublish: true,
        description: null,
        query: null,
      ),
      Category(
        id: 212,
        name: 'Колеры, колеровочные пасты',
        isPublish: true,
        description: null,
        query: null,
      ),
    ],
    numericCharacteristics: [],
    stringCharacteristics: [],
    boolCharacteristics: [],
    stockItems: [],
    canBuy: true,
  );
}