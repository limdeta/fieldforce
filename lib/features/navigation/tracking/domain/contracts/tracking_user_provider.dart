/// Абстракция для получения пользователя в модуле трекинга
/// 
/// Позволяет трекингу работать независимо от app слоя
abstract class TrackingUserProvider {
  int? getCurrentUserId();
  bool get isUserAuthorized;
}

class TrackingUserNotFoundException implements Exception {
  final String message;
  
  const TrackingUserNotFoundException(this.message);
  
  @override
  String toString() => 'TrackingUserNotFoundException: $message';
}
