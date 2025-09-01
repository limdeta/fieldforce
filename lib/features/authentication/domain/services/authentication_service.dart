import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class AuthenticationService {
  final UserRepository userRepository;
  final SessionRepository sessionRepository;

  const AuthenticationService({
    required this.userRepository,
    required this.sessionRepository,
  });

  Future<Either<AuthFailure, UserSession>> authenticateUser(
    PhoneNumber phoneNumber,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final userResult = await userRepository.getUserByPhoneNumber(phoneNumber);
      
      return userResult.fold(
        (failure) => Left(AuthFailure('Ошибка поиска пользователя: ${failure.message}')),
        (user) async {
          if (!PasswordService.verifyPassword(password, user.hashedPassword)) {
            return const Left(AuthFailure('Неверный пароль'));
          }

          final sessionResult = UserSession.create(
            user: user,
            rememberMe: rememberMe,
          );

          return sessionResult.fold(
            (failure) => Left(AuthFailure('Ошибка создания сессии: ${failure.message}')),
            (session) async {
              // 4. Save session
              final saveResult = await sessionRepository.saveSession(session);
              return saveResult.fold(
                (failure) => Left(failure),
                (_) => Right(session),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(AuthFailure('Ошибка аутентификации: $e'));
    }
  }

  Either<AuthFailure, void> validateAuthenticationRequest(
    PhoneNumber phoneNumber,
    String password,
  ) {
    // Basic validation
    if (password.isEmpty) {
      return const Left(AuthFailure('Пароль не может быть пустым'));
    }

    if (password.length < 6) {
      return const Left(AuthFailure('Пароль должен содержать минимум 6 символов'));
    }

    return const Right(null);
  }

  Future<Either<AuthFailure, void>> logoutUser() async {
    try {
      final result = await sessionRepository.clearSession();
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(AuthFailure('Ошибка выхода: $e'));
    }
  }
}
