// lib/features/shop/domain/usecases/get_facets_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/domain/repositories/facet_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class GetFacetsUseCase {
  final FacetRepository _facetRepository;

  GetFacetsUseCase(this._facetRepository);

  Future<Either<Failure, List<FacetGroup>>> call(FacetFilter filter) {
    return _facetRepository.getFacetGroups(filter);
  }
}
