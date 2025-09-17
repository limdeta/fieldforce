// lib/features/shop/domain/usecases/submit_order_usecase.dart



import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// Параметры для отправки заказа
class SubmitOrderParams {
  final bool withoutRealization;
  final bool toReview;

  const SubmitOrderParams({
    this.withoutRealization = false,
    this.toReview = false,
  });
}

/// Результат отправки заказа (содержит отправленный заказ и новую корзину)
class SubmitOrderResult {
  final Order submittedOrder;
  final Order newCart;

  const SubmitOrderResult({
    required this.submittedOrder,
    required this.newCart,
  });
}

/// Use case для отправки заказа
class SubmitOrderUseCase {
  final OrderRepository _orderRepository;

  const SubmitOrderUseCase(this._orderRepository);

  Future<Either<Failure, SubmitOrderResult>> call(SubmitOrderParams params) async {
    try {
      // TODO: Нужно будет реализовать submit заказа и создание нового draft
      // Пока оставляем заглушку
      
      throw UnimplementedError('SubmitOrderUseCase еще не реализован');
    } catch (e) {
      return Left(NetworkFailure('Ошибка отправки заказа: $e'));
    }
  }
}