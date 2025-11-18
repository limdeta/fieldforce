import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/shop/domain/entities/facet.dart';

class FacetSelectionBadge extends Equatable {
  final String groupKey;
  final String label;
  final Object value;

  const FacetSelectionBadge({
    required this.groupKey,
    required this.label,
    required this.value,
  });

  @override
  List<Object?> get props => [groupKey, label, value];
}

const _copySentinel = Object();

class FacetFilterState extends Equatable {
  final int? categoryId;
  final bool isLoading;
  final bool isApplying;
  final List<FacetGroup> groups;
  final FacetFilter workingFilter;
  final FacetFilter appliedFilter;
  final List<FacetSelectionBadge> appliedBadges;
  final String? errorMessage;
  final String? applyError;
  final bool hasLoadedOnce;

  const FacetFilterState({
    this.categoryId,
    this.isLoading = false,
    this.isApplying = false,
    this.groups = const [],
    this.workingFilter = const FacetFilter(),
    this.appliedFilter = const FacetFilter(),
    this.appliedBadges = const [],
    this.errorMessage,
    this.applyError,
    this.hasLoadedOnce = false,
  });

  bool get hasActiveFilters => appliedBadges.isNotEmpty;

  FacetFilterState copyWith({
    Object? categoryId = _copySentinel,
    bool? isLoading,
    bool? isApplying,
    List<FacetGroup>? groups,
    FacetFilter? workingFilter,
    FacetFilter? appliedFilter,
    List<FacetSelectionBadge>? appliedBadges,
    String? errorMessage,
    String? applyError,
    bool? hasLoadedOnce,
    bool resetError = false,
    bool resetApplyError = false,
  }) {
    return FacetFilterState(
      categoryId: identical(categoryId, _copySentinel) ? this.categoryId : categoryId as int?,
      isLoading: isLoading ?? this.isLoading,
      isApplying: isApplying ?? this.isApplying,
      groups: groups ?? this.groups,
      workingFilter: workingFilter ?? this.workingFilter,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      appliedBadges: appliedBadges ?? this.appliedBadges,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
      applyError: resetApplyError ? null : (applyError ?? this.applyError),
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        isLoading,
        isApplying,
        groups,
        workingFilter,
        appliedFilter,
        appliedBadges,
        errorMessage,
        applyError,
        hasLoadedOnce,
      ];
}
