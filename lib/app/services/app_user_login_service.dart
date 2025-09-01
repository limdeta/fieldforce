import 'package:get_it/get_it.dart';
import '../../shared/either.dart';
import '../../shared/failures.dart';
import '../domain/app_session.dart';
import '../domain/app_user.dart';
import '../domain/repositories/app_user_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';

/// Обёртка над authentication фичей для работы через AppUser
/// Делегирует аутентификацию к LoginUseCase, но возвращает AppSession
class AppUserLoginService {
  final LoginUseCase _loginUseCase;
  final AppUserRepository _appUserRepository;

  AppUserLoginService({
    LoginUseCase? loginUseCase,
    AppUserRepository? appUserRepository,
  }) : _loginUseCase = loginUseCase ?? GetIt.instance<LoginUseCase>(),
        _appUserRepository = appUserRepository ?? GetIt.instance<AppUserRepository>();

  /// Аутентификация через AppUser
  /// 1. Делегирует аутентификацию к authentication фиче
  /// 2. После успешной аутентификации загружает полный AppUser
  /// 3. Возвращает AppSession с полными данными
  Future<Either<AuthFailure, AppSession>> authenticateAppUser({
    required String phoneNumber,
    required String password,
    bool rememberMe = false,
  }) async {

    // 1. Делегируем аутентификацию к authentication фиче
    final authResult = await _loginUseCase.call(
      phoneString: phoneNumber,
      password: password,
      rememberMe: rememberMe,
    );

    return authResult.fold(
      (authFailure) {
        print('❌ [AppUserLogin] Ошибка аутентификации: ${authFailure.message}');
        return Left(authFailure);
      },
      (userSession) async {
        print('✅ [AppUserLogin] Аутентификация успешна для User: ${userSession.user.externalId}');

        // 2. Загружаем полный AppUser на основе аутентифицированного User
        final appUserResult = await _loadAppUserFromAuthenticatedUser(userSession.user.externalId);

        return appUserResult.fold(
          (failure) {
            print('❌ [AppUserLogin] Не удалось загрузить AppUser: ${failure.message}');
            return Left(AuthFailure('AppUser не найден: ${failure.message}'));
          },
          (appUser) {
            print('✅ [AppUserLogin] AppUser загружен: ${appUser.fullName} (Employee ID: ${appUser.employee.id})');
            // 3. Создаем AppSession с полными данными
            final appSession = AppSession(
              appUser: appUser,
              securitySession: userSession,
              createdAt: DateTime.now(),
            );
            print('🎯 [AppUserLogin] AppSession создан успешно');
            return Right(appSession);
          },
        );
      },
    );
  }

  /// Загружает AppUser на основе externalId аутентифицированного User
  Future<Either<Failure, AppUser>> _loadAppUserFromAuthenticatedUser(String externalId) async {
    try {
      print('🔍 [AppUserLogin] Поиск AppUser по externalId: $externalId');

      // Находим AppUser по User.externalId
      final appUserResult = await _appUserRepository.getAppUserByExternalId(externalId);

      return appUserResult.fold(
        (failure) {
          print('❌ [AppUserLogin] AppUser не найден по externalId $externalId: ${failure.message}');
          return Left(failure);
        },
        (appUser) {
          if (appUser == null) {
            print('❌ [AppUserLogin] AppUser is null для externalId: $externalId');
            return Left(DatabaseFailure('AppUser не существует для пользователя $externalId'));
          }
          
          print('✅ [AppUserLogin] AppUser найден: ${appUser.fullName}');
          return Right(appUser);
        },
      );
    } catch (e) {
      print('❌ [AppUserLogin] Ошибка при загрузке AppUser: $e');
      return Left(DatabaseFailure('Ошибка загрузки AppUser: $e'));
    }
  }
}
