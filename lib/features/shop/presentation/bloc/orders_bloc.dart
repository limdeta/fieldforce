// lib/features/shop/presentation/bloc/orders_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_order_by_id_usecase.dart';
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

  OrdersBloc({
    required domain.GetOrdersUseCase getOrdersUseCase,
    required GetOrderByIdUseCase getOrderByIdUseCase,
  })  : _getOrdersUseCase = getOrdersUseCase,
        _getOrderByIdUseCase = getOrderByIdUseCase,
        super(const OrdersInitial()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<UpdateOrdersFilterEvent>(_onUpdateOrdersFilter);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<RefreshOrdersEvent>(_onRefreshOrders);
  }

  /// Загрузить список заказов
  Future<void> _onLoadOrders(LoadOrdersEvent event, Emitter<OrdersState> emit) async {
    try {
      emit(const OrdersLoading());
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
          
          if (orders.isEmpty) {
            emit(OrdersEmpty(
              currentFilter: event.filter ?? const OrdersFilter(),
            ));
          } else {
            // Подсчитываем статистику по статусам
            final statusCounts = <String, int>{};
            for (final order in orders) {
              final status = order.state.toString();
              statusCounts[status] = (statusCounts[status] ?? 0) + 1;
            }

            emit(OrdersLoaded(
              orders: orders,
              currentFilter: event.filter ?? const OrdersFilter(),
              totalCount: orders.length,
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
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      
      // Перезагружаем с новым фильтром
      // Получаем employeeId из текущего состояния (можно добавить в состояние)
      // Пока используем заглушку
      _logger.info('Обновляем фильтр заказов: ${event.filter}');
      
      // TODO: Нужно сохранить employeeId в состоянии для перезагрузки
      emit(OrdersLoaded(
        orders: currentState.orders,
        currentFilter: event.filter,
        totalCount: currentState.totalCount,
        statusCounts: currentState.statusCounts,
      ));
    }
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

  Future<void> _onRefreshOrders(RefreshOrdersEvent event, Emitter<OrdersState> emit) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      
      add(LoadOrdersEvent(
        employeeId: event.employeeId,
        filter: currentState.currentFilter,
      ));
    } else {
      add(LoadOrdersEvent(employeeId: event.employeeId));
    }
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