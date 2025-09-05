import 'package:fieldforce/app/domain/entities/app_session.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';

class AppUserLoginUseCase {
  final LoginUseCase _loginUseCase;
  final AppUserRepository _appUserRepository;

  AppUserLoginUseCase({
    LoginUseCase? loginUseCase,
    AppUserRepository? appUserRepository,
  }) : _loginUseCase = loginUseCase ?? GetIt.instance<LoginUseCase>(),
      _appUserRepository = appUserRepository ?? GetIt.instance<AppUserRepository>();

  Future<Either<AuthFailure, AppSession>> call({
    required String phoneNumber,
    required String password,
    bool rememberMe = false,
  }) async {
    final authResult = await _loginUseCase.call(
      phoneString: phoneNumber,
      password: password,
      rememberMe: rememberMe,
    );

    return authResult.fold(
      (authFailure) {
        return Left(authFailure);
      },
      (userSession) async {
        final appUserResult = await _loadAppUserFromAuthenticatedUser(userSession.user.externalId);
        return appUserResult.fold(
          (failure) {
            return Left(AuthFailure('AppUser не найден: ${failure.message}'));
          },
          (appUser) {
            final appSession = AppSession(
              appUser: appUser,
              securitySession: userSession,
              createdAt: DateTime.now(),
            );
            return Right(appSession);
          },
        );
      },
    );
  }

  Future<Either<Failure, AppUser>> _loadAppUserFromAuthenticatedUser(String externalId) async {
    try {
      final appUserResult = await _appUserRepository.getAppUserByExternalId(externalId);
      return appUserResult.fold(
        (failure) {
          return Left(failure);
        },
        (appUser) {
          if (appUser == null) {
            return Left(DatabaseFailure('AppUser не существует для пользователя $externalId'));
          }
          return Right(appUser);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка загрузки AppUser: $e'));
    }
  }
}

