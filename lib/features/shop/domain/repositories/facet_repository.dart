// lib/features/shop/domain/repositories/facet_repository.dart

import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

abstract class FacetRepository {
  Future<Either<Failure, List<FacetGroup>>> getFacetGroups(FacetFilter filter);
  Future<Either<Failure, List<int>>> resolveProductCodes(FacetFilter filter);
}
