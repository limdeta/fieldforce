import 'user_session.dart';

/// Состояния сессии без null!
/// 
/// Используем sealed class для явного моделирования всех возможных состояний.
/// Это исключает необходимость в null-проверках.
sealed class SessionState {
  const SessionState();
}

class SessionNotFound extends SessionState {
  const SessionNotFound();
  
  @override
  String toString() => 'SessionNotFound()';
}

/// Активная сессия найдена
class SessionFound extends SessionState {
  final UserSession userSession;
  
  const SessionFound(this.userSession);
  
  @override
  String toString() => 'SessionFound(${userSession.user.phoneNumber})';
}

/// Extension для удобной работы с SessionState
extension SessionStateX on SessionState {
  /// Проверяем, есть ли активная сессия
  bool get isAuthenticated => this is SessionFound;
  
  /// Получаем сессию (если есть)
  UserSession? get sessionOrNull => switch (this) {
    SessionFound(userSession: final session) => session,
    SessionNotFound() => null,
  };
  
  /// Безопасное выполнение действия с сессией
  T when<T>({
    required T Function() onNotFound,
    required T Function(UserSession session) onFound,
  }) {
    return switch (this) {
      SessionNotFound() => onNotFound(),
      SessionFound(userSession: final session) => onFound(session),
    };
  }
}
