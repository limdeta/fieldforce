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
}
