import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/facet_repository.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_facets_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/resolve_facet_product_codes_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCategoryRepository implements CategoryRepository {
  _FakeCategoryRepository({Either<Failure, List<Category>>? descendantsResult})
      : _descendantsResult =
            descendantsResult ?? Right<Failure, List<Category>>(<Category>[]);

  final Either<Failure, List<Category>> _descendantsResult;

  @override
  Future<Either<Failure, List<Category>>> getAllDescendants(int categoryId) async {
    return _descendantsResult;
  }

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Category?>> getCategoryById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> saveCategories(List<Category> categories) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Category>>> searchCategories(String query) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Category>>> getSubcategories(int parentId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Category>>> getAllAncestors(int categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateCategoryCounts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateCategoryCountsWithCategories(
    List<Category> categories,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateCategoryCountsForRegion(
    List<Category> categories,
    String regionCode,
  ) {
    throw UnimplementedError();
  }
}

class _FakeFacetRepository implements FacetRepository {
  _FakeFacetRepository({required this.groups, required this.resolvedCodes});

  final List<FacetGroup> groups;
  final List<int> resolvedCodes;
  int resolveCallCount = 0;

  @override
  Future<Either<Failure, List<FacetGroup>>> getFacetGroups(FacetFilter filter) async {
    return Right(groups);
  }

  @override
  Future<Either<Failure, List<int>>> resolveProductCodes(FacetFilter filter) async {
    resolveCallCount++;
    return Right(resolvedCodes);
  }
}

void main() {
  late FacetFilterBloc bloc;
  late GetFacetsUseCase getFacetsUseCase;
  late ResolveFacetProductCodesUseCase resolveCodesUseCase;
  late _FakeCategoryRepository categoryRepository;
  late _FakeFacetRepository facetRepository;

  const categoryId = 1;
  const brandId = 10;
  final sampleGroups = <FacetGroup>[
    const FacetGroup(
      key: 'brands',
      title: 'Brands',
      type: FacetGroupType.list,
      values: [
        FacetValue(value: brandId, label: 'Brand', count: 5),
      ],
    ),
  ];

  setUp(() {
    facetRepository = _FakeFacetRepository(
      groups: sampleGroups,
      resolvedCodes: const <int>[1001, 1002],
    );
    getFacetsUseCase = GetFacetsUseCase(facetRepository);
    resolveCodesUseCase = ResolveFacetProductCodesUseCase(facetRepository);
    categoryRepository = _FakeCategoryRepository();

    bloc = FacetFilterBloc(
      getFacetsUseCase: getFacetsUseCase,
      resolveFacetProductCodesUseCase: resolveCodesUseCase,
      categoryRepository: categoryRepository,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  Future<void> _waitFor(bool Function(FacetFilterState) predicate) async {
    if (predicate(bloc.state)) {
      return;
    }
    await expectLater(
      bloc.stream,
      emitsThrough(predicate),
    );
  }

  test('removing all selections clears allowed codes cache and avoids re-resolve', () async {
    bloc.add(const FacetFilterCategoryChanged(categoryId: categoryId, forceReload: true));
    await _waitFor((state) => state.hasLoadedOnce && !state.isLoading);

    expect(bloc.state.allowedProductCodes, isNull);

    bloc.add(const FacetFilterSheetOpened());

    bloc.add(const FacetFilterValueToggled(groupKey: 'brands', value: brandId));
    await _waitFor((state) => state.workingFilter.brandIds.contains(brandId));

    bloc.add(const FacetFilterApplied());
    await _waitFor(
      (state) =>
          !state.isApplying &&
          const ListEquality<int>().equals(state.allowedProductCodes, facetRepository.resolvedCodes),
    );

    bloc.add(const FacetFilterSheetOpened());
    await _waitFor((state) => state.allowedProductCodes != null);

    bloc.add(const FacetFilterValueToggled(groupKey: 'brands', value: brandId));
    await _waitFor((state) => state.workingFilter.brandIds.isEmpty);

    bloc.add(const FacetFilterApplied());
    await _waitFor(
      (state) =>
          !state.isApplying &&
          state.allowedProductCodes == null &&
          state.appliedBadges.isEmpty,
    );

    expect(facetRepository.resolveCallCount, 1);
  });
}
