/// Типы ошибок при отправке заказа на бэкенд
enum OrderSubmissionErrorType {
  /// Сетевые ошибки - требуют retry
  networkError,
  
  /// Ошибки валидации данных - заказ возвращается в draft
  validationError,
  
  /// Ошибки авторизации - возможно нужен logout
  unauthorized,
  
  /// Неизвестная ошибка - заказ переходит в error после max attempts
  unknownError,
}

/// Ошибка отправки заказа с детальной информацией
class OrderSubmissionError {
  final OrderSubmissionErrorType type;
  final String message;
  final String? errorCode;

  const OrderSubmissionError({
    required this.type,
    required this.message,
    this.errorCode,
  });

  /// Создаёт ошибку сети (timeout, no connection, 5xx)
  factory OrderSubmissionError.networkError(String message) {
    return OrderSubmissionError(
      type: OrderSubmissionErrorType.networkError,
      message: message,
    );
  }

  /// Создаёт ошибку валидации (400 с кодом ошибки)
  factory OrderSubmissionError.validationError(
    String message, {
    String? errorCode,
  }) {
    return OrderSubmissionError(
      type: OrderSubmissionErrorType.validationError,
      message: message,
      errorCode: errorCode,
    );
  }

  /// Создаёт ошибку авторизации (401/403)
  factory OrderSubmissionError.unauthorized([String? message]) {
    return OrderSubmissionError(
      type: OrderSubmissionErrorType.unauthorized,
      message: message ?? 'Требуется авторизация',
    );
  }

  /// Создаёт неизвестную ошибку
  factory OrderSubmissionError.unknownError(String message) {
    return OrderSubmissionError(
      type: OrderSubmissionErrorType.unknownError,
      message: message,
    );
  }

  /// Нужен ли retry для этой ошибки
  bool get shouldRetry => type == OrderSubmissionErrorType.networkError;

  /// Вернуть ли заказ в draft
  bool get shouldReturnToDraft => type == OrderSubmissionErrorType.validationError;

  /// Разлогинить ли пользователя
  // bool get shouldLogout => type == OrderSubmissionErrorType.unauthorized;

  @override
  String toString() {
    return 'OrderSubmissionError(type: $type, message: $message, errorCode: $errorCode)';
  }
}
