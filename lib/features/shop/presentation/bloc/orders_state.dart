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
  final List<Order> orders;
  final OrdersFilter currentFilter;
  final int totalCount;
  final Map<String, int> statusCounts; // Количество по статусам

  const OrdersLoaded({
    required this.orders,
    required this.currentFilter,
    required this.totalCount,
    required this.statusCounts,
  });

  @override
  List<Object?> get props => [orders, currentFilter, totalCount, statusCounts];

  OrdersLoaded copyWith({
    List<Order>? orders,
    OrdersFilter? currentFilter,
    int? totalCount,
    Map<String, int>? statusCounts,
  }) {
    return OrdersLoaded(
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
  final OrdersFilter currentFilter;

  const OrdersEmpty({
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [currentFilter];
}