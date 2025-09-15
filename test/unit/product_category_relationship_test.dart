import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart' as tree_category;

void main() {
  group('Product Category Relationship Tests', () {
    test('should create products with categoriesInstock', () {
      // Arrange & Act
      final enamelProduct = _createEnamelProduct();
      final colorantProduct = _createColorantProduct();

      // Assert
      expect(enamelProduct.categoriesInstock.length, 1);
      expect(enamelProduct.categoriesInstock[0].id, 221);
      expect(enamelProduct.categoriesInstock[0].name, 'Эмали НЦ');

      expect(colorantProduct.categoriesInstock.length, 1);
      expect(colorantProduct.categoriesInstock[0].id, 212);
      expect(colorantProduct.categoriesInstock[0].name, 'Колеры, колеровочные пасты');
    });

    test('should simulate hierarchical product search', () {
      // Arrange
      final products = [_createEnamelProduct(), _createColorantProduct()];
      final constructionCategory = _createConstructionCategoryTree();

      // Act - симуляция поиска продуктов в родительской категории
      final productsInConstruction = _findProductsInCategoryAndDescendants(
        products,
        constructionCategory,
      );

      final productsInPaintMaterials = _findProductsInCategoryAndDescendants(
        products,
        constructionCategory.findById(211)!,
      );

      // Assert
      expect(productsInConstruction.length, 2); // Оба продукта должны быть найдены
      expect(productsInPaintMaterials.length, 2); // Оба продукта в подкатегории

      // Проверим, что продукты найдены правильно
      final enamelProducts = productsInConstruction
          .where((p) => p.categoriesInstock.any((c) => c.id == 221))
          .toList();
      final colorantProducts = productsInConstruction
          .where((p) => p.categoriesInstock.any((c) => c.id == 212))
          .toList();

      expect(enamelProducts.length, 1);
      expect(colorantProducts.length, 1);
    });

    test('should handle products with multiple categories', () {
      // Arrange
      final multiCategoryProduct = _createMultiCategoryProduct();
      final constructionCategory = _createConstructionCategoryTree();

      // Act
      final foundProducts = _findProductsInCategoryAndDescendants(
        [multiCategoryProduct],
        constructionCategory,
      );

      // Assert
      expect(foundProducts.length, 1);
      expect(foundProducts[0].categoriesInstock.length, 2);
    });
  });

  group('Category Hierarchy Product Count Tests', () {
    test('should calculate product counts for category hierarchy', () {
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
  });
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