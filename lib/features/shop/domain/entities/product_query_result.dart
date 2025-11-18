import 'package:fieldforce/features/shop/domain/entities/product_query.dart';

/// Wrapper returned by the product pipeline, keeping pagination metadata in one
/// place so both offline Drift and future remote APIs can share the same
/// contract.
class ProductQueryResult<T> {
  final List<T> items;
  final bool hasMore;
  final int offset;
  final int limit;
  final int? totalCount;
  final ProductQuery appliedQuery;

  const ProductQueryResult({
    required this.items,
    required this.hasMore,
    required this.offset,
    required this.limit,
    required this.appliedQuery,
    this.totalCount,
  });

    factory ProductQueryResult.empty(ProductQuery query) => ProductQueryResult<T>(
      items: List<T>.empty(growable: false),
        hasMore: false,
        offset: query.offset,
        limit: query.limit,
        appliedQuery: query,
        totalCount: 0,
      );

  int get nextOffset => offset + items.length;

  ProductQueryResult<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? offset,
    int? limit,
    int? totalCount,
    ProductQuery? appliedQuery,
  }) {
    return ProductQueryResult<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      totalCount: totalCount ?? this.totalCount,
      appliedQuery: appliedQuery ?? this.appliedQuery,
    );
  }
}
