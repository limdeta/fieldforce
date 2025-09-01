import 'package:fieldforce/shared/failures.dart';

import '../../../../shared/either.dart';
import '../services/authentication_service.dart';

class LogoutUseCase {
  final AuthenticationService authenticationService;

  const LogoutUseCase({
    required this.authenticationService,
  });

  Future<Either<AuthFailure, void>> call() async {
    return await authenticationService.logoutUser();
  }
}
