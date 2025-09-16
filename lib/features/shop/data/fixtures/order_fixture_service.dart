import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:flutter/foundation.dart';

/// Сервис для создания фикстурных заказов в dev режиме
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
    debugPrint('🛒 Создание фикстурных заказов...');

    final orders = <Order>[];

    try {
      if (tradingPoints.isEmpty) {
        debugPrint('❌ Нет торговых точек для создания заказов');
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

      // 3. Отправленный заказ (второй)
      if (tradingPoints.length > 2) {
        final submittedOrder = await _createOrder(
          employee: employee,
          tradingPoint: tradingPoints[2],
          state: OrderState.pending,
          withItems: true,
        );
        orders.add(submittedOrder);
      }

      debugPrint('✅ Создано ${orders.length} фикстурных заказов');
      return orders;
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка создания фикстурных заказов: $e');
      debugPrint('Stack trace: $stackTrace');
      return orders;
    }
  }

  /// Создает заказ с указанными параметрами
  Future<Order> _createOrder({
    required Employee employee,
    required TradingPoint tradingPoint,
    required OrderState state,
    bool withItems = false,
  }) async {
    debugPrint('🔍 Создаем заказ: employee.id=${employee.id}, tradingPoint.id=${tradingPoint.id}');
    
    // Создаем базовый заказ
    var order = Order.createDraft(
      creator: employee,
      outlet: tradingPoint,
    );

    // Добавляем товары если нужно
    if (withItems) {
      order = _addItemsToOrder(order);
    }

    // Устанавливаем способ оплаты для отправленных заказов
    if (state != OrderState.draft) {
      order = order.copyWith(
        paymentKind: const PaymentKind.cash(),
      );
    }

    // Переводим в нужное состояние
    if (state != OrderState.draft) {
      order = order.updateState(state);
    }

    // Сохраняем заказ
    return await _orderRepository.saveOrder(order);
  }

  /// Добавляет тестовые товары в заказ
  Order _addItemsToOrder(Order order) {
    final lines = <OrderLine>[];

    // Создаем тестовые StockItem и OrderLine
    final stockItem1 = _createTestStockItem(1, 'Тестовый товар 1', 10000);
    final stockItem2 = _createTestStockItem(2, 'Тестовый товар 2', 15000);

    lines.add(
      OrderLine.create(
        orderId: order.id ?? 0,
        stockItem: stockItem1,
        quantity: 2,
      ),
    );

    lines.add(
      OrderLine.create(
        orderId: order.id ?? 0,
        stockItem: stockItem2,
        quantity: 1,
      ),
    );

    return order.copyWith(lines: lines);
  }

  /// Создает тестовый StockItem
  StockItem _createTestStockItem(int id, String title, int price) {
    return StockItem(
      id: id,
      productCode: id,
      warehouseId: 1,
      warehouseName: 'Тестовый склад',
      warehouseVendorId: 'TEST_WAREHOUSE',
      isPickUpPoint: false,
      stock: 100,
      multiplicity: 1,
      publicStock: '100+ шт',
      defaultPrice: price,
      discountValue: 0,
      availablePrice: price,
      currency: 'RUB',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}