
/// Unified DTO describing how product lists should be filtered and paginated.
///
/// The structure mirrors the parameters we expect from the backend filter
/// service, so we can serialize it for remote calls later. For now we only
/// use a subset (category scope, search text, allowed codes) but leaving the
/// rest makes Phase 2 easier.
class ProductQuery {
  final String? searchText;
  final int? baseCategoryId;
  final List<int> scopedCategoryIds;
  final List<int>? allowedProductCodes;
  final List<int> brandIds;
  final List<int> manufacturerIds;
  final List<int> seriesIds;
  final List<int> productTypeIds;
  final bool onlyNovelty;
  final bool onlyPopular;
  final bool requireStock;
  final bool includeArchived;
  final int offset;
  final int limit;

  const ProductQuery({
    this.searchText,
    this.baseCategoryId,
    this.scopedCategoryIds = const <int>[],
    this.allowedProductCodes,
    this.brandIds = const <int>[],
    this.manufacturerIds = const <int>[],
    this.seriesIds = const <int>[],
    this.productTypeIds = const <int>[],
    this.onlyNovelty = false,
    this.onlyPopular = false,
    this.requireStock = true,
    this.includeArchived = false,
    this.offset = 0,
    this.limit = 20,
  });

  factory ProductQuery.initial({int limit = 20}) => ProductQuery(limit: limit);

  bool get hasSearchText => (searchText?.trim().isNotEmpty ?? false);

  bool get hasScopedCategories => scopedCategoryIds.isNotEmpty;

  bool get hasFacetFilters => brandIds.isNotEmpty ||
      manufacturerIds.isNotEmpty ||
      seriesIds.isNotEmpty ||
      productTypeIds.isNotEmpty ||
      (allowedProductCodes != null) ||
      onlyNovelty ||
      onlyPopular;

