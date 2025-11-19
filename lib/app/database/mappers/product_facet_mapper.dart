// lib/app/database/mappers/product_facet_mapper.dart

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';

class ProductFacetMapper {
  static ProductFacetsCompanion toFacetCompanion(Product product) {
    return ProductFacetsCompanion(
      productCode: Value(product.code),
      brandId: Value(product.brand?.id),
      brandName: Value(product.brand?.name),
      brandSearchPriority: Value(product.brand?.searchPriority ?? 0),
      manufacturerId: Value(product.manufacturer?.id),
      manufacturerName: Value(product.manufacturer?.name),
      seriesId: Value(product.series?.id),
      seriesName: Value(product.series?.name),
      typeId: Value(product.type?.id),
      typeName: Value(product.type?.name),
      novelty: Value(product.novelty),
      popular: Value(product.popular),
      canBuy: Value(product.canBuy),
      createdAt: const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }

  static List<ProductCategoryFacetsCompanion> toCategoryCompanions(Product product) {
    if (product.categoriesInstock.isEmpty) {
      return <ProductCategoryFacetsCompanion>[];
    }

    return product.categoriesInstock.map((category) {
      return ProductCategoryFacetsCompanion(
        id: const Value.absent(),
        productCode: Value(product.code),
        categoryId: Value(category.id),
        categoryName: Value(category.name),
        createdAt: Value(DateTime.now()),
      );
    }).toList();
  }

  /// Создаёт companions для характеристик продукта (bool, string, numeric).
  /// Phase 3.1: bool характеристики
  /// Phase 3.2: string характеристики
  /// Phase 3.3: numeric характеристики
  static List<ProductCharacteristicFacetsCompanion> toCharacteristicCompanions(Product product) {
    final companions = <ProductCharacteristicFacetsCompanion>[];
    
    // Bool characteristics
    for (final char in product.boolCharacteristics) {
      companions.add(
        ProductCharacteristicFacetsCompanion(
          productCode: Value(product.code),
          attributeId: Value(char.attributeId),
          attributeName: Value(char.attributeName),
          charType: const Value('bool'),
          boolValue: Value(char.value == true ? 1 : 0),
          stringValue: const Value.absent(),
          numericValue: const Value.absent(),
          adaptValue: Value(char.adaptValue),
          createdAt: Value(DateTime.now()),
        ),
      );
    }
    
    // String characteristics (Phase 3.2)
    for (final char in product.stringCharacteristics) {
      companions.add(
        ProductCharacteristicFacetsCompanion(
          productCode: Value(product.code),
          attributeId: Value(char.attributeId),
          attributeName: Value(char.attributeName),
          charType: const Value('string'),
          boolValue: const Value.absent(),
          stringValue: Value(char.value as int), // ID значения из справочника
          numericValue: const Value.absent(),
          adaptValue: Value(char.adaptValue), // Человекочитаемое название
          createdAt: Value(DateTime.now()),
        ),
      );
    }
    
    // Numeric characteristics (Phase 3.3)
    for (final char in product.numericCharacteristics) {
      companions.add(
        ProductCharacteristicFacetsCompanion(
          productCode: Value(product.code),
          attributeId: Value(char.attributeId),
          attributeName: Value(char.attributeName),
          charType: const Value('numeric'),
          boolValue: const Value.absent(),
          stringValue: const Value.absent(),
          numericValue: Value(char.value as double?), // Числовое значение
          adaptValue: Value(char.adaptValue), // Единица измерения или описание
          createdAt: Value(DateTime.now()),
        ),
      );
    }
    
    return companions;
  }
}
