import 'package:fieldforce/app/domain/entities/app_session.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/features/authentication/domain/entities/session_state.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';

class AppSessionService {
  static AppSession? _currentSession;

  static final GetCurrentSessionUseCase _getSecuritySession =
      GetIt.instance<GetCurrentSessionUseCase>();
  static final AppUserRepository _appUserRepository =
      GetIt.instance<AppUserRepository>();

  static bool get hasActiveSession => _currentSession?.isAuthenticated == true;
  static AppSession? get currentSession => _currentSession;

  static Future<Either<Failure, AppSession>> createFromSecuritySession(
    UserSession securitySession,
  ) async {
    try {
      // Ищем AppUser по externalId из security session
      final appUserResult = await _appUserRepository.getAppUserByExternalId(
        securitySession.externalId,
      );

      return appUserResult.fold(
        (failure) => Left(failure),
        (appUser) {
          if (appUser == null) {
            return const Left(NotFoundFailure('AppUser не найден'));
          }

          final appSession = AppSession(
            appUser: appUser,
            securitySession: securitySession,
            createdAt: DateTime.now(),
          );

          _currentSession = appSession;
          return Right(appSession);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка создания AppSession: $e'));
    }
  }

  static Future<Either<Failure, SessionState>> getCurrentSessionState() async {
    try {
      // Если есть кешированная валидная сессия
      if (_currentSession?.isAuthenticated == true) {
        return Right(SessionFound(_currentSession!.securitySession));
      }

      // Получаем состояние сессии из authentication слоя
      return await _getSecuritySession.call();
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения состояния сессии: $e'));
    }
  }

  static Future<Either<Failure, AppSession?>> getCurrentAppSession() async {
    try {
      // Если есть кешированная сессия и она валидна
      if (_currentSession?.isAuthenticated == true) {
        return Right(_currentSession);
      }

      // Получаем security session состояние
      final sessionResult = await _getSecuritySession.call();

      return await sessionResult.fold(
        (failure) async => Left(failure),
        (sessionState) async {
          return await sessionState.when(
            onNotFound: () async {
              _currentSession = null;
              return const Right(null);
            },
            onFound: (userSession) async {
              // Создаем новую AppSession
              final appSessionResult = await createFromSecuritySession(userSession);

              return appSessionResult.fold(
                (failure) => Left(failure),
                (appSession) => Right(appSession),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения AppSession: $e'));
    }
  }

  /// Очищает текущую сессию (при выходе)
  static void clearCurrentSession() {
    _currentSession = null;
  }

  /// Алиас для совместимости
  static void clearSession() {
    clearCurrentSession();
  }

  /// Обновляет данные пользователя в текущей сессии
  static Future<Either<Failure, AppSession>> updateCurrentUser(
    AppUser updatedUser,
  ) async {
    if (_currentSession == null) {
      return const Left(NotFoundFailure('Нет активной сессии для обновления'));
    }

    try {
      final updatedSession = _currentSession!.updateAppUser(updatedUser);
      _currentSession = updatedSession;
      return Right(updatedSession);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка обновления пользователя: $e'));
    }
  }
}
