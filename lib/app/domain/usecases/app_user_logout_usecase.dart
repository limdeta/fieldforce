import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';

class AppUserLogoutUseCase {
  final LogoutUseCase _logoutUseCase;

  AppUserLogoutUseCase({
    LogoutUseCase? logoutUseCase,
  }) : _logoutUseCase = logoutUseCase ?? GetIt.instance<LogoutUseCase>();

  Future<Either<AuthFailure, void>> call() async {
    try {
      // Делегируем
      final logoutResult = await _logoutUseCase.call();

      return logoutResult.fold(
        (authFailure) {
          return Left(authFailure);
        },
        (_) async {
          try {
            AppSessionService.clearSession();
            return const Right(null);
          } catch (e) {
            return const Right(null);
          }
        },
      );
    } catch (e) {
      return Left(AuthFailure('Ошибка logout: $e'));
    }
  }
}

