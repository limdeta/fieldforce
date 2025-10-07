// lib/features/shop/presentation/bloc/orders_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_order_by_id_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/retry_order_submission_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_orders_usecase.dart' as domain;


part 'orders_event.dart';
part 'orders_state.dart';

/// BLoC для управления списком заказов (все кроме draft)
/// Отображает историю заказов пользователя с фильтрацией и сортировкой
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  static final Logger _logger = Logger('OrdersBloc');

  final domain.GetOrdersUseCase _getOrdersUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final RetryOrderSubmissionUseCase _retryOrderSubmissionUseCase;
  int? _currentEmployeeId;
  List<Order> _cachedOrders = const [];
  OrdersFilter _cachedFilter = const OrdersFilter();

  OrdersBloc({
    required domain.GetOrdersUseCase getOrdersUseCase,
    required GetOrderByIdUseCase getOrderByIdUseCase,
    required RetryOrderSubmissionUseCase retryOrderSubmissionUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _getOrderByIdUseCase = getOrderByIdUseCase,
        _retryOrderSubmissionUseCase = retryOrderSubmissionUseCase,
        super(const OrdersInitial()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<UpdateOrdersFilterEvent>(_onUpdateOrdersFilter);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<RefreshOrdersEvent>(_onRefreshOrders);
    on<RetryOrderSubmissionEvent>(_onRetryOrderSubmission);
  }

  /// Загрузить список заказов
  Future<void> _onLoadOrders(LoadOrdersEvent event, Emitter<OrdersState> emit) async {
    try {
      emit(const OrdersLoading());
      _currentEmployeeId = event.employeeId;
      _logger.info('Загружаем заказы для сотрудника ${event.employeeId}');

      final result = await _getOrdersUseCase(domain.GetOrdersParams(
        employeeId: event.employeeId,
        filter: _convertFilterToDomain(event.filter),
      ));

      result.fold(
        (failure) {
          _logger.warning('Ошибка загрузки заказов: ${failure.message}');
          emit(OrdersError(message: failure.message));
        },
        (orders) {
          _logger.info('Загружено заказов: ${orders.length}');

          _cachedFilter = event.filter ?? const OrdersFilter();
          _cacheOrders(orders);

          if (_cachedOrders.isEmpty) {
            emit(OrdersEmpty(
              employeeId: event.employeeId,
              currentFilter: _cachedFilter,
            ));
          } else {
            final statusCounts = _calculateStatusCounts(_cachedOrders);
            emit(OrdersLoaded(
              employeeId: event.employeeId,
              orders: _cloneCachedOrders(),
              currentFilter: _cachedFilter,
              totalCount: _cachedOrders.length,
              statusCounts: statusCounts,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка загрузки заказов', e, stackTrace);
      emit(OrdersError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Обновить фильтр заказов
  Future<void> _onUpdateOrdersFilter(UpdateOrdersFilterEvent event, Emitter<OrdersState> emit) async {
    final employeeId = _currentEmployeeId;
    if (employeeId == null) {
      _logger.warning('Попытка обновить фильтр заказов без загруженного сотрудника');
      return;
    }

    _logger.info('Обновляем фильтр заказов: ${event.filter}');
    emit(const OrdersLoading());
    add(LoadOrdersEvent(employeeId: employeeId, filter: event.filter));
  }

  /// Получить заказ по ID
  Future<void> _onGetOrderById(GetOrderByIdEvent event, Emitter<OrdersState> emit) async {
    try {
      emit(OrderLoading(event.orderId));
      _logger.info('Загружаем заказ по ID: ${event.orderId}');

      final result = await _getOrderByIdUseCase(GetOrderByIdParams(
        orderId: event.orderId,
      ));

      result.fold(
        (failure) {
          _logger.warning('Ошибка загрузки заказа: ${failure.message}');
          emit(OrdersError(message: failure.message));
        },
        (order) {
          _logger.info('Заказ загружен: ${order.id}');
          emit(OrderDetailLoaded(order));
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка загрузки заказа', e, stackTrace);
      emit(OrdersError(message: 'Неожиданная ошибка: $e'));
    }
  }

  Future<void> _onRetryOrderSubmission(
    RetryOrderSubmissionEvent event,
    Emitter<OrdersState> emit,
  ) async {
    if (event.orderId <= 0) {
      _logger.warning('Попытка повторной отправки заказа с некорректным ID: ${event.orderId}');
      emit(OrderRetryFailure(orderId: event.orderId, message: 'Некорректный идентификатор заказа'));
      return;
    }

    final baseState = state;
    emit(OrderRetryInProgress(orderId: event.orderId));

    final result = await _retryOrderSubmissionUseCase(
      RetryOrderSubmissionParams(orderId: event.orderId),
    );

    await result.fold(
      (failure) async {
        _logger.warning('Повторная отправка заказа ${event.orderId} завершилась ошибкой: ${failure.message}');
        emit(OrderRetryFailure(orderId: event.orderId, message: failure.message));
      },
      (updatedOrder) async {
        _logger.info('Заказ ${event.orderId} повторно отправлен, новое состояние: ${updatedOrder.state}');
        _updateCachedOrder(updatedOrder);

        if (baseState is OrdersLoaded) {
          final statusCounts = _calculateStatusCounts(_cachedOrders);
          emit(OrdersLoaded(
            employeeId: baseState.employeeId,
            orders: _cloneCachedOrders(),
            currentFilter: baseState.currentFilter,
            totalCount: _cachedOrders.length,
            statusCounts: statusCounts,
          ));
        } else if (baseState is OrderDetailLoaded) {
          emit(OrderDetailLoaded(updatedOrder));
        }

        emit(OrderRetrySuccess(orderId: event.orderId));
      },
    );
  }

  Future<void> _onRefreshOrders(RefreshOrdersEvent event, Emitter<OrdersState> emit) async {
    final employeeId = event.employeeId;
    final filter = state is OrdersLoaded
        ? (state as OrdersLoaded).currentFilter
        : state is OrdersEmpty
            ? (state as OrdersEmpty).currentFilter
            : null;

    add(LoadOrdersEvent(
      employeeId: employeeId,
      filter: filter,
    ));
  }

  List<Order> _cloneCachedOrders() => List<Order>.from(_cachedOrders);

  void _cacheOrders(List<Order> orders) {
    _cachedOrders = List<Order>.from(orders);
  }

  void _updateCachedOrder(Order updatedOrder) {
    final index = _cachedOrders.indexWhere((order) => order.id == updatedOrder.id);
    if (index == -1) {
      return;
    }
    final updated = List<Order>.from(_cachedOrders);
    updated[index] = updatedOrder;
    _cachedOrders = updated;
  }

  Map<OrderState, int> _calculateStatusCounts(List<Order> orders) {
    final counts = <OrderState, int>{};
    for (final order in orders) {
      counts[order.state] = (counts[order.state] ?? 0) + 1;
    }
    return counts;
  }

  /// Преобразует presentation фильтр в domain фильтр
  domain.OrdersFilter? _convertFilterToDomain(OrdersFilter? presentationFilter) {
    if (presentationFilter == null) {
      return null;
    }

    return domain.OrdersFilter(
      states: presentationFilter.states,
      dateFrom: presentationFilter.dateFrom,
      dateTo: presentationFilter.dateTo,
      searchQuery: presentationFilter.searchQuery,
      sortType: _convertSortTypeToDomain(presentationFilter.sortType),
      ascending: presentationFilter.ascending,
    );
  }

  /// Преобразует presentation sortType в domain sortType
  domain.OrderSortType _convertSortTypeToDomain(OrderSortType presentationSortType) {
    switch (presentationSortType) {
      case OrderSortType.byCreatedAt:
        return domain.OrderSortType.byCreatedAt;
      case OrderSortType.byUpdatedAt:
        return domain.OrderSortType.byUpdatedAt;
      case OrderSortType.byTotalAmount:
        return domain.OrderSortType.byTotalAmount;
      case OrderSortType.byOutletName:
        return domain.OrderSortType.byOutletName;
    }
  }
}