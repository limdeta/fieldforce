// lib/features/shop/domain/usecases/get_orders_usecase.dart


import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class GetOrdersParams {
  final int employeeId;
  final OrdersFilter? filter;

  const GetOrdersParams({
    required this.employeeId,
    this.filter,
  });
}

/// Фильтр для заказов (дубликат из orders_event.dart для использования в domain слое)
class OrdersFilter {
  final List<OrderState>? states;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? searchQuery;
  final OrderSortType sortType;
  final bool ascending;

  const OrdersFilter({
    this.states,
    this.dateFrom,
    this.dateTo,
    this.searchQuery,
    this.sortType = OrderSortType.byCreatedAt,
    this.ascending = false,
  });
}

enum OrderSortType {
  byCreatedAt,
  byUpdatedAt,
  byTotalAmount,
  byOutletName,
}

class GetOrdersUseCase {
  final OrderRepository _orderRepository;

  const GetOrdersUseCase(this._orderRepository);

  Future<Either<Failure, List<Order>>> call(GetOrdersParams params) async {
    try {
      // Получаем все заказы пользователя
      final allOrders = await _orderRepository.getOrdersByEmployee(params.employeeId);
      
      // Фильтруем draft заказы (они отображаются в корзине)
      final nonDraftOrders = allOrders.where((order) => 
          order.state != OrderState.draft
      ).toList();

      // Применяем дополнительные фильтры если есть
      List<Order> filteredOrders = nonDraftOrders;
      
      if (params.filter != null) {
        filteredOrders = _applyFilters(nonDraftOrders, params.filter!);
      }

      // Сортируем заказы
      _sortOrders(filteredOrders, params.filter?.sortType ?? OrderSortType.byCreatedAt, 
                  params.filter?.ascending ?? false);

      return Right(filteredOrders);
    } catch (e) {
      return Left(NetworkFailure('Ошибка получения списка заказов: $e'));
    }
  }

  List<Order> _applyFilters(List<Order> orders, OrdersFilter filter) {
    List<Order> filtered = List.from(orders);

    // Фильтр по статусам
    if (filter.states != null && filter.states!.isNotEmpty) {
      filtered = filtered.where((order) => filter.states!.contains(order.state)).toList();
    }

    // Фильтр по датам
    if (filter.dateFrom != null) {
      filtered = filtered.where((order) => order.createdAt.isAfter(filter.dateFrom!)).toList();
    }
    if (filter.dateTo != null) {
      filtered = filtered.where((order) => order.createdAt.isBefore(filter.dateTo!.add(const Duration(days: 1)))).toList();
    }

    // Поиск по тексту (номер заказа или комментарий)
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((order) =>
          order.id.toString().contains(query) ||
          (order.comment?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return filtered;
  }

  void _sortOrders(List<Order> orders, OrderSortType sortType, bool ascending) {
    orders.sort((a, b) {
      int result = 0;
      
      switch (sortType) {
        case OrderSortType.byCreatedAt:
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case OrderSortType.byUpdatedAt:
          result = a.updatedAt.compareTo(b.updatedAt);
          break;
        case OrderSortType.byTotalAmount:
          // TODO: Нужно будет добавить вычисление общей суммы заказа
          result = 0; // Заглушка
          break;
        case OrderSortType.byOutletName:
          // TODO: Нужно будет добавить название торговой точки
          result = 0; // Заглушка
          break;
      }
      
      return ascending ? result : -result;
    });
  }
}