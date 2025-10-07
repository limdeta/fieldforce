import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';

void main() {
  group('Order Entity Tests', () {
    late Employee testEmployee;
    late TradingPoint testOutlet;
    late Order draftOrder;

    setUp(() {
      testEmployee = Employee(
        id: 1,
        lastName: 'Тестовый',
        firstName: 'Пользователь',
        role: EmployeeRole.sales,
      );

      testOutlet = TradingPoint(
        id: 1,
        externalId: 'TEST_001',
        name: 'Тестовая точка',
      );

      draftOrder = Order.createDraft(
        creator: testEmployee,
        outlet: testOutlet,
      );
    });

    test('должен создать заказ-черновик с правильным статусом', () {
      expect(draftOrder.state, OrderState.draft);
      expect(draftOrder.creator, testEmployee);
      expect(draftOrder.outlet, testOutlet);
      expect(draftOrder.lines, isEmpty);
      expect(draftOrder.canEdit, isTrue);
      expect(draftOrder.isEmpty, isTrue);
    });

    test('должен корректно вычислять стоимость заказа', () {
      // Создаем тестовые StockItem и OrderLine
      final stockItem1 = _createTestStockItem(1, 'Товар 1', 10000);
      final stockItem2 = _createTestStockItem(2, 'Товар 2', 15000);

      final orderLine1 = OrderLine.create(
        orderId: 1,
        stockItem: stockItem1,
        quantity: 2,
      );

      final orderLine2 = OrderLine.create(
        orderId: 1,
        stockItem: stockItem2,
        quantity: 1,
      );

      final orderWithItems = draftOrder.copyWith(
        lines: [orderLine1, orderLine2],
      );

      expect(orderWithItems.totalCost, 35000); // 2 * 10000 + 1 * 15000
      expect(orderWithItems.itemCount, 2);
      expect(orderWithItems.totalQuantity, 3);
      expect(orderWithItems.isEmpty, isFalse);
    });

    test('должен правильно переходить между состояниями', () {
      // Добавляем товар
      final stockItem = _createTestStockItem(1, 'Товар', 10000);
      final orderLine = OrderLine.create(
        orderId: 1,
        stockItem: stockItem,
        quantity: 1,
      );

      var order = draftOrder.copyWith(
        lines: [orderLine],
        paymentKind: const PaymentKind.cash(),
      );

      expect(order.canSubmit, isTrue);

      // Переводим в pending
      order = order.updateState(OrderState.pending);
      expect(order.state, OrderState.pending);
      expect(order.canEdit, isFalse);

      // Подтверждаем заказ
      order = order.updateState(OrderState.confirmed);
      expect(order.state, OrderState.confirmed);
      expect(order.state.isConfirmed, isTrue);
    });

    test('должен запрещать некорректные переходы состояний', () {
      expect(() => draftOrder.updateState(OrderState.confirmed),
          throwsA(isA<StateError>()));
    });

    test('должен проверять валидность заказа перед отправкой', () {
      // Пустой заказ не может быть отправлен
      expect(draftOrder.canSubmit, isFalse);

      // Заказ без способа оплаты не может быть отправлен
      final stockItem = _createTestStockItem(1, 'Товар', 10000);
      final orderLine = OrderLine.create(
        orderId: 1,
        stockItem: stockItem,
        quantity: 1,
      );

      var order = draftOrder.copyWith(lines: [orderLine]);
      expect(order.canSubmit, isFalse);

      // Заказ с товаром и способом оплаты может быть отправлен
      order = order.copyWith(paymentKind: const PaymentKind.cash());
      expect(order.canSubmit, isTrue);
    });

    test('должен добавлять товары в заказ', () {
      final stockItem = _createTestStockItem(1, 'Товар', 10000);
      final orderLine = OrderLine.create(
        orderId: 1,
        stockItem: stockItem,
        quantity: 2,
      );

      final updatedOrder = draftOrder.addProduct(
        productId: stockItem.productCode,
        orderLine: orderLine,
      );

      expect(updatedOrder.lines.length, 1);
      expect(updatedOrder.lines.first.quantity, 2);
      expect(updatedOrder.totalCost, 20000);
    });
  });

  group('OrderState Tests', () {
    test('должен корректно проверять переходы состояний', () {
      expect(OrderState.draft.canTransitionTo(OrderState.pending), isTrue);
      expect(OrderState.draft.canTransitionTo(OrderState.confirmed), isFalse);

      expect(OrderState.pending.canTransitionTo(OrderState.confirmed), isTrue);
      expect(OrderState.pending.canTransitionTo(OrderState.error), isTrue);
      expect(OrderState.pending.canTransitionTo(OrderState.draft), isFalse);

      expect(OrderState.confirmed.canTransitionTo(OrderState.draft), isFalse);
      expect(OrderState.confirmed.canTransitionTo(OrderState.pending), isFalse);

      expect(OrderState.error.canTransitionTo(OrderState.pending), isTrue);
      expect(OrderState.error.canTransitionTo(OrderState.draft), isTrue);
    });
  });

  group('PaymentKind Tests', () {
    test('должен создавать корректные способы оплаты', () {
      const cash = PaymentKind.cash();
      const card = PaymentKind.card();
      const credit = PaymentKind.credit();
      const empty = PaymentKind.empty();

      expect(cash.isValid(), isTrue);
      expect(card.isValid(), isTrue);
      expect(credit.isValid(), isTrue);
      expect(empty.isValid(), isFalse);

      expect(cash.type, 'cash');
      expect(card.type, 'card');
      expect(credit.type, 'credit');
      expect(empty.type, isNull);
    });
  });
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
    publicStock: '100+ шт',
    defaultPrice: price,
    discountValue: 0,
    offerPrice: price,
    currency: 'RUB',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}