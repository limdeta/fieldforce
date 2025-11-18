// lib/features/shop/domain/usecases/resolve_facet_product_codes_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/domain/repositories/facet_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class ResolveFacetProductCodesUseCase {
  final FacetRepository _facetRepository;

  ResolveFacetProductCodesUseCase(this._facetRepository);

  Future<Either<Failure, List<int>>> call(FacetFilter filter) {
    return _facetRepository.resolveProductCodes(filter);
  }
}
