// lib/features/shop/domain/entities/facet.dart

/// Тип группы фасетов
enum FacetGroupType {
  list,
  toggle,
}

/// Значение фасета с количеством товаров
class FacetValue {
  final Object value;
  final String label;
  final int count;
  final bool selected;

  const FacetValue({
    required this.value,
    required this.label,
    required this.count,
    this.selected = false,
  });

  FacetValue copyWith({
    bool? selected,
    int? count,
  }) {
    return FacetValue(
      value: value,
      label: label,
      count: count ?? this.count,
      selected: selected ?? this.selected,
    );
  }
}

/// Группа фасетов (например, бренды, категории)
class FacetGroup {
  final String key;
  final String title;
  final FacetGroupType type;
  final List<FacetValue> values;

  const FacetGroup({
    required this.key,
    required this.title,
    required this.type,
    required this.values,
  });
}

/// DTO с выбранными фильтрами для расчёта фасетов
class FacetFilter {
  final int? baseCategoryId;
  final List<int> scopeCategoryIds;
  final List<int> selectedCategoryIds;
  final List<int> brandIds;
  final List<int> manufacturerIds;
  final List<int> seriesIds;
  final List<int> typeIds;
  final bool onlyNovelty;
  final bool onlyPopular;

  const FacetFilter({
    this.baseCategoryId,
    this.scopeCategoryIds = const [],
    this.selectedCategoryIds = const [],
    this.brandIds = const [],
    this.manufacturerIds = const [],
    this.seriesIds = const [],
    this.typeIds = const [],
    this.onlyNovelty = false,
    this.onlyPopular = false,
  });

  FacetFilter copyWith({
    int? baseCategoryId,
    List<int>? scopeCategoryIds,
    List<int>? selectedCategoryIds,
    List<int>? brandIds,
    List<int>? manufacturerIds,
    List<int>? seriesIds,
    List<int>? typeIds,
    bool? onlyNovelty,
    bool? onlyPopular,
  }) {
    return FacetFilter(
      baseCategoryId: baseCategoryId ?? this.baseCategoryId,
      scopeCategoryIds: scopeCategoryIds ?? this.scopeCategoryIds,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      brandIds: brandIds ?? this.brandIds,
      manufacturerIds: manufacturerIds ?? this.manufacturerIds,
      seriesIds: seriesIds ?? this.seriesIds,
      typeIds: typeIds ?? this.typeIds,
      onlyNovelty: onlyNovelty ?? this.onlyNovelty,
      onlyPopular: onlyPopular ?? this.onlyPopular,
    );
  }

  bool get isEmpty =>
      brandIds.isEmpty &&
      manufacturerIds.isEmpty &&
      seriesIds.isEmpty &&
      typeIds.isEmpty &&
      selectedCategoryIds.isEmpty &&
      !onlyNovelty &&
      !onlyPopular;
}
