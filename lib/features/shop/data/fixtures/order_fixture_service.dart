import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Сервис для создания фикстурных заказов в dev режиме
/// Использует уже созданные продукты, не создает новые
class OrderFixtureService {
  final OrderRepository _orderRepository;

  OrderFixtureService({
    required OrderRepository orderRepository,
  }) : _orderRepository = orderRepository;

  /// Создает несколько тестовых заказов для демонстрации
  /// Принимает employee и outlet от оркестратора
  Future<List<Order>> createFixtureOrders({
    required Employee employee,
    required List<TradingPoint> tradingPoints,
  }) async {

    final orders = <Order>[];

    if (tradingPoints.isEmpty) {
      return orders;
    }

    // 1. Черновик заказа (корзина)
    final draftOrder = await _createOrder(
      employee: employee,
      tradingPoint: tradingPoints[0],
      state: OrderState.draft,
      withItems: true,
    );
    orders.add(draftOrder);

    // 2. Отправленный заказ (если есть вторая торговая точка)
    if (tradingPoints.length > 1) {
      final pendingOrder = await _createOrder(
        employee: employee,
        tradingPoint: tradingPoints[1],
        state: OrderState.pending,
        withItems: true,
      );
      orders.add(pendingOrder);
    }

    // 3. Завершенный заказ
    if (tradingPoints.length > 2) {
      final completedOrder = await _createOrder(
        employee: employee,
        tradingPoint: tradingPoints[2],
        state: OrderState.completed,
        withItems: true,
      );
      orders.add(completedOrder);
    }

    return orders;
  }

  Future<Order> _createOrder({
    required Employee employee,
    required TradingPoint tradingPoint,
    required OrderState state,
    bool withItems = false,
  }) async {
    final now = DateTime.now();
    
    final order = Order(
      creator: employee,
      outlet: tradingPoint,
      lines: [], // Пустой список сначала
      state: state,
      paymentKind: state == OrderState.draft 
          ? const PaymentKind.cash() // дефолтное значение для draft
          : const PaymentKind.cash(),
      createdAt: now,
      updatedAt: now,
    );

    // Сохраняем заказ чтобы получить ID
    final savedOrder = await _orderRepository.saveOrder(order);
    
    if (withItems && savedOrder.id != null) {
      await _addTestItemsToOrder(savedOrder.id!);
      return await _orderRepository.getOrderById(savedOrder.id!) ?? savedOrder;
    }

    return savedOrder;
  }

  /// Добавляет тестовые товары в заказ
  Future<void> _addTestItemsToOrder(int orderId) async {
      final stockItemRepository = GetIt.instance<StockItemRepository>();
      
      final stockItems1Result = await stockItemRepository.getStockItemsByProductCode(1001);
      final stockItems2Result = await stockItemRepository.getStockItemsByProductCode(1002);

      final stockItem1 = stockItems1Result.fold(
        (failure) {
          return null;
        },
        (stockItems) => stockItems.isNotEmpty ? stockItems.first : null,
      );

      final stockItem2 = stockItems2Result.fold(
        (failure) {
          return null;
        },
        (stockItems) => stockItems.isNotEmpty ? stockItems.first : null,
      );

      // Добавляем только те товары, для которых найдены реальные StockItem'ы
      if (stockItem1 != null) {
        final orderLine1 = OrderLine.create(
          orderId: orderId,
          stockItem: stockItem1,
          quantity: 2,
        );
        await _orderRepository.addOrderLine(orderLine1);
      }

      if (stockItem2 != null) {
        final orderLine2 = OrderLine.create(
          orderId: orderId,
          stockItem: stockItem2,
          quantity: 1,
        );
        await _orderRepository.addOrderLine(orderLine2);
      }
  }



}