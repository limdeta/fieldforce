import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/app_session.dart';
import '../../domain/usecases/get_current_app_session_usecase.dart';
import '../../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../services/app_session_service.dart';
import '../../theme/app_colors.dart';


/// Главная страница приложения (после авторизации)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppSession? _currentSession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSession();
  }

  Future<void> _loadCurrentSession() async {
    try {
      final getCurrentSession = GetCurrentAppSessionUseCase();
      final result = await getCurrentSession.call();
      
      if (mounted) {
        result.fold(
          (failure) {
            // Если не удалось получить сессию, перенаправляем на логин
            Navigator.of(context).pushReplacementNamed('/login');
          },
          (session) {
            if (session == null) {
              // Нет активной сессии, перенаправляем на логин
              Navigator.of(context).pushReplacementNamed('/login');
            } else {
              setState(() {
                _currentSession = session;
                _isLoading = false;
              });
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      final logoutUseCase = GetIt.instance<LogoutUseCase>();
      final result = await logoutUseCase.call();
      
      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка выхода: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (session) async {
            // Успешный выход - очищаем app session и переходим на страницу входа
            AppSessionService.clearSession();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выхода: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final session = _currentSession!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('fieldforce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Информация о пользователе
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добро пожаловать!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Имя:', session.fullName),
                      _buildInfoRow('Телефон:', session.phoneNumber),
                      const SizedBox(height: 16),
                      // Кнопка карты
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/map');
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Открыть карту'),

                        ),
                      ),
                      
                      // Кнопка админ-панели (только для администраторов)
                      if (session.permissions.contains('admin') || session.permissions.contains('manager'))
                        const SizedBox(height: 8),
                      if (session.permissions.contains('admin') || session.permissions.contains('manager'))
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/admin');
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Панель администратора'),

                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildInfoRow('ID:', session.externalId),
                      _buildInfoRow('Время входа:', _formatDateTime(session.loginTime)),
                      _buildInfoRow('Запомнить:', session.rememberMe ? 'Да' : 'Нет'),
                      if (!session.rememberMe && session.timeUntilExpiry != null)
                        _buildInfoRow(
                          'До истечения сессии:', 
                          _formatDuration(session.timeUntilExpiry!)
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Права доступа
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Права доступа:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...session.permissions.map((permission) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(permission),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопка выхода
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hoursч $minutesм';
  }
}