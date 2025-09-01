import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';

/// Состояния аутентификации
sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

/// Состояние загрузки
class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

/// Состояние успешной аутентификации
class AuthenticationAuthenticated extends AuthenticationState {
  final UserSession userSession;

  const AuthenticationAuthenticated({
    required this.userSession,
  });

  @override
  List<Object> get props => [userSession];
}

/// Состояние неаутентифицированного пользователя
class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated();
}

/// Состояние ошибки аутентификации
class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Состояние проверки сессии
class AuthenticationSessionChecking extends AuthenticationState {
  const AuthenticationSessionChecking();
}
