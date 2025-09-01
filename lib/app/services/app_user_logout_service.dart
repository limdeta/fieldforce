import 'package:get_it/get_it.dart';
import '../../shared/either.dart';
import '../../shared/failures.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../services/app_session_service.dart';

class AppUserLogoutService {
  final LogoutUseCase _logoutUseCase;

  AppUserLogoutService({
    LogoutUseCase? logoutUseCase,
  }) : _logoutUseCase = logoutUseCase ?? GetIt.instance<LogoutUseCase>();


  Future<Either<AuthFailure, void>> logoutAppUser() async {
    try {
      // Делегируем logout к authentication фиче
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
