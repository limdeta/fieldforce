import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/features/shop/domain/errors/order_submission_error.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Реальная реализация OrderApiService для отправки заказов на Symfony бэкенд
/// Использует SessionManager.httpClient для аутентификации через существующую сессию
class RealOrderApiService implements OrderApiService {
  static final Logger _logger = Logger('RealOrderApiService');
  
  final SessionManager _sessionManager;

  const RealOrderApiService({required SessionManager sessionManager})
      : _sessionManager = sessionManager;

  @override
  Future<Either<Failure, int?>> submitOrder(Map<String, dynamic> orderJson) async {
    try {
      final client = await _sessionManager.getSessionClient();
      final url = Uri.parse(AppConfig.ordersApiUrl);
      
      _logger.info('Отправка заказа на $url');
      _logger.fine('Payload: ${jsonEncode(orderJson)}');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          ...(await _sessionManager.getSessionHeaders()),
        },
        body: jsonEncode(orderJson),
      ).timeout(const Duration(seconds: 30));

      _logger.info('Получен ответ: ${response.statusCode}');

      // Успешная отправка
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final serverId = data['orderId'] as int?;
        _logger.info('Заказ успешно создан на бэкенде: serverId=$serverId');
        // Возвращаем serverId для сохранения в Order
        return Right(serverId);
      }

      // Ошибка валидации (400) - не retry
      if (response.statusCode == 400) {
        final error = _parseErrorResponse(response.body);
        _logger.warning('Ошибка валидации заказа: ${error.message}');
        
        return Left(ValidationFailure(error.message));
      }

      // Ошибка авторизации (401/403)
      if (response.statusCode == 401 || response.statusCode == 403) {
        _logger.warning('Ошибка авторизации: ${response.statusCode}');
        return const Left(AuthFailure('Требуется авторизация'));
      }

      // Серверные ошибки (500+) - retry
      if (response.statusCode >= 500) {
        _logger.warning('Ошибка сервера: ${response.statusCode}');
        return Left(NetworkFailure('Ошибка сервера: ${response.statusCode}'));
      }

      // Неизвестный код ответа
      _logger.severe('Неожиданный код ответа: ${response.statusCode}');
      return Left(NetworkFailure('Неожиданный код ответа: ${response.statusCode}'));

    } on TimeoutException catch (e) {
      _logger.warning('Таймаут при отправке заказа', e);
      return const Left(NetworkFailure('Превышено время ожидания ответа'));
      
    } on SocketException catch (e) {
      _logger.warning('Нет соединения с интернетом', e);
      return const Left(NetworkFailure('Нет соединения с интернетом'));
      
    } catch (e, st) {
      _logger.severe('Неожиданная ошибка при отправке заказа', e, st);
      return Left(NetworkFailure('Неожиданная ошибка: $e'));
    }
  }

  /// Парсит тело ответа с ошибкой от бэкенда
  OrderSubmissionError _parseErrorResponse(String body) {
    try {
      final json = jsonDecode(body);
      final errorCode = json['error'] as String?;
      final message = json['message'] as String? ?? 'Ошибка валидации заказа';
      
      return OrderSubmissionError.validationError(
        message,
        errorCode: errorCode,
      );
    } catch (e) {
      _logger.warning('Не удалось распарсить ошибку: $body', e);
      return OrderSubmissionError.validationError(
        'Ошибка валидации заказа',
      );
    }
  }
}
