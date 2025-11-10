import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/app/di/service_locator.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/helpers/navigation_helper.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/services/user_initialization_service.dart';
import 'package:fieldforce/app/services/post_authentication_service.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/bloc.dart';
import 'package:fieldforce/features/authentication/presentation/widgets/authentication_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  static final Logger _logger = Logger('_LoginPageViewState');
  String? _initialPhone;
  String? _initialPassword;
  bool _isRestoringSession = true;
  late final Future<String> _versionLabelFuture;

  @override
  void initState() {
    super.initState();
    _versionLabelFuture = _loadVersionLabel();
    _prepareInitialCredentials();
  }

  Future<String> _loadVersionLabel() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return 'ver. ${info.version}';
    } catch (_) {
      return '';
    }
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
    AuthenticationAuthenticated state, {
    required bool isAutoLogin,
  }) async {
    try {
      // 1. Создаем бизнес-сущности (Employee, AppUser) после успешной аутентификации
      final postAuthService = getIt<PostAuthenticationService>();
      final businessEntitiesResult = await postAuthService.createBusinessEntitiesForUser(state.userSession.user);

      final businessEntitiesFailure = businessEntitiesResult.fold((failure) => failure, (_) => null);
      if (businessEntitiesFailure != null) {
        final message = 'Ошибка создания бизнес-сущностей: ${businessEntitiesFailure.message}';
        if (isAutoLogin) {
          if (!mounted) return;
          await _handleSilentSessionFailure(
            // ignore: use_build_context_synchronously
            context,
            message,
          );
        } else {
          _logger.warning('Ошибка создания бизнес-сущностей при логине: $message');
          if (mounted) {
            _showError(message);
          }
        }
        return;
      }

      _logger.fine('Бизнес-сущности успешно созданы');

      // 2. Создаем AppSession (теперь AppUser должен существовать)
      final appSessionResult = await AppSessionService.createFromSecuritySession(state.userSession);
      if (appSessionResult.isLeft()) {
        final failure = appSessionResult.fold((l) => l, (r) => null);
        final message = 'Не удалось создать сессию приложения: ${failure?.message ?? 'неизвестная ошибка'}';
        if (isAutoLogin) {
          if (!mounted) return;
          await _handleSilentSessionFailure(
            // ignore: use_build_context_synchronously
            context,
            message,
          );
        } else {
          _logger.warning('Ошибка создания сессии приложения при логине: $message');
          if (mounted) {
            _showError(message);
          }
        }
        return;
      }

      // 3. Инициализируем пользовательские настройки
      await UserInitializationService.initializeUserSettings(state.userSession.user);

      if (mounted) {
        // ignore: use_build_context_synchronously
        _navigateByUserRole(context, state.userSession.user.role);
      }
    } catch (error, stackTrace) {
      if (isAutoLogin) {
        if (!mounted) return;
        await _handleSilentSessionFailure(
          // ignore: use_build_context_synchronously
          context,
          'Ошибка инициализации: $error',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }

      _logger.severe('Ошибка инициализации после логина', error, stackTrace);
      if (mounted) {
        _showError('Ошибка инициализации: $error');
      }
    }
  }

  Future<void> _handleSilentSessionFailure(
    BuildContext context,
    String reason, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _logger.warning('Не удалось восстановить сохраненную сессию: $reason', error, stackTrace);

    try {
      final sessionRepository = getIt<SessionRepository>();
      final clearResult = await sessionRepository.clearSession();

      clearResult.fold(
        (failure) => _logger.warning('Не удалось очистить поврежденную сессию: ${failure.message}'),
        (_) => _logger.fine('Поврежденная сессия успешно очищена'),
      );
    } catch (cleanupError, cleanupStackTrace) {
      _logger.severe('Исключение при очистке поврежденной сессии', cleanupError, cleanupStackTrace);
    }

    if (!mounted) {
      return;
    }

    // ignore: use_build_context_synchronously
    context.read<AuthenticationBloc>().add(const AuthenticationSessionInvalidated());
  }

  void _navigateByUserRole(BuildContext context, UserRole role) {
    // Все роли переходят на домашнюю страницу из настроек
    NavigationHelper.navigateHome(context, clearStack: true);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка входа'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Не удалось выполнить вход в систему.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Скопируйте это сообщение и отправьте разработчику для устранения проблемы.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ошибка скопирована в буфер обмена'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Скопировать'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          switch (state) {
            case AuthenticationSessionChecking():
              _isRestoringSession = true;
              break;
            case AuthenticationLoading():
              _isRestoringSession = false;
              break;
            case AuthenticationAuthenticated():
              _handleAuthenticationSuccess(
                context,
                state,
                isAutoLogin: _isRestoringSession,
              );
              _isRestoringSession = false;
              break;
            case AuthenticationError():
              _isRestoringSession = false;
              _showError(state.message);
              break;
            case AuthenticationUnauthenticated():
              _isRestoringSession = false;
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

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: FutureBuilder<String>(
                    future: _versionLabelFuture,
                    builder: (context, snapshot) {
                      final label = snapshot.data;
                      if (label == null || label.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
                      return Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              letterSpacing: 0.4,
                            ) ?? TextStyle(
                              fontSize: 12,
                              color: color,
                              letterSpacing: 0.4,
                            ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom-centered overlay spinner when loading or checking session
              if (state is AuthenticationLoading || state is AuthenticationSessionChecking)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
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
