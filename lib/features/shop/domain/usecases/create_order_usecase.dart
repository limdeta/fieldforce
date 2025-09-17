import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';

/// Use case для создания нового заказа
class CreateOrderUseCase {
  final OrderRepository _orderRepository;

  CreateOrderUseCase(this._orderRepository);

  /// Создает новый заказ в статусе "черновик" для торговой точки
  Future<Order> call({
    required Employee employee,
    required TradingPoint tradingPoint,
  }) async {
    // Проверяем, нет ли уже черновика для данной торговой точки
    final existingDraft = await _orderRepository.getCurrentDraftOrder(
      employee.id, 
      tradingPoint.id!,
    );

    // Если черновик существует, возвращаем его
    return existingDraft;
  }
}