import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';

/// Mock сервис для аутентификации
/// Используется только для тестирования и разработки
/// НЕ делает реальных HTTP вызовов
class MockAuthApiService implements IAuthApiService {

  /// Mock аутентификация для тестирования
  @override
  Future<Either<Failure, AuthApiResult>> authenticate(
    PhoneNumber phoneNumber,
    String password,
  ) async {
    try {
      // Имитация сетевого запроса
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock логика аутентификации
      final result = _mockAuthenticateLogic(phoneNumber, password);

      return Right(result);
    } catch (e) {
      return Left(NetworkFailure('Ошибка mock аутентификации: $e'));
    }
  }

  /// Mock логика аутентификации
  AuthApiResult _mockAuthenticateLogic(PhoneNumber phoneNumber, String password) {
    final phoneValue = phoneNumber.value;

    // Список "валидных" учетных данных для тестирования
    const validCredentials = [
      {'phone': '+79991112233', 'password': 'password123'},
      {'phone': '+79991113344', 'password': 'admin123'},
      {'phone': '+79991114455', 'password': 'manager123'},
    ];

    // Проверяем учетные данные
    final isValid = validCredentials.any((cred) =>
      cred['phone'] == phoneValue && cred['password'] == password
    );

    if (isValid) {
      return AuthApiResult.success();
    }

    // Имитируем различные типы ошибок
    if (phoneValue == '+79991110000') {
      return AuthApiResult.failure('Пользователь заблокирован');
    }

    if (phoneValue == '+79991111111') {
      return AuthApiResult.failure('Слишком много попыток входа');
    }

    return AuthApiResult.failure('Неверный телефон или пароль');
  }

  /// Mock получение данных пользователя
  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserInfo() async {
    try {
      // Имитация сетевого запроса
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock данные пользователя в формате реального API
      return Right({
        'id': 123,
        'firstName': 'Иван',
        'fatherName': 'Иванович', // Используем fatherName как в реальном API
        'lastName': 'Иванов',
        'phoneNumber': '+79991112233',
        'email': 'ivan.ivanov@company.com',
        'roles': ['ROLE_USER', 'ROLE_SALES'], // Массив ролей как в реальном API
        'contractors': [], // Пустой массив contractors
        'vendorId': null,
        'outlet': null, // null для простоты
        'disabled': false,
        'createdAt': '2024-01-15T10:30:00Z',
      });
    } catch (e) {
      return Left(NetworkFailure('Ошибка получения mock данных пользователя: $e'));
    }
  }
}