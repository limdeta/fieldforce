import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';

import '../../../../../shared/either.dart';
import '../../../../../shared/failures.dart';

abstract interface class NavigationUserRepository {
  Future<Either<Failure, NavigationUser>> getUserById(int id);
}
