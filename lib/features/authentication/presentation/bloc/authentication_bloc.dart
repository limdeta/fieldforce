import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:fieldforce/features/authentication/domain/entities/session_state.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/authentication_state.dart';

/// BLoC для управления состоянием аутентификации
/// 
/// Этот BLoC находится в слое features и содержит только бизнес-логику
/// аутентификации. Он не знает о UI-специфичных деталях и может быть
/// переиспользован в разных частях приложения.
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentSessionUseCase _getCurrentSessionUseCase;

  AuthenticationBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentSessionUseCase getCurrentSessionUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentSessionUseCase = getCurrentSessionUseCase,
        super(const AuthenticationInitial()) {
    
    // Регистрируем обработчики событий
    on<AuthenticationLoginRequested>(_onLoginRequested);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
    on<AuthenticationSessionCheckRequested>(_onSessionCheckRequested);
    on<AuthenticationErrorCleared>(_onErrorCleared);
  }

  /// Обработчик события логина
  Future<void> _onLoginRequested(
    AuthenticationLoginRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());

    try {
      final result = await _loginUseCase.call(
        phoneString: event.phoneNumber,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      result.fold(
        (failure) => emit(AuthenticationError(message: failure.message)),
        (userSession) => emit(AuthenticationAuthenticated(userSession: userSession)),
      );
    } catch (e) {
      emit(AuthenticationError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Обработчик события логаута
  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());

    try {
      final result = await _logoutUseCase.call();
      
      result.fold(
        (failure) => emit(AuthenticationError(message: failure.message)),
        (_) => emit(const AuthenticationUnauthenticated()),
      );
    } catch (e) {
      emit(AuthenticationError(message: 'Ошибка при выходе: $e'));
    }
  }

  /// Обработчик события проверки сессии
  Future<void> _onSessionCheckRequested(
    AuthenticationSessionCheckRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationSessionChecking());

    final result = await _getCurrentSessionUseCase.call();

    result.fold(
      // Техническая ошибка
      (failure) => emit(const AuthenticationUnauthenticated()),
      // Анализируем состояние сессии БЕЗ null-проверок!
      (sessionState) => sessionState.when(
        onNotFound: () => emit(const AuthenticationUnauthenticated()),
        onFound: (userSession) => emit(AuthenticationAuthenticated(userSession: userSession)),
      ),
    );
  }


  /// Обработчик сброса ошибки
  void _onErrorCleared(
    AuthenticationErrorCleared event,
    Emitter<AuthenticationState> emit,
  ) {
    if (state is AuthenticationError) {
      emit(const AuthenticationUnauthenticated());
    }
  }
}
