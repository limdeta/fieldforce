import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/app/service_locator.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/services/user_initialization_service.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/bloc.dart';
import 'package:fieldforce/features/authentication/presentation/widgets/authentication_widget.dart';

/// Страница входа в систему (App-уровень)
/// 
/// Демонстрирует правильную модульную архитектуру:
/// - Использует AuthenticationBloc из features/authentication
/// - Координирует app-уровневые сервисы (AppSession, UserInitialization)
/// - Обрабатывает навигацию между экранами
/// - Разделяет ответственность между app и features слоями
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthenticationBloc>()
        ..add(const AuthenticationSessionCheckRequested()),
      child: const LoginPageView(),
    );
  }
}

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  Future<void> _handleAuthenticationSuccess(
    BuildContext context,
    AuthenticationAuthenticated state,
  ) async {
    try {
      final appSessionResult = await AppSessionService.createFromSecuritySession(state.userSession);
      if (appSessionResult.isLeft()) {
        throw Exception('Не удалось создать сессию приложения');
      }

      await UserInitializationService.initializeUserSettings(state.userSession.user);

      if (context.mounted) {
        _navigateByUserRole(context, state.userSession.user.role);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Ошибка инициализации: $e');
      }
    }
  }

  void _navigateByUserRole(BuildContext context, UserRole role) {
    String targetRoute;
    switch (role) {
      case UserRole.admin:
        targetRoute = '/admin';
        break;
      case UserRole.manager:
        targetRoute = '/home';
        break;
      case UserRole.user:
        targetRoute = '/sales-home';
        break;
    }
    
    Navigator.of(context).pushReplacementNamed(targetRoute);
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в fieldforce'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          switch (state) {
            case AuthenticationAuthenticated():
              _handleAuthenticationSuccess(context, state);
              break;
            case AuthenticationError():
              _showError(context, state.message);
              break;
            default:
              break;
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Показываем индикатор загрузки во время аутентификации
                if (state is AuthenticationLoading || 
                    state is AuthenticationSessionChecking)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                
                // AuthenticationWidget из features - сохраняется модульность
                const AuthenticationWidget(
                  initialPhone: '+7-999-111-2233',
                  initialPassword: 'password123',
                  showTestData: true,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
