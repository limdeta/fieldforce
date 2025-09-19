import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

class AuthenticationService {
  static final Logger _logger = Logger('PostAuthenticationService');
  final UserRepository userRepository;
  final SessionRepository sessionRepository;
  final IAuthApiService authApiService;

  const AuthenticationService({
    required this.userRepository,
    required this.sessionRepository,
    required this.authApiService,
  });

  /// Аутентификация пользователя
  /// Стратегия: API-first, с graceful fallback на существующую сессию
  Future<Either<AuthFailure, UserSession>> authenticateUser(
    PhoneNumber phoneNumber,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      // 1. Сначала пытаемся аутентифицироваться через внешний API
      final apiResult = await authApiService.authenticate(phoneNumber, password);

      return apiResult.fold(
        (apiFailure) async {
          // 2. Обработка ошибок API
          if (apiFailure is NetworkFailure) {
            return await _handleOfflineAuthentication(phoneNumber, password, rememberMe);
          } else {
            return Left(AuthFailure('Ошибка аутентификации: ${apiFailure.message}'));
          }
        },
        (authResult) async {
          if (authResult.isAuthenticated) {
            if (!authResult.isAccountActive) {
              return Left(AuthFailure('Аккаунт отключен. Обратитесь к администратору.'));
            }
            
            // 3. API аутентификация успешна и аккаунт активен - создаем базовую сессию
            return await _createBasicSessionAfterApiAuth(phoneNumber, password, rememberMe: rememberMe);
          } else {
            // 4. API вернул отказ в аутентификации
            return Left(AuthFailure(authResult.errorMessage ?? 'Аутентификация отклонена'));
          }
        },
      );
    } catch (e) {
      // 5. При любых ошибках - пытаемся использовать существующую сессию
      return await _handleOfflineAuthentication(phoneNumber, password, rememberMe);
    }
  }

  /// Обработка аутентификации при недоступности API (graceful fallback)
  Future<Either<AuthFailure, UserSession>> _handleOfflineAuthentication(
    PhoneNumber phoneNumber,
    String password,
    bool rememberMe,
  ) async {
    final sessionResult = await sessionRepository.getCurrentSession();
    
    return sessionResult.fold(
      (failure) => Left(AuthFailure('Сервер недоступен. Требуется подключение к интернету для первого входа.')),
      (existingSession) async {
        if (existingSession != null && existingSession.isValid) {
          // Есть валидная сессия - разрешаем вход без API
          return Right(existingSession);
        } else {
          // Нет валидной сессии или она истекла
          if (existingSession != null && !existingSession.isValid) {
            final hoursSinceLogin = DateTime.now().difference(existingSession.loginTime).inHours;
            return Left(AuthFailure('Истекло время сессии (прошло $hoursSinceLoginч). Требуется повторная аутентификация через интернет.'));
          } else {
            return Left(AuthFailure('Сервер недоступен. Требуется подключение к интернету для входа.'));
          }
        }
      },
    );
  }

  /// Создает базовую сессию после успешной API аутентификации
  Future<Either<AuthFailure, UserSession>> _createBasicSessionAfterApiAuth(
    PhoneNumber phoneNumber,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      // Создаем или получаем пользователя в auth модуле
      final userResult = await _getOrCreateAuthUser(phoneNumber, password);

      return userResult.fold(
        (failure) => Left(AuthFailure('Ошибка создания пользователя: ${failure.message}')),
        (user) async {
          // Создаем базовую сессию
          final sessionResult = UserSession.create(
            user: user,
            rememberMe: rememberMe,
          );

          return sessionResult.fold(
            (failure) => Left(AuthFailure('Ошибка создания сессии: ${failure.message}')),
            (session) async {
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
      return Left(AuthFailure('Ошибка создания сессии после API аутентификации: $e'));
    }
  }

  /// Получает существующего пользователя или создает нового в auth модуле
  Future<Either<Failure, User>> _getOrCreateAuthUser(
    PhoneNumber phoneNumber,
    String password,
  ) async {
    final existingUserResult = await userRepository.getUserByPhoneNumber(phoneNumber);

    return existingUserResult.fold(
      (failure) async {
        final hashedPassword = PasswordService.hashPassword(password);
        final newUser = User.create(
          externalId: 'auth_${phoneNumber.value}', // Генерируем externalId для auth модуля
          phoneNumber: phoneNumber,
          hashedPassword: hashedPassword,
          role: UserRole.user, // Используем существующую роль
        );

        return newUser.fold(
          (failure) => Left(failure),
          (user) async => await userRepository.createUser(user),
        );
      },
      (existingUser) async {
        final isPasswordValid = PasswordService.verifyPassword(password, existingUser.hashedPassword);
        if (!isPasswordValid) {
          final hashedPassword = PasswordService.hashPassword(password);
          final updatedUser = User(
            id: existingUser.id,
            externalId: existingUser.externalId,
            role: existingUser.role,
            phoneNumber: existingUser.phoneNumber,
            hashedPassword: hashedPassword,
          );
          return await userRepository.saveUser(updatedUser);
        }
        return Right(existingUser);
      },
    );
  }

  Future<Either<AuthFailure, void>> logout() async {
    try {
      final currentSessionResult = await sessionRepository.getCurrentSession();

      return currentSessionResult.fold(
        (failure) => Left(AuthFailure('Ошибка получения текущей сессии: ${failure.message}')),
        (session) async {
          if (session != null) {
            // Используем clearSession вместо deleteSession
            return await sessionRepository.clearSession();
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(AuthFailure('Ошибка выхода: $e'));
    }
  }

  /// Валидация запроса аутентификации
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

  /// Фоновая проверка и продление сессии
  /// Вызывается периодически для поддержания актуальности сессии
  Future<Either<Failure, void>> refreshSessionIfNeeded() async {
    try {
      final sessionResult = await sessionRepository.getCurrentSession();
      
      return sessionResult.fold(
        (failure) => Left(failure),
        (existingSession) async {
          if (existingSession == null || !existingSession.isValid) {
            return const Right(null); // Нет сессии или она невалидна
          }

          final hoursSinceLogin = DateTime.now().difference(existingSession.loginTime).inHours;
          
          // Если сессия старше 12 часов, пытаемся ее освежить
          if (hoursSinceLogin > 12) {
            
            // Пытаемся получить свежие данные пользователя
            final userInfoResult = await authApiService.getUserInfo();
            
            return userInfoResult.fold(
              (failure) {
                // Не удалось освежить - оставляем старую сессию
                _logger.warning('AuthenticationService: Не удалось освежить сессию: ${failure.message}');
                return const Right(null);
              },
              (userData) async {
                // Проверяем, активен ли аккаунт
                final isActive = userData['isActive'] as bool? ?? true;
                if (!isActive) {
                  _logger.severe('AuthenticationService: Аккаунт отключен при фоновой проверке');
                  // Можно отправить уведомление пользователю
                  return const Right(null);
                }

                // Создаем новую сессию с обновленным временем
                final refreshedSessionResult = UserSession.create(
                  user: existingSession.user,
                  rememberMe: existingSession.rememberMe,
                  deviceId: existingSession.deviceId,
                  permissions: existingSession.permissions,
                );

                return refreshedSessionResult.fold(
                  (failure) => Left(failure),
                  (refreshedSession) async {
                    final saveResult = await sessionRepository.saveSession(refreshedSession);
                    return saveResult.fold(
                      (failure) => Left(failure),
                      (_) {
                        _logger.info('AuthenticationService: Сессия успешно обновлена');
                        return const Right(null);
                      },
                    );
                  },
                );
              },
            );
          } else {
            return const Right(null); // Сессия еще свежая
          }
        },
      );
    } catch (e) {
      _logger.severe('AuthenticationService: Ошибка при обновлении сессии: $e');
      return Left(DatabaseFailure('Ошибка обновления сессии: $e'));
    }
  }

  /// Метод logoutUser для совместимости с LogoutUseCase
  Future<Either<AuthFailure, void>> logoutUser() async {
    return logout();
  }
}
