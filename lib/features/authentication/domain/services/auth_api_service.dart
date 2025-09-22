import 'dart:convert';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:logging/logging.dart';

/// Сервис для аутентификации через внешний API
/// Делает реальные HTTP запросы к серверу аутентификации
class AuthApiService implements IAuthApiService {
  static final Logger _logger = Logger('AuthApiService');

  @override
  Future<Either<Failure, AuthApiResult>> authenticate(
    PhoneNumber phoneNumber,
    String password,
  ) async {
    // Получаем сессионный клиент
    final client = await SessionManager.instance.getSessionClient();

    try {
      final url = AppConfig.authApiUrl;
      if (url.isEmpty) {
        return Left(NetworkFailure('URL API аутентификации не настроен'));
      }

      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'FieldForce-Mobile/1.0',
        },
        body: jsonEncode({
          'login': int.parse(phoneNumber.value.replaceAll(RegExp(r'[^\d]'), '')), // Убираем +7 и другие символы
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        await SessionManager.instance.saveSessionCookie(response);
        
        _logger.info('Аутентификация успешна');
        
        // При успешной аутентификации считаем пользователя активным
        // Детальные данные пользователя будут получены через getUserInfo
        return Right(AuthApiResult.success(isActive: true));
      } else {
        String errorMessage = 'Ошибка аутентификации';

        // Специальная обработка для разных HTTP статусов
        if (response.statusCode == 403) {
          errorMessage = 'Доступ запрещен. Проверьте права доступа.';
        } else if (response.statusCode == 401) {
          errorMessage = 'Неверные данные входа';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Сервер временно недоступен. Попробуйте позже.';
        }

        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody is Map && responseBody.containsKey('message')) {
            errorMessage = responseBody['message'];
          }
          // Проверяем, не является ли ошибка связанной с неактивным аккаунтом
          // (хотя при логине это маловероятно, но на всякий случай оставим)
          if (responseBody is Map && responseBody['isActive'] == false) {
            errorMessage = 'Аккаунт отключен. Обратитесь к администратору.';
          }
        } catch (_) {
          // Игнорируем ошибки парсинга
        }

        _logger.warning('Аутентификация отклонена: $errorMessage (статус: ${response.statusCode})');
        return Right(AuthApiResult.failure(errorMessage));
      }
    } catch (e) {
      _logger.severe('Ошибка сети при аутентификации', e);
      return Left(NetworkFailure('Ошибка подключения к серверу'));
    }
    // НЕ закрываем клиент - он используется для сессии!
  }

  /// Получает данные пользователя с сервера
  /// Использует сохраненную сессионную куку
  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserInfo() async {
    if (!SessionManager.instance.hasActiveSession()) {
      return Left(AuthFailure('Нет активной сессии. Необходимо выполнить вход.'));
    }

    final client = await SessionManager.instance.getSessionClient();

    try {
      // Используем новый URL для получения данных пользователя
      final url = AppConfig.userInfoApiUrl;

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'FieldForce-Mobile/1.0',
          ...SessionManager.instance.getSessionHeaders(), // Добавляем сессионную куку
        },
      );

      if (response.statusCode == 200) {
        try {
          final userData = jsonDecode(response.body) as Map<String, dynamic>;
          _logger.fine('Получены данные пользователя: ${userData.keys.join(', ')}');

          // Преобразуем данные API в формат, ожидаемый приложением
          final transformedData = _transformUserData(userData);
          return Right(transformedData);
        } catch (e) {
          _logger.warning('Ошибка парсинга данных пользователя', e);
          return Left(NetworkFailure('Ошибка обработки данных пользователя'));
        }
      } else if (response.statusCode == 401) {
        // Сессия истекла
        await SessionManager.instance.clearSession();
        return Left(AuthFailure('Сессия истекла. Необходимо выполнить вход повторно.'));
      } else {
        _logger.warning('Ошибка получения данных пользователя: статус ${response.statusCode}');
        return Left(NetworkFailure('Не удалось получить данные пользователя'));
      }
    } catch (e) {
      _logger.severe('Ошибка сети при получении данных пользователя', e);
      return Left(NetworkFailure('Ошибка подключения к серверу'));
    }
  }

  /// Преобразует данные API в формат, ожидаемый приложением
  Map<String, dynamic> _transformUserData(Map<String, dynamic> apiData) {
    final transformedData = {
      'id': apiData['id'],
      'firstName': apiData['firstName'],
      'fatherName': apiData['fatherName'],
      'lastName': apiData['lastName'],
      'isActive': apiData['isActive'] ?? true, // Флаг активности аккаунта
      // Дополнительные поля для совместимости с существующим кодом
      'fullName': _buildFullName(apiData),
    };

    // ЭКСПЕРИМЕНТ: Парсим outlet из данных пользователя
    // Это временное решение для автоматического выбора торговой точки
    if (apiData.containsKey('outlet') && apiData['outlet'] != null) {
      _logger.info('ЭКСПЕРИМЕНТ: Найден outlet в данных пользователя, парсим...');
      try {
        final outletData = apiData['outlet'] as Map<String, dynamic>;
        transformedData['outlet'] = {
          'id': outletData['id'],
          'vendorId': outletData['vendorId'],
          'name': outletData['name'],
          'address': outletData['address'],
          'longitude': outletData['address']?['longitude'],
          'latitude': outletData['address']?['latitude'],
        };
        _logger.info('ЭКСПЕРИМЕНТ: Outlet успешно распарсен: ${transformedData['outlet']['name']}');
      } catch (e) {
        _logger.warning('ЭКСПЕРИМЕНТ: Ошибка парсинга outlet из данных пользователя', e);
      }
    } else {
      _logger.info('ЭКСПЕРИМЕНТ: Outlet не найден в данных пользователя');
    }

    return transformedData;
  }

  /// Строит полное имя пользователя
  String _buildFullName(Map<String, dynamic> apiData) {
    final firstName = apiData['firstName'] ?? '';
    final fatherName = apiData['fatherName'] ?? '';
    final lastName = apiData['lastName'] ?? '';

    final parts = [lastName, firstName, fatherName].where((part) => part.isNotEmpty).toList();
    return parts.join(' ');
  }
}