  ProductQuery copyWith({
    String? searchText,
    bool clearSearchText = false,
    int? baseCategoryId,
    List<int>? scopedCategoryIds,
    List<int>? allowedProductCodes,
    bool clearAllowedProductCodes = false,
    List<int>? brandIds,
    List<int>? manufacturerIds,
    List<int>? seriesIds,
    List<int>? productTypeIds,
    bool? onlyNovelty,
    bool? onlyPopular,
    bool? requireStock,
    bool? includeArchived,
    int? offset,
    int? limit,
  }) {
    return ProductQuery(
      searchText: clearSearchText ? null : (searchText ?? this.searchText),
      baseCategoryId: baseCategoryId ?? this.baseCategoryId,
        scopedCategoryIds: scopedCategoryIds ?? this.scopedCategoryIds,
        allowedProductCodes: clearAllowedProductCodes
          ? null
          : (allowedProductCodes ?? this.allowedProductCodes),
      brandIds: brandIds ?? this.brandIds,
      manufacturerIds: manufacturerIds ?? this.manufacturerIds,
      seriesIds: seriesIds ?? this.seriesIds,
      productTypeIds: productTypeIds ?? this.productTypeIds,
      onlyNovelty: onlyNovelty ?? this.onlyNovelty,
      onlyPopular: onlyPopular ?? this.onlyPopular,
      requireStock: requireStock ?? this.requireStock,
      includeArchived: includeArchived ?? this.includeArchived,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'searchText': searchText,
        'baseCategoryId': baseCategoryId,
        'scopedCategoryIds': scopedCategoryIds,
        'allowedProductCodes': allowedProductCodes,
        'brandIds': brandIds,
        'manufacturerIds': manufacturerIds,
        'seriesIds': seriesIds,
        'productTypeIds': productTypeIds,
        'onlyNovelty': onlyNovelty,
        'onlyPopular': onlyPopular,
        'requireStock': requireStock,
        'includeArchived': includeArchived,
        'offset': offset,
        'limit': limit,
      };

  factory ProductQuery.fromJson(Map<String, dynamic> json) {
    List<int> _readList(dynamic value) {
      if (value == null) return const <int>[];
      if (value is List) {
        return value.whereType<num>().map((e) => e.toInt()).toList(growable: false);
      }
      return const <int>[];
    }

    return ProductQuery(
      searchText: json['searchText'] as String?,
      baseCategoryId: json['baseCategoryId'] as int?,
      scopedCategoryIds: _readList(json['scopedCategoryIds']),
        allowedProductCodes: json['allowedProductCodes'] == null
          ? null
          : _readList(json['allowedProductCodes']),
      brandIds: _readList(json['brandIds']),
      manufacturerIds: _readList(json['manufacturerIds']),
      seriesIds: _readList(json['seriesIds']),
      productTypeIds: _readList(json['productTypeIds']),
      onlyNovelty: json['onlyNovelty'] as bool? ?? false,
      onlyPopular: json['onlyPopular'] as bool? ?? false,
      requireStock: json['requireStock'] as bool? ?? true,
      includeArchived: json['includeArchived'] as bool? ?? false,
      offset: json['offset'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };

    void putList(String key, List<int> values) {
      if (values.isEmpty) return;
      params[key] = values.join(',');
    }

    if (hasSearchText) {
      params['search'] = searchText!.trim();
    }

    if (baseCategoryId != null) {
      params['baseCategoryId'] = baseCategoryId.toString();
    }

    putList('scopedCategoryIds', scopedCategoryIds);
    if (allowedProductCodes != null) {
      putList('allowedProductCodes', allowedProductCodes!);
    }
    putList('brandIds', brandIds);
    putList('manufacturerIds', manufacturerIds);
    putList('seriesIds', seriesIds);
    putList('productTypeIds', productTypeIds);

    if (onlyNovelty) params['onlyNovelty'] = 'true';
    if (onlyPopular) params['onlyPopular'] = 'true';
    if (!requireStock) params['requireStock'] = 'false';
    if (includeArchived) params['includeArchived'] = 'true';

    return params;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductQuery) return false;
    return searchText == other.searchText &&
      baseCategoryId == other.baseCategoryId &&
      _listEquals(scopedCategoryIds, other.scopedCategoryIds) &&
      _listsEqualNullable(allowedProductCodes, other.allowedProductCodes) &&
      _listEquals(brandIds, other.brandIds) &&
      _listEquals(manufacturerIds, other.manufacturerIds) &&
      _listEquals(seriesIds, other.seriesIds) &&
      _listEquals(productTypeIds, other.productTypeIds) &&
        onlyNovelty == other.onlyNovelty &&
        onlyPopular == other.onlyPopular &&
        requireStock == other.requireStock &&
        includeArchived == other.includeArchived &&
        offset == other.offset &&
        limit == other.limit;
  }

  @override
  int get hashCode => Object.hash(
        searchText,
        baseCategoryId,
        _listHash(scopedCategoryIds),
        _nullableListHash(allowedProductCodes),
        _listHash(brandIds),
        _listHash(manufacturerIds),
        _listHash(seriesIds),
        _listHash(productTypeIds),
        onlyNovelty,
        onlyPopular,
        requireStock,
        includeArchived,
        offset,
        limit,
      );

  @override
  String toString() {
    return 'ProductQuery(searchText: $searchText, baseCategoryId: $baseCategoryId, scopedCategoryIds: $scopedCategoryIds, allowedProductCodes: $allowedProductCodes, brands: $brandIds, manufacturers: $manufacturerIds, series: $seriesIds, productTypes: $productTypeIds, onlyNovelty: $onlyNovelty, onlyPopular: $onlyPopular, requireStock: $requireStock, includeArchived: $includeArchived, offset: $offset, limit: $limit)';
  }
}

bool _listsEqualNullable(List<int>? a, List<int>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == null && b == null;
  return _listEquals(a, b);
}

int _nullableListHash(List<int>? value) {
  if (value == null) return 0;
  return _listHash(value);
}

bool _listEquals(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHash(List<int> value) {
  if (value.isEmpty) return 0;
  return Object.hashAll(value);
}
