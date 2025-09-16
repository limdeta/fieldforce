import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';

/// Use case для добавления товара в заказ
class AddProductToOrderUseCase {
  final OrderRepository _orderRepository;

  AddProductToOrderUseCase(this._orderRepository);

  /// Добавляет товар в заказ с указанным количеством
  Future<Order> call({
    required Order order,
    required StockItem stockItem,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Количество должно быть больше нуля');
    }

    if (quantity > stockItem.stock) {
      throw ArgumentError('Недостаточно товара на складе. Доступно: ${stockItem.stock}');
    }

    // Создаем строку заказа
    final orderLine = OrderLine.create(
      orderId: order.id ?? 0, // ID заказа (будет обновлен при сохранении)
      stockItem: stockItem,
      quantity: quantity,
    );

    // Добавляем товар в заказ
    final updatedOrder = order.addProduct(
      productId: stockItem.product.code,
      orderLine: orderLine,
    );

    // Сохраняем обновленный заказ
    return await _orderRepository.saveOrder(updatedOrder);
  }
}