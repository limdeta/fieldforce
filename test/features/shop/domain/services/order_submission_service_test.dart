import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOrderApiService implements OrderApiService {
  Failure? failure;
  Map<String, dynamic>? lastPayload;

  @override
  Future<Either<Failure, void>> submitOrder(Map<String, dynamic> orderJson) async {
    lastPayload = orderJson;
    if (failure != null) {
      return Left(failure!);
    }
    return const Right(null);
  }
}

void main() {
  group('OrderSubmissionService', () {
    late _FakeOrderApiService api;
    late OrderSubmissionService service;

    setUp(() {
      api = _FakeOrderApiService();
      service = OrderSubmissionService(apiService: api);
    });

    test('успешно подтверждает заказ', () async {
      final order = _createReadyOrder();

      final result = await service.submit(order);

      expect(result.isRight(), isTrue);
      final updatedOrder = result.getOrElse(() => throw StateError('result is Left'));
      expect(updatedOrder.state, OrderState.confirmed);
      expect(updatedOrder.isConfirmed, isTrue);
      expect(api.lastPayload, isNotNull);
      expect(api.lastPayload!['state'], 'pending');
      expect((api.lastPayload!['lines'] as List), isNotEmpty);
    });

    test('возвращает Left при сетевой ошибке и оставляет заказ в pending', () async {
      api.failure = const NetworkFailure('no internet');
      final order = _createReadyOrder().submit();

      final result = await service.submit(order);

      expect(result.isLeft(), isTrue);
  final failure = result.fold((failure) => failure, (_) => throw StateError('expected Left'));
  expect(failure, isA<NetworkFailure>());
      expect(order.state, OrderState.pending);
      expect(order.failureReason, isNull);
    });

    test('возвращает Left при ответе API с ошибкой', () async {
      const message = 'invalid payload';
      api.failure = const GeneralFailure(message);
      final order = _createReadyOrder().submit();

      final result = await service.submit(order);

      expect(result.isLeft(), isTrue);
  final failure = result.fold((failure) => failure, (_) => throw StateError('expected Left'));
  expect(failure, isA<GeneralFailure>());
  expect((failure as GeneralFailure).message, message);
      expect(order.state, OrderState.pending);
      expect(order.failureReason, isNull);
    });
  });
}

Order _createReadyOrder() {
  final employee = Employee(
    id: 1,
    lastName: 'Иванов',
    firstName: 'Иван',
    role: EmployeeRole.sales,
  );

  final outlet = TradingPoint(
    id: 10,
    externalId: 'TP-10',
    name: 'Аптека №10',
  );

  final draft = Order.createDraft(
    creator: employee,
    outlet: outlet,
  );

  final stockItem = StockItem(
    id: 100,
    productCode: 100,
    warehouseId: 1,
    warehouseName: 'Главный склад',
    warehouseVendorId: 'MAIN',
    isPickUpPoint: true,
    stock: 10,
    publicStock: '10',
    defaultPrice: 5000,
    discountValue: 0,
    offerPrice: null,
    currency: 'RUB',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final line = OrderLine.create(
    orderId: 1,
    stockItem: stockItem,
    quantity: 2,
  );

  final orderWithItems = draft
      .addProduct(productId: stockItem.productCode, orderLine: line)
      .updatePaymentKind(const PaymentKind.cash());

  expect(orderWithItems.canSubmit, isTrue, reason: 'order must be ready to submit in tests');

  return orderWithItems;
}
