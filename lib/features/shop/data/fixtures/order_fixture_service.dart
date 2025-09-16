import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:flutter/foundation.dart';

/// Сервис для создания фикстурных заказов в dev режиме
class OrderFixtureService {
  final OrderRepository _orderRepository;
  final EmployeeRepository _employeeRepository;
  final TradingPointRepository _tradingPointRepository;

  OrderFixtureService({
    required OrderRepository orderRepository,
    required EmployeeRepository employeeRepository,
    required TradingPointRepository tradingPointRepository,
  })  : _orderRepository = orderRepository,
        _employeeRepository = employeeRepository,
        _tradingPointRepository = tradingPointRepository;

  /// Создает несколько тестовых заказов для демонстрации
  Future<List<Order>> createFixtureOrders() async {
    debugPrint('🛒 Создание фикстурных заказов...');

    final orders = <Order>[];

    try {
      // Получаем сотрудников и торговые точки
      final employeesResult = await _employeeRepository.getAll();
      final tradingPointsResult = await _tradingPointRepository.getAll();

      final employees = employeesResult.fold(
        (failure) {
          debugPrint('Ошибка получения сотрудников: $failure');
          return <Employee>[];
        },
        (employees) => employees,
      );

      final tradingPoints = tradingPointsResult.fold(
        (failure) {
          debugPrint('Ошибка получения торговых точек: $failure');
          return <TradingPoint>[];
        },
        (points) => points,
      );

      if (employees.isEmpty || tradingPoints.isEmpty) {
        debugPrint('Недостаточно данных для создания заказов');
        return orders;
      }

      // Создаем несколько заказов в разных состояниях
      final employee = employees.first;

      // 1. Черновик заказа (корзина)
      final draftOrder = await _createOrder(
        employee: employee,
        tradingPoint: tradingPoints[0],
        state: OrderState.draft,
        withItems: true,
      );
      orders.add(draftOrder);

      // 2. Отправленный заказ
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
    final warehouse = Warehouse(
      id: 1,
      name: 'Тестовый склад',
      vendorId: 'TEST_WAREHOUSE',
      isPickUpPoint: false,
    );

    final product = Product(
      title: title,
      barcodes: ['$id'],
      code: id,
      bcode: id,
      catalogId: id,
      novelty: false,
      popular: false,
      isMarked: false,
      images: [],
      categoriesInstock: [],
      numericCharacteristics: [],
      stringCharacteristics: [],
      boolCharacteristics: [],
      stockItems: [],
      canBuy: true,
    );

    return StockItem(
      id: id,
      product: product,
      warehouse: warehouse,
      stock: 100,
      multiplicity: 1,
      publicStock: '100+ шт',
      defaultPrice: price,
      discountValue: 0,
      availablePrice: null,
      offerPrice: price,
      promotion: null,
    );
  }
}