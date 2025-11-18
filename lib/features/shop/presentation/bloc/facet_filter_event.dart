import 'package:equatable/equatable.dart';

abstract class FacetFilterEvent extends Equatable {
  const FacetFilterEvent();

  @override
  List<Object?> get props => [];
}

class FacetFilterCategoryChanged extends FacetFilterEvent {
  final int? categoryId;
  final bool forceReload;

  const FacetFilterCategoryChanged({
    this.categoryId,
    this.forceReload = false,
  });

  @override
  List<Object?> get props => [categoryId, forceReload];
}

class FacetFilterSheetOpened extends FacetFilterEvent {
  const FacetFilterSheetOpened();
}

class FacetFilterValueToggled extends FacetFilterEvent {
  final String groupKey;
  final Object value;

  const FacetFilterValueToggled({
    required this.groupKey,
    required this.value,
  });

  @override
  List<Object?> get props => [groupKey, value];
}

class FacetFilterCleared extends FacetFilterEvent {
  const FacetFilterCleared();
}

class FacetFilterApplied extends FacetFilterEvent {
  const FacetFilterApplied();
}

/// Сбрасываем незаписанные изменения (когда пользователь закрывает окно без применения).
class FacetFilterEditingCancelled extends FacetFilterEvent {
  const FacetFilterEditingCancelled();
}
