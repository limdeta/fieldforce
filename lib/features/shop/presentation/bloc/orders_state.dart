// lib/features/shop/presentation/bloc/orders_state.dart

part of 'orders_bloc.dart';

@immutable
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final int employeeId;
  final List<Order> orders;
  final OrdersFilter currentFilter;
  final int totalCount;
  final Map<OrderState, int> statusCounts; // Количество по статусам

  const OrdersLoaded({
    required this.employeeId,
    required this.orders,
    required this.currentFilter,
    required this.totalCount,
    required this.statusCounts,
  });

  @override
  List<Object?> get props => [employeeId, orders, currentFilter, totalCount, statusCounts];

  OrdersLoaded copyWith({
    int? employeeId,
    List<Order>? orders,
    OrdersFilter? currentFilter,
    int? totalCount,
    Map<OrderState, int>? statusCounts,
  }) {
    return OrdersLoaded(
      employeeId: employeeId ?? this.employeeId,
      orders: orders ?? this.orders,
      currentFilter: currentFilter ?? this.currentFilter,
      totalCount: totalCount ?? this.totalCount,
      statusCounts: statusCounts ?? this.statusCounts,
    );
  }
}

class OrderLoading extends OrdersState {
  final int orderId;

  const OrderLoading(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderDetailLoaded extends OrdersState {
  final Order order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;
  final Object? error;

  const OrdersError({
    required this.message,
    this.error,
  });

  @override
  List<Object?> get props => [message, error];
}

class OrdersEmpty extends OrdersState {
  final int employeeId;
  final OrdersFilter currentFilter;

  const OrdersEmpty({
    required this.employeeId,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [employeeId, currentFilter];
}

abstract class OrdersActionState extends OrdersState {
  const OrdersActionState();
}

class OrderRetryInProgress extends OrdersActionState {
  final int orderId;

  const OrderRetryInProgress({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderRetrySuccess extends OrdersActionState {
  final int orderId;

  const OrderRetrySuccess({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderRetryFailure extends OrdersActionState {
  final int orderId;
  final String message;

  const OrderRetryFailure({
    required this.orderId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, message];
}