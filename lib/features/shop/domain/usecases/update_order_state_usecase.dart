import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';

/// Use case для изменения статуса заказа
class UpdateOrderStateUseCase {
  final OrderRepository _orderRepository;

  UpdateOrderStateUseCase(this._orderRepository);

  /// Переводит заказ в новое состояние
  Future<Order> call({
    required Order order,
    required OrderState newState,
  }) async {
    // Проверяем, что переход возможен
    if (!order.state.canTransitionTo(newState)) {
      throw StateError('Невозможен переход из ${order.state} в $newState');
    }

    // Дополнительные бизнес-правила
    if (newState == OrderState.pending && order.isEmpty) {
      throw StateError('Нельзя отправить пустой заказ');
    }

    if (newState == OrderState.pending && !order.paymentKind.isValid()) {
      throw StateError('Не выбран способ оплаты');
    }

    // Обновляем состояние
    final updatedOrder = order.updateState(newState);

    // Сохраняем заказ
    return await _orderRepository.saveOrder(updatedOrder);
  }
}