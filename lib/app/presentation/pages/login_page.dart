import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/app/di/service_locator.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/services/user_initialization_service.dart';
import 'package:fieldforce/app/services/post_authentication_service.dart';
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

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  String? _initialPhone;
  String? _initialPassword;

  @override
  void initState() {
    super.initState();
    _prepareInitialCredentials();
  }

  Future<void> _prepareInitialCredentials() async {
    if (!AppConfig.isProd) {
      setState(() {
        _initialPhone = '999-111-2233';
        _initialPassword = 'password123';
      });
      return;
    }

    try {
      final sessionResult = await getIt<SessionRepository>().getCurrentSession();
      sessionResult.fold((failure) {
      }, (session) {
        if (session != null && session.rememberMe) {
          final cleaned = session.user.phoneNumber.value.replaceAll(RegExp(r'[^\d]'), '');
          String local = cleaned;
          if (cleaned.startsWith('7') && cleaned.length == 11) local = cleaned.substring(1);
          setState(() {
            _initialPhone = local; // local part only
            _initialPassword = null;
          });
        } else {
          setState(() {
            _initialPhone = null;
            _initialPassword = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _initialPhone = null;
        _initialPassword = null;
      });
    }
  }

  Future<void> _handleAuthenticationSuccess(
    BuildContext context,
    AuthenticationAuthenticated state,
  ) async {
    try {
      // 1. Создаем бизнес-сущности (Employee, AppUser) после успешной аутентификации
      final postAuthService = getIt<PostAuthenticationService>();
      final businessEntitiesResult = await postAuthService.createBusinessEntitiesForUser(state.userSession.user);

      businessEntitiesResult.fold(
        (failure) {
          // Логируем ошибку, но не прерываем процесс - пользователь уже аутентифицирован
          debugPrint('Ошибка создания бизнес-сущностей: ${failure.message}');
        },
        (_) {
          debugPrint('Бизнес-сущности успешно созданы');
        },
      );

      // 2. Создаем AppSession
      final appSessionResult = await AppSessionService.createFromSecuritySession(state.userSession);
      if (appSessionResult.isLeft()) {
        throw Exception('Не удалось создать сессию приложения');
      }

      // 3. Инициализируем пользовательские настройки
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
        targetRoute = '/sales-home';
        break;
      case UserRole.manager:
        targetRoute = '/sales-home';
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
          // Use a Stack so we can overlay a spinner without affecting layout.
          return Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AuthenticationWidget(
                        initialPhone: _initialPhone,
                        initialPassword: _initialPassword,
                        showTestData: AppConfig.isDev,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom-centered overlay spinner when loading or checking session
              if (state is AuthenticationLoading || state is AuthenticationSessionChecking)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
