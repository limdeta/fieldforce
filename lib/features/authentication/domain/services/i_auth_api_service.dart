import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// Результат аутентификации от внешнего API
class AuthApiResult {
  final bool isAuthenticated;
  final String? errorMessage;
  final bool? isActive; // Флаг активности аккаунта
  final Map<String, dynamic>? userData; // Данные пользователя из API

  const AuthApiResult({
    required this.isAuthenticated,
    this.errorMessage,
    this.isActive,
    this.userData,
  });

  factory AuthApiResult.success({bool? isActive, Map<String, dynamic>? userData}) {
    return AuthApiResult(
      isAuthenticated: true,
      isActive: isActive,
      userData: userData,
    );
  }

  factory AuthApiResult.failure(String message) {
    return AuthApiResult(isAuthenticated: false, errorMessage: message);
  }

  /// Проверяет, активен ли аккаунт (если информация доступна)
  bool get isAccountActive => isActive ?? true; // По умолчанию считаем активным, если не указано
}

/// Интерфейс для сервисов аутентификации через внешний API
abstract class IAuthApiService {
  /// Аутентификация пользователя
  Future<Either<Failure, AuthApiResult>> authenticate(
    PhoneNumber phoneNumber,
    String password,
  );

  /// Получение данных пользователя с сервера
  Future<Either<Failure, Map<String, dynamic>>> getUserInfo();
}