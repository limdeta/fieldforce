import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      // Если аутентификация успешна, сохраняем фейковую куку в SessionManager
      if (result.isAuthenticated) {
        await _saveMockSessionCookie();
      }

      return Right(result);
    } catch (e) {
      return Left(NetworkFailure('Ошибка mock аутентификации: $e'));
    }
  }

  /// Сохраняет фейковую сессионную куку для имитации реального поведения
  Future<void> _saveMockSessionCookie() async {
    try {
      // Генерируем фейковый PHPSESSID
      final mockSessionId = 'MOCK_${DateTime.now().millisecondsSinceEpoch}';
      final mockCookie = 'PHPSESSID=$mockSessionId';
      
      // Сохраняем в SessionManager напрямую через SharedPreferences
      // (так как у нас нет реального HTTP response)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('php_session_cookie', mockCookie);
      
      // Обновляем внутреннее состояние SessionManager
      // Вызываем getSessionClient чтобы он подхватил новую куку
      await SessionManager.instance.getSessionClient();
    } catch (e) {
      // Игнорируем ошибки сохранения куки в mock режиме
      print('⚠️ MockAuthApiService: Ошибка сохранения mock куки: $e');
    }
  }

  /// Mock логика аутентификации
  AuthApiResult _mockAuthenticateLogic(PhoneNumber phoneNumber, String password) {
    final phoneValue = phoneNumber.value;

    // Список "валидных" учетных данных для тестирования
    // Соответствует dev фикстурам (Саддам Хусейн)
    const validCredentials = [
      {'phone': '+7-999-111-2233', 'password': 'password123'}, // Саддам из фикстур
      {'phone': '+79991112233', 'password': 'password123'},    // Вариант без дефисов
      {'phone': '+79991113344', 'password': 'admin123'},
      {'phone': '+79991114455', 'password': 'manager123'},
    ];

    // Проверяем учетные данные
    final isValid = validCredentials.any((cred) =>
      cred['phone'] == phoneValue && cred['password'] == password
    );

    if (isValid) {
      return AuthApiResult.success(isActive: true);
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
      // Возвращаем данные Саддама из dev фикстур
      return Right({
        'id': 123,
        'firstName': 'Саддам',
        'fatherName': 'Хусейнович', // Добавляем отчество
        'lastName': 'Хусейн',
        'phoneNumber': '+7-999-111-2233',
        'email': 'salesrep@fieldforce.dev',
        'roles': ['ROLE_USER', 'ROLE_SALES'], // Массив ролей как в реальном API
        'contractors': [], // Пустой массив contractors
        'vendorId': null,
        'outlet': null, // null для простоты
        'isActive': true, // Аккаунт активен
        'createdAt': '2024-01-15T10:30:00Z',
      });
    } catch (e) {
      return Left(NetworkFailure('Ошибка получения mock данных пользователя: $e'));
    }
  }
}