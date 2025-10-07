// lib/features/shop/presentation/bloc/orders_event.dart

part of 'orders_bloc.dart';

@immutable
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersEvent extends OrdersEvent {
  final int employeeId;
  final OrdersFilter? filter;

  const LoadOrdersEvent({
    required this.employeeId,
    this.filter,
  });

  @override
  List<Object?> get props => [employeeId, filter];
}

class UpdateOrdersFilterEvent extends OrdersEvent {
  final OrdersFilter filter;

  const UpdateOrdersFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class GetOrderByIdEvent extends OrdersEvent {
  final int orderId;

  const GetOrderByIdEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RetryOrderSubmissionEvent extends OrdersEvent {
  final int orderId;

  const RetryOrderSubmissionEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RefreshOrdersEvent extends OrdersEvent {
  final int employeeId;

  const RefreshOrdersEvent({
    required this.employeeId,
  });

  @override
  List<Object?> get props => [employeeId];
}

class OrdersFilter {
  final List<OrderState>? states;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? searchQuery; // Поиск по номеру или комментарию
  final OrderSortType sortType;
  final bool ascending;

  const OrdersFilter({
    this.states,
    this.dateFrom,
    this.dateTo,
    this.searchQuery,
    this.sortType = OrderSortType.byCreatedAt,
    this.ascending = false, // По умолчанию новые сначала
  });

  OrdersFilter copyWith({
    List<OrderState>? states,
    bool clearStates = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    String? searchQuery,
    bool clearSearch = false,
    OrderSortType? sortType,
    bool? ascending,
  }) {
    return OrdersFilter(
      states: clearStates ? null : (states ?? this.states),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sortType: sortType ?? this.sortType,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Типы сортировки заказов
enum OrderSortType {
  byCreatedAt,
  byUpdatedAt,
  byTotalAmount,
  byOutletName,
}