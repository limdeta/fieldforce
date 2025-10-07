import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:logging/logging.dart';

/// Сервис для создания фикстурных заказов в dev режиме
/// Использует уже созданные продукты, не создает новые
class OrderFixtureService {
  static final Logger _logger = Logger('OrderFixtureService');

  final OrderRepository _orderRepository;
  final StockItemRepository _stockItemRepository;

  OrderFixtureService({
    required OrderRepository orderRepository,
    required StockItemRepository stockItemRepository,
  })  : _orderRepository = orderRepository,
        _stockItemRepository = stockItemRepository;

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

    // 3. Подтверждённый заказ
    if (tradingPoints.length > 2) {
      final confirmedOrder = await _createOrder(
        employee: employee,
        tradingPoint: tradingPoints[2],
        state: OrderState.confirmed,
        withItems: true,
      );
      orders.add(confirmedOrder);
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
    
    final linePlaceholderId = -1;
    final List<OrderLine> lines = withItems
        ? await _buildFixtureLines(orderId: linePlaceholderId)
        : <OrderLine>[];

    if (state != OrderState.draft && lines.isEmpty) {
      throw StateError(
        'Не удалось создать фикстурный заказ в состоянии $state с товарами: отсутствуют доступные остатки',
      );
    }

    final order = Order(
      creator: employee,
      outlet: tradingPoint,
      lines: lines,
      state: state,
      paymentKind: state == OrderState.draft 
          ? const PaymentKind.cash() // дефолтное значение для draft
          : const PaymentKind.cash(),
      createdAt: now,
      updatedAt: now,
    );

    final savedOrder = await _orderRepository.saveOrder(order);
    return savedOrder;
  }

  Future<List<OrderLine>> _buildFixtureLines({required int orderId}) async {
    final productRequests = <int, int>{1001: 2, 1002: 1};
    final lines = <OrderLine>[];

    for (final entry in productRequests.entries) {
      final productCode = entry.key;
      final quantity = entry.value;

      final stockItemsResult =
          await _stockItemRepository.getStockItemsByProductCode(productCode);
      final stockItem = stockItemsResult.fold((failure) {
        _logger.warning(
          'Не удалось получить остатки для продукта $productCode: ${failure.message}',
        );
        return null;
      }, (stockItems) {
        if (stockItems.isEmpty) {
          return null;
        }
        // выбираем первый склад с наличием > 0, иначе первый доступный
        final prioritized = stockItems.firstWhere(
          (item) => item.stock > 0,
          orElse: () => stockItems.first,
        );
        return prioritized;
      });

      if (stockItem == null) {
        continue;
      }

      lines.add(
        OrderLine.create(
          orderId: orderId,
          stockItem: stockItem,
          quantity: quantity,
          pricePerUnit: stockItem.availablePrice ?? stockItem.defaultPrice,
        ),
      );
    }

    if (lines.isEmpty) {
      final fallbackResult = await _stockItemRepository.getAvailableStockItems();
      fallbackResult.fold(
        (failure) => _logger.severe(
          'Не удалось получить доступные остатки для фикстурных заказов: ${failure.message}',
        ),
        (stockItems) {
          if (stockItems.isNotEmpty) {
            final stockItem = stockItems.first;
            lines.add(
              OrderLine.create(
                orderId: orderId,
                stockItem: stockItem,
                quantity: 1,
                pricePerUnit: stockItem.availablePrice ?? stockItem.defaultPrice,
              ),
            );
          }
        },
      );
    }

    return lines;
  }
}