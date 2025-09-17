// lib/features/shop/presentation/pages/orders_page.dart

import 'package:fieldforce/features/shop/presentation/bloc/orders_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/services/app_session_service.dart';
import '../widgets/navigation_fab_widget.dart';

/// Страница списка заказов (все кроме draft)
/// Показывает историю заказов пользователя с фильтрацией и сортировкой
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _ordersBloc = GetIt.instance<OrdersBloc>();
    // Загружаем заказы при инициализации
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      sessionResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('КРИТИЧЕСКАЯ ОШИБКА: Нет активной сессии пользователя. Необходимо войти в систему.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 10),
            ),
          );
        },
        (session) {
          if (session == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('КРИТИЧЕСКАЯ ОШИБКА: Сессия не найдена. Необходимо войти в систему.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 10),
              ),
            );
            return;
          }
          
          final employeeId = session.appUser.employee.id;
          if (employeeId <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('КРИТИЧЕСКАЯ ОШИБКА: Некорректный ID сотрудника. Обратитесь к администратору.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 10),
              ),
            );
            return;
          }
          
          _ordersBloc.add(LoadOrdersEvent(employeeId: employeeId));
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('КРИТИЧЕСКАЯ ОШИБКА при загрузке заказов: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
        actions: [
          // Кнопка фильтра
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Фильтры',
          ),
          // Кнопка перехода к корзине
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            tooltip: 'Корзина',
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _ordersBloc,
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersInitial) {
              return const Center(child: Text('Инициализация...'));
            } else if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersError) {
              return _buildError(state);
            } else if (state is OrdersEmpty) {
              return _buildEmptyOrders();
            } else if (state is OrdersLoaded) {
              return _buildLoadedOrders(state);
            } else if (state is OrderDetailLoaded) {
              return _buildOrderDetail(state);
            }

            return const Center(child: Text('Неизвестное состояние'));
          },
        ),
      ),
      floatingActionButton: NavigationFabWidget(
        heroTagPrefix: 'orders',
        showCart: true,
        showHome: true,
      ),
    );
  }

  /// Виджет ошибки
  Widget _buildError(OrdersError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки заказов',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Перезагрузить заказы
              // _ordersBloc.add(RefreshOrdersEvent(employeeId: 1));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  /// Виджет пустого списка заказов
  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 96,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Нет заказов',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ваши заказы будут отображаться здесь',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Перейти в корзину'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedOrders(OrdersLoaded state) {
    return Column(
      children: [
        // Информация о заказах и фильтрах
        if (state.statusCounts.isNotEmpty) _buildOrdersStats(state),
        
        // Список заказов
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // TODO: Перезагрузить заказы
              // _ordersBloc.add(RefreshOrdersEvent(employeeId: 1));
            },
            child: ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _buildOrderCard(order);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Статистика заказов
  Widget _buildOrdersStats(OrdersLoaded state) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Всего заказов: ${state.totalCount}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: state.statusCounts.entries.map((entry) {
              return Text(
                '${entry.key}: ${entry.value}',
                style: Theme.of(context).textTheme.bodySmall,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(order) {
    Color statusColor = _getStatusColor(order.state.toString());
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(order.state.toString()),
            color: statusColor,
          ),
        ),
        title: Text(
          'Заказ #${order.id}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Создан: ${_formatDate(order.createdAt)}'),
            // TODO: Добавить сумму заказа когда будет доступна
            // Text('Сумма: ${order.totalAmount} ₽'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getStatusText(order.state.toString()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => _openOrderDetail(order.id),
      ),
    );
  }

  Widget _buildOrderDetail(OrderDetailLoaded state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${state.order.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _loadOrders();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основная информация
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация о заказе',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Номер заказа:', '#${state.order.id}'),
                    _buildDetailRow('Статус:', _getStatusText(state.order.state.toString())),
                    _buildDetailRow('Создан:', _formatDate(state.order.createdAt)),
                    _buildDetailRow('Обновлен:', _formatDate(state.order.updatedAt)),
                    if (state.order.comment?.isNotEmpty == true)
                      _buildDetailRow('Комментарий:', state.order.comment!),
                  ],
                ),
              ),
            ),

            // Список товаров
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Товары в заказе',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // TODO: Отобразить список товаров когда будет доступен
                    Text('Товары: ${state.order.lines.length}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтры заказов'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Реализовать фильтры
            Text('Фильтры будут реализованы позже'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _openOrderDetail(int orderId) {
    _ordersBloc.add(GetOrderByIdEvent(orderId));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'В обработке';
      case 'confirmed':
        return 'Подтвержден';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // Не dispose блок здесь, так как он может использоваться в других местах
    super.dispose();
  }
}