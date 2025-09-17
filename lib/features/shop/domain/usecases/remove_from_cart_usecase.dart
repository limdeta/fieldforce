// lib/features/shop/domain/usecases/remove_from_cart_usecase.dart
import 'package:fieldforce/features/shop/domain/failures/shop_failures.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// Параметры для удаления товара из корзины
class RemoveFromCartParams {
  final int orderLineId;

  const RemoveFromCartParams({
    required this.orderLineId,
  });
}

/// Use case для удаления строки из корзины
/// Аналог PHP deleteLineFromCurrentOrder - удаляет строку заказа
class RemoveFromCartUseCase {
  final OrderRepository _orderRepository;

  const RemoveFromCartUseCase(this._orderRepository);

  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    try {
      await _orderRepository.removeOrderLine(params.orderLineId);
      return const Right(null);
    } catch (e) {
      return Left(CartOperationFailure('удаление товара', e.toString()));
    }
  }
}