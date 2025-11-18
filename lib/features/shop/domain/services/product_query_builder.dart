import 'package:fieldforce/features/shop/domain/entities/product_query.dart';

/// Helper that centralizes how UI/bloc inputs turn into a normalized
/// [ProductQuery]. It keeps pagination, deduplicates filters, and allows the
/// same builder to be reused once remote APIs appear.
class ProductQueryBuilder {
  const ProductQueryBuilder();

  /// Creates a minimal query for category listing screens.
  ProductQuery forCategory({
    required int categoryId,
    List<int>? scopedCategoryIds,
    List<int>? allowedProductCodes,
    int offset = 0,
    int limit = 20,
  }) {
    return ProductQuery(
      baseCategoryId: categoryId,
      scopedCategoryIds: _normalizeList(scopedCategoryIds),
      allowedProductCodes:
          allowedProductCodes == null ? null : _normalizeList(allowedProductCodes),
      offset: offset,
      limit: limit,
    );
  }

  /// Creates a minimal query for search screens.
  ProductQuery forSearch({
    required String searchText,
    int? categoryId,
    List<int>? scopedCategoryIds,
    List<int>? allowedProductCodes,
    int offset = 0,
    int limit = 20,
  }) {
    return ProductQuery(
      searchText: searchText.trim().isEmpty ? null : searchText.trim(),
      baseCategoryId: categoryId,
      scopedCategoryIds: _normalizeList(scopedCategoryIds),
      allowedProductCodes:
          allowedProductCodes == null ? null : _normalizeList(allowedProductCodes),
      offset: offset,
      limit: limit,
      requireStock: false,
    );
  }

  /// Returns a builder seeded from an existing query.
  ProductQueryBuilderSession edit(ProductQuery base) {
    return ProductQueryBuilderSession(base);
  }

  List<int> _normalizeList(List<int>? values) {
    if (values == null || values.isEmpty) return const <int>[];
    final unique = values.toSet().toList()..sort();
    return List<int>.unmodifiable(unique);
  }
}

/// Mutable builder session used to compose queries incrementally.
class ProductQueryBuilderSession {
  String? _searchText;
  int? _baseCategoryId;
  List<int> _scopedCategoryIds;
  List<int>? _allowedProductCodes;
  List<int> _brandIds;
  List<int> _manufacturerIds;
  List<int> _seriesIds;
  List<int> _productTypeIds;
  List<int> _priceCategoryIds;
  bool _onlyNovelty;
  bool _onlyPopular;
  bool _requireStock;
  bool _includeArchived;
  int _offset;
  int _limit;

  ProductQueryBuilderSession(ProductQuery seed)
      : _searchText = seed.searchText,
        _baseCategoryId = seed.baseCategoryId,
        _scopedCategoryIds = List<int>.from(seed.scopedCategoryIds),
        _allowedProductCodes = seed.allowedProductCodes == null
          ? null
          : List<int>.from(seed.allowedProductCodes!),
        _brandIds = List<int>.from(seed.brandIds),
        _manufacturerIds = List<int>.from(seed.manufacturerIds),
        _seriesIds = List<int>.from(seed.seriesIds),
        _productTypeIds = List<int>.from(seed.productTypeIds),
        _priceCategoryIds = List<int>.from(seed.priceCategoryIds),
        _onlyNovelty = seed.onlyNovelty,
        _onlyPopular = seed.onlyPopular,
        _requireStock = seed.requireStock,
        _includeArchived = seed.includeArchived,
        _offset = seed.offset,
        _limit = seed.limit;

  ProductQueryBuilderSession setSearchText(String? value) {
    _searchText = value?.trim().isEmpty ?? true ? null : value!.trim();
    return this;
  }

  ProductQueryBuilderSession setBaseCategory(int? categoryId) {
    _baseCategoryId = categoryId;
    return this;
  }

  ProductQueryBuilderSession setScopedCategories(List<int>? ids) {
    _scopedCategoryIds = _normalizeList(ids);
    return this;
  }

  ProductQueryBuilderSession setAllowedProductCodes(List<int>? codes) {
    _allowedProductCodes = codes == null ? null : _normalizeList(codes);
    return this;
  }

  ProductQueryBuilderSession clearAllowedProductCodes() {
    _allowedProductCodes = null;
    return this;
  }

  ProductQueryBuilderSession setBrandIds(List<int>? ids) {
    _brandIds = _normalizeList(ids);
    return this;
  }

  ProductQueryBuilderSession setManufacturerIds(List<int>? ids) {
    _manufacturerIds = _normalizeList(ids);
    return this;
  }

  ProductQueryBuilderSession setSeriesIds(List<int>? ids) {
    _seriesIds = _normalizeList(ids);
    return this;
  }

  ProductQueryBuilderSession setProductTypeIds(List<int>? ids) {
    _productTypeIds = _normalizeList(ids);
    return this;
  }

  ProductQueryBuilderSession setPriceCategoryIds(List<int>? ids) {
    _priceCategoryIds = _normalizeList(ids);
    return this;
  }

  ProductQueryBuilderSession setOnlyNovelty(bool value) {
    _onlyNovelty = value;
    if (value) {
      _onlyPopular = false;
    }
    return this;
  }

  ProductQueryBuilderSession setOnlyPopular(bool value) {
    _onlyPopular = value;
    if (value) {
      _onlyNovelty = false;
    }
    return this;
  }

  ProductQueryBuilderSession setRequireStock(bool value) {
    _requireStock = value;
    return this;
  }

  ProductQueryBuilderSession setIncludeArchived(bool value) {
    _includeArchived = value;
    return this;
  }

  ProductQueryBuilderSession resetPagination() {
    _offset = 0;
    return this;
  }

  ProductQueryBuilderSession setPagination({int? offset, int? limit}) {
    if (offset != null) _offset = offset;
    if (limit != null) _limit = limit;
    return this;
  }

  ProductQuery build() {
    return ProductQuery(
      searchText: _searchText,
      baseCategoryId: _baseCategoryId,
      scopedCategoryIds: List<int>.unmodifiable(_scopedCategoryIds),
        allowedProductCodes: _allowedProductCodes == null
          ? null
          : List<int>.unmodifiable(_allowedProductCodes!),
      brandIds: List<int>.unmodifiable(_brandIds),
      manufacturerIds: List<int>.unmodifiable(_manufacturerIds),
      seriesIds: List<int>.unmodifiable(_seriesIds),
      productTypeIds: List<int>.unmodifiable(_productTypeIds),
      priceCategoryIds: List<int>.unmodifiable(_priceCategoryIds),
      onlyNovelty: _onlyNovelty,
      onlyPopular: _onlyPopular,
      requireStock: _requireStock,
      includeArchived: _includeArchived,
      offset: _offset,
      limit: _limit,
    );
  }

  List<int> _normalizeList(List<int>? values) {
    if (values == null || values.isEmpty) return <int>[];
    final unique = values.toSet().toList()..sort();
    return unique;
  }
}
