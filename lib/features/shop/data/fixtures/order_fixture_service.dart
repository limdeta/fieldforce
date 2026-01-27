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
      serverId: null,  // Фикстурные заказы не отправлены на бэкенд
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
    final lines = <OrderLine>[];

    // Используем динамический поиск доступных остатков вместо хардкода продуктов
    final fallbackResult = await _stockItemRepository.getAvailableStockItems();
    
    await fallbackResult.fold(
      (failure) {
        _logger.severe(
          'Не удалось получить доступные остатки для фикстурных заказов: ${failure.message}',
        );
      },
      (stockItems) {
        if (stockItems.isEmpty) {
          _logger.warning('Нет доступных остатков для создания фикстурных заказов');
          return;
        }

        // Берем первые 2-3 продукта для разнообразия
        final itemsToUse = stockItems.take(3).toList();
        
        for (int i = 0; i < itemsToUse.length; i++) {
          final stockItem = itemsToUse[i];
          final quantity = i == 0 ? 2 : 1; // Первый товар - 2 шт, остальные - по 1
          
          lines.add(
            OrderLine.create(
              orderId: orderId,
              stockItem: stockItem,
              quantity: quantity,
              pricePerUnit: stockItem.availablePrice ?? stockItem.defaultPrice,
            ),
          );
        }
        
        _logger.info('Создано ${lines.length} строк заказа из доступных остатков');
      },
    );

    return lines;
  }
}