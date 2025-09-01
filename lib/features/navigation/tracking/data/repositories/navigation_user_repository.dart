import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

abstract interface class NavigationUserRepository {
  Future<Either<Failure, NavigationUser>> getUserById(int id);
}
