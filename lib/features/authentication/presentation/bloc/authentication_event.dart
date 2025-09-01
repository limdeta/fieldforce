import 'package:equatable/equatable.dart';

/// События аутентификации
sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Событие логина пользователя
class AuthenticationLoginRequested extends AuthenticationEvent {
  final String phoneNumber;
  final String password;
  final bool rememberMe;

  const AuthenticationLoginRequested({
    required this.phoneNumber,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [phoneNumber, password, rememberMe];
}

/// Событие логаута пользователя
class AuthenticationLogoutRequested extends AuthenticationEvent {
  const AuthenticationLogoutRequested();
}

/// Событие проверки существующей сессии
class AuthenticationSessionCheckRequested extends AuthenticationEvent {
  const AuthenticationSessionCheckRequested();
}

/// Событие сброса состояния ошибки
class AuthenticationErrorCleared extends AuthenticationEvent {
  const AuthenticationErrorCleared();
}
