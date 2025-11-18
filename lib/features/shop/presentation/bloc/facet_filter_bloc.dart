import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_facets_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/resolve_facet_product_codes_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class FacetFilterBloc extends Bloc<FacetFilterEvent, FacetFilterState> {
  FacetFilterBloc({
    required GetFacetsUseCase getFacetsUseCase,
    required ResolveFacetProductCodesUseCase resolveFacetProductCodesUseCase,
    required CategoryRepository categoryRepository,
  }) : _getFacetsUseCase = getFacetsUseCase,
       _resolveFacetProductCodesUseCase = resolveFacetProductCodesUseCase,
       _categoryRepository = categoryRepository,
       super(const FacetFilterState()) {
    on<FacetFilterCategoryChanged>(_onCategoryChanged);
    on<FacetFilterSheetOpened>(_onSheetOpened);
    on<FacetFilterValueToggled>(_onValueToggled);
    on<FacetFilterCleared>(_onCleared);
    on<FacetFilterApplied>(_onApplied);
    on<FacetFilterEditingCancelled>(_onEditingCancelled);
  }

  final GetFacetsUseCase _getFacetsUseCase;
  final ResolveFacetProductCodesUseCase _resolveFacetProductCodesUseCase;
  final CategoryRepository _categoryRepository;
  final Logger _logger = Logger('FacetFilterBloc');

  static const int _globalCacheKey = -1;
  final Map<int, FacetFilter> _appliedFiltersCache = <int, FacetFilter>{};

  int _cacheKey(int? categoryId) => categoryId ?? _globalCacheKey;

  Future<void> _onCategoryChanged(
    FacetFilterCategoryChanged event,
    Emitter<FacetFilterState> emit,
  ) async {
    final categoryId = event.categoryId;
    if (!event.forceReload &&
        state.categoryId == categoryId &&
        state.hasLoadedOnce) {
      _logger.info('Skip category reload for $categoryId (already loaded)');
      return;
    }

    _logger.info(
      'Loading facets for category=$categoryId forceReload=${event.forceReload}',
    );

    emit(
      state.copyWith(
        isLoading: true,
        categoryId: categoryId,
        resetError: true,
        resetApplyError: true,
      ),
    );

    List<Category> descendants = const <Category>[];
    if (categoryId != null) {
      final scopeResult = await _categoryRepository.getAllDescendants(
        categoryId,
      );
      if (scopeResult.isLeft()) {
        final message = scopeResult.fold(
          (failure) => failure.message,
          (_) => 'Не удалось загрузить категории',
        );
        _logger.warning(
          'Failed to resolve category scope for $categoryId: $message',
        );
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: message,
            categoryId: categoryId,
            groups: const <FacetGroup>[],
            workingFilter: state.workingFilter.copyWith(
              baseCategoryId: categoryId,
              scopeCategoryIds: [categoryId],
              selectedCategoryIds: const <int>[],
            ),
            appliedFilter: state.appliedFilter.copyWith(
              baseCategoryId: categoryId,
              scopeCategoryIds: [categoryId],
              selectedCategoryIds: const <int>[],
            ),
            hasLoadedOnce: true,
          ),
        );
        return;
      }
      descendants = scopeResult.getOrElse(() => <Category>[]);
    }

    final scopeIds = <int>{};
    if (categoryId != null) {
      scopeIds.add(categoryId);
      scopeIds.addAll(descendants.map((c) => c.id));
    }

    final cacheKey = _cacheKey(categoryId);
    final cachedFilter = _appliedFiltersCache[cacheKey];
    final normalizedApplied = (cachedFilter ?? const FacetFilter()).copyWith(
      baseCategoryId: categoryId,
      scopeCategoryIds: scopeIds.toList(growable: false),
    );

    if (cachedFilter != null) {
      _logger.info(
        'Restored cached filter for category=$categoryId: ${_filterSummary(cachedFilter)}',
      );
    }

    final groupsResult = await _getFacetsUseCase(normalizedApplied);
    if (groupsResult.isLeft()) {
      final message = groupsResult.fold(
        (failure) => failure.message,
        (_) => 'Не удалось загрузить фасеты',
      );
      _logger.warning(
        'Failed to load facets for category $categoryId: $message',
      );
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: message,
          categoryId: categoryId,
          workingFilter: normalizedApplied,
          appliedFilter: normalizedApplied,
          groups: const <FacetGroup>[],
          appliedBadges: const <FacetSelectionBadge>[],
          hasLoadedOnce: true,
        ),
      );
      return;
    }

    final rawGroups = groupsResult.getOrElse(() => const <FacetGroup>[]);
    final filteredGroups = rawGroups
        .where((group) => group.key != 'categories')
        .toList(growable: false);
    final groups = _syncGroupSelections(filteredGroups, normalizedApplied);
    final badges = _buildBadges(groups);

    emit(
      state.copyWith(
        isLoading: false,
        categoryId: categoryId,
        workingFilter: normalizedApplied,
        appliedFilter: normalizedApplied,
        groups: groups,
        appliedBadges: badges,
        hasLoadedOnce: true,
      ),
    );

    _logger.info(
      'Facets loaded for category=$categoryId groups=${groups.length} badges=${badges.length}',
    );
  }

  void _onSheetOpened(
    FacetFilterSheetOpened event,
    Emitter<FacetFilterState> emit,
  ) {
    emit(
      state.copyWith(
        workingFilter: state.appliedFilter,
        groups: _syncGroupSelections(state.groups, state.appliedFilter),
        resetApplyError: true,
      ),
    );
  }

  void _onValueToggled(
    FacetFilterValueToggled event,
    Emitter<FacetFilterState> emit,
  ) {
    final updatedFilter = _updateFilterForValue(
      state.workingFilter,
      event.groupKey,
      event.value,
    );
    if (identical(updatedFilter, state.workingFilter)) {
      return;
    }

    final updatedGroups = _syncGroupSelections(state.groups, updatedFilter);
    emit(
      state.copyWith(
        workingFilter: updatedFilter,
        groups: updatedGroups,
        resetApplyError: true,
      ),
    );
  }

  void _onCleared(FacetFilterCleared event, Emitter<FacetFilterState> emit) {
    final cleared = _clearSelections(state.workingFilter);
    final updatedGroups = _syncGroupSelections(state.groups, cleared);
    emit(
      state.copyWith(
        workingFilter: cleared,
        groups: updatedGroups,
        resetApplyError: true,
      ),
    );
  }

  Future<void> _onApplied(
    FacetFilterApplied event,
    Emitter<FacetFilterState> emit,
  ) async {
    if (!state.hasLoadedOnce) {
      _logger.info('Facet apply ignored: category not loaded yet');
      return;
    }
    final categoryId = state.categoryId;
    _logger.info(
      'Applying facet filter for category=$categoryId -> ${_filterSummary(state.workingFilter)}',
    );

    emit(state.copyWith(isApplying: true, resetApplyError: true));

    final resolveResult = await _resolveFacetProductCodesUseCase(
      state.workingFilter,
    );
    if (resolveResult.isLeft()) {
      final failure = resolveResult.fold((l) => l, (_) => null);
      _logger.warning(
        'Failed to resolve product codes for category $categoryId: ${failure?.message}',
      );
      emit(
        state.copyWith(
          isApplying: false,
          applyError: failure?.message ?? 'Не удалось применить фильтр',
        ),
      );
      return;
    }

    final codes = resolveResult.getOrElse(() => const <int>[]);
    final normalizedCodes = state.workingFilter.isEmpty
        ? null
        : List<int>.unmodifiable(codes);

    _logger.info(
      'Resolved allowed product codes for category=$categoryId: ${normalizedCodes?.length ?? 0}',
    );

    final appliedFilter = state.workingFilter.copyWith(
      restrictedProductCodes: normalizedCodes,
    );

    final facetsResult = await _getFacetsUseCase(state.workingFilter);
    final refreshedGroups = facetsResult.fold(
      (_) => _syncGroupSelections(state.groups, appliedFilter),
      (groups) => _syncGroupSelections(groups, appliedFilter),
    );
    final refreshedBadges = _buildBadges(refreshedGroups);

    final cacheKey = _cacheKey(categoryId);
    _appliedFiltersCache[cacheKey] = appliedFilter;

    emit(
      state.copyWith(
        isApplying: false,
        appliedFilter: appliedFilter,
        workingFilter: appliedFilter,
        groups: refreshedGroups,
        appliedBadges: refreshedBadges,
        applyError: null,
      ),
    );

    _logger.info(
      'Facet apply completed for category=$categoryId badges=${refreshedBadges.length}',
    );
  }

  void _onEditingCancelled(
    FacetFilterEditingCancelled event,
    Emitter<FacetFilterState> emit,
  ) {
    final syncedGroups = _syncGroupSelections(
      state.groups,
      state.appliedFilter,
    );
    emit(
      state.copyWith(workingFilter: state.appliedFilter, groups: syncedGroups),
    );
  }

  FacetFilter _updateFilterForValue(
    FacetFilter filter,
    String groupKey,
    Object rawValue,
  ) {
    switch (groupKey) {
      case 'brands':
        final updated = _toggleListValue(filter.brandIds, rawValue);
        return updated == null ? filter : filter.copyWith(brandIds: updated);
      case 'manufacturers':
        final updated = _toggleListValue(filter.manufacturerIds, rawValue);
        return updated == null
            ? filter
            : filter.copyWith(manufacturerIds: updated);
      case 'series':
        final updated = _toggleListValue(filter.seriesIds, rawValue);
        return updated == null ? filter : filter.copyWith(seriesIds: updated);
      case 'types':
        final updated = _toggleListValue(filter.typeIds, rawValue);
        return updated == null ? filter : filter.copyWith(typeIds: updated);
      case 'priceCategories':
        final updated = _toggleListValue(filter.priceCategoryIds, rawValue);
        return updated == null
            ? filter
            : filter.copyWith(priceCategoryIds: updated);
      case 'categories':
        final value = _readInt(rawValue);
        if (value == null || !filter.scopeCategoryIds.contains(value)) {
          return filter;
        }
        final updated = _toggleListValue(filter.selectedCategoryIds, value);
        return updated == null
            ? filter
            : filter.copyWith(selectedCategoryIds: updated);
      case 'novelty':
        return filter.copyWith(onlyNovelty: !filter.onlyNovelty);
      case 'popular':
        return filter.copyWith(onlyPopular: !filter.onlyPopular);
      default:
        return filter;
    }
  }

  FacetFilter _clearSelections(FacetFilter filter) {
    return filter.copyWith(
      brandIds: const <int>[],
      manufacturerIds: const <int>[],
      seriesIds: const <int>[],
      typeIds: const <int>[],
      priceCategoryIds: const <int>[],
      selectedCategoryIds: const <int>[],
      onlyNovelty: false,
      onlyPopular: false,
      restrictedProductCodes: null,
    );
  }

  List<FacetGroup> _syncGroupSelections(
    List<FacetGroup> groups,
    FacetFilter filter,
  ) {
    return groups
        .map(
          (group) => FacetGroup(
            key: group.key,
            title: group.title,
            type: group.type,
            values: group.values
                .map(
                  (value) => value.copyWith(
                    selected: _isValueSelected(group.key, value.value, filter),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  bool _isValueSelected(String groupKey, Object value, FacetFilter filter) {
    final id = value is int ? value : null;
    switch (groupKey) {
      case 'brands':
        return id != null && filter.brandIds.contains(id);
      case 'manufacturers':
        return id != null && filter.manufacturerIds.contains(id);
      case 'series':
        return id != null && filter.seriesIds.contains(id);
      case 'types':
        return id != null && filter.typeIds.contains(id);
      case 'priceCategories':
        return id != null && filter.priceCategoryIds.contains(id);
      case 'categories':
        return id != null && filter.selectedCategoryIds.contains(id);
      case 'novelty':
        return filter.onlyNovelty;
      case 'popular':
        return filter.onlyPopular;
      default:
        return false;
    }
  }

  List<FacetSelectionBadge> _buildBadges(List<FacetGroup> groups) {
    final badges = <FacetSelectionBadge>[];
    for (final group in groups) {
      for (final value in group.values) {
        if (!value.selected) continue;
        badges.add(
          FacetSelectionBadge(
            groupKey: group.key,
            label: group.type == FacetGroupType.toggle
                ? group.title
                : value.label,
            value: value.value,
          ),
        );
      }
    }
    return badges;
  }

  List<int>? _toggleListValue(List<int> source, Object rawValue) {
    final value = _readInt(rawValue);
    if (value == null) {
      return null;
    }
    final next = List<int>.from(source);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    return next;
  }

  int? _readInt(Object rawValue) {
    if (rawValue is int) return rawValue;
    if (rawValue is num) return rawValue.toInt();
    return null;
  }

  String _filterSummary(FacetFilter filter) {
    return 'brands=${filter.brandIds.length}/manufacturers=${filter.manufacturerIds.length}/series=${filter.seriesIds.length}/types=${filter.typeIds.length}/priceCategories=${filter.priceCategoryIds.length}/categories=${filter.selectedCategoryIds.length}/novelty=${filter.onlyNovelty}/popular=${filter.onlyPopular}';
  }
}
