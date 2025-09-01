import 'package:fieldforce/shared/failures.dart';

import '../../../../shared/either.dart';
import '../entities/user_session.dart';

abstract class SessionRepository {
  Future<Either<AuthFailure, UserSession?>> getCurrentSession();
  Future<Either<AuthFailure, void>> saveSession(UserSession session);
  Future<Either<AuthFailure, void>> clearSession();
  Future<Either<AuthFailure, bool>> hasValidSession();
  Future<Either<AuthFailure, void>> refreshSession();
}
