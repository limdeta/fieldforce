import 'package:fieldforce/app/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/app/presentation/pages/route_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/theme/app_colors.dart';


class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final RouteRepository _routeRepository = GetIt.instance<RouteRepository>();
  
  List<domain.Route> _routes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserAndRoutes();
  }

  Future<void> _loadUserAndRoutes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Получаем текущую сессию приложения
      final sessionResult = await AppSessionService.getCurrentAppSession();
      if (sessionResult.isLeft()) {
        setState(() {
          _error = 'Не удалось получить сессию пользователя';
          _isLoading = false;
        });
        return;
      }

      final session = sessionResult.fold((l) => throw Exception(l), (r) => r);
      if (session == null) {
        setState(() {
          _error = 'Пользователь не найден в сессии';
          _isLoading = false;
        });
        return;
      }

      // Получаем маршруты пользователя через Employee
      _routeRepository.watchEmployeeRoutes(session.appUser.employee).listen(
        (routes) {
          if (mounted) {
            setState(() {
              _routes = routes.cast<domain.Route>();
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Ошибк�� загрузки маршрутов: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршруты'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/sales-home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserAndRoutes,
          ),
          // Добавляем меню в AppBar вместо FloatingActionButton
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),
        ],
      ),
      body: _buildBody(),
      // Убир��ем FloatingActionButton - он мешал нажатиям в нижней части списка
      // Навигация теперь происходит через AppBar или кнопки в карточках
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка маршрутов...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserAndRoutes,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.route,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет маршрутов',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'У вас пока нет созданных маршрутов',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserAndRoutes,
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }

    // Используем обычный ListView вместо RefreshIndicator для устранения проблем с касанием
    return ListView.builder(
      // Добавляем physics для стабильного поведения скролла
      physics: const AlwaysScrollableScrollPhysics(),
      // Добавляем отступ снизу ��ля удобства прокрутки и касаний
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _routes.length,
      itemBuilder: (context, index) {
        final route = _routes[index];
        return _buildRouteCard(route);
      },
    );
  }

  Widget _buildRouteCard(domain.Route route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок маршрута
            Row(
              children: [
                Icon(
                  _getRouteStatusIcon(route.status),
                  color: _getRouteStatusColor(route.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(route.status),
              ],
            ),
            const SizedBox(height: 8),
            
            // Описание
            if (route.description != null) ...[
              Text(
                route.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Информация о маршруте
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${route.pointsOfInterest.length} точек',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(route.plannedDuration),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Прогресс выполнения
            if (route.status != domain.RouteStatus.planned) ...[
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: route.completionPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getRouteStatusColor(route.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(route.completionPercentage * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else 
              const SizedBox(height: 4),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openRouteDetail(route),
                    icon: const Icon(Icons.list),
                    label: const Text('Подробно'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openRouteOnMap(route),
                    icon: const Icon(Icons.map),
                    label: const Text('На карте'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(domain.RouteStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRouteStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRouteStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        _getRouteStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getRouteStatusColor(status),
        ),
      ),
    );
  }

  IconData _getRouteStatusIcon(domain.RouteStatus status) {
    switch (status) {
      case domain.RouteStatus.planned:
        return Icons.schedule;
      case domain.RouteStatus.active:
        return Icons.directions_run;
      case domain.RouteStatus.completed:
        return Icons.check_circle;
      case domain.RouteStatus.cancelled:
        return Icons.cancel;
      case domain.RouteStatus.paused:
        return Icons.pause_circle;
    }
  }

  Color _getRouteStatusColor(domain.RouteStatus status) {
    switch (status) {
      case domain.RouteStatus.planned:
        return Colors.blue;
      case domain.RouteStatus.active:
        return Colors.orange;
      case domain.RouteStatus.completed:
        return Colors.green;
      case domain.RouteStatus.cancelled:
        return Colors.red;
      case domain.RouteStatus.paused:
        return Colors.grey;
    }
  }

  String _getRouteStatusText(domain.RouteStatus status) {
    switch (status) {
      case domain.RouteStatus.planned:
        return 'Запланирован';
      case domain.RouteStatus.active:
        return 'Активный';
      case domain.RouteStatus.completed:
        return 'Завершен';
      case domain.RouteStatus.cancelled:
        return 'Отменен';
      case domain.RouteStatus.paused:
        return 'Приостановлен';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Неизвестно';
    
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    
    if (hours > 0) {
      return '$hoursч $minutesм';
    } else {
      return '$minutesм';
    }
  }

  void _openRouteDetail(domain.Route route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteDetailPage(route: route),
      ),
    );
  }

  void _openRouteOnMap(domain.Route route) {
    // Сохраняем выбранный маршрут в настройки
    // и переходим на главную страницу, где он автоматически загрузится
    Navigator.pushReplacementNamed(
      context,
      '/sales-home',
      arguments: {'selectedRoute': route},
    );
  }
}
