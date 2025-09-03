/// Абстракция для получения пользователя в модуле трекинга
/// 
/// Позволяет трекингу работать независимо от app слоя
abstract class TrackingUserProvider {
  /// Получить ID текущего пользователя для трекинга
  int? getCurrentUserId();
  
  /// Проверить, авторизован ли пользователь
  bool get isUserAuthorized;
}

/// Исключение когда пользователь не найден
class TrackingUserNotFoundException implements Exception {
  final String message;
  
  const TrackingUserNotFoundException(this.message);
  
  @override
  String toString() => 'TrackingUserNotFoundException: $message';
}
