// lib/features/shop/domain/usecases/get_order_by_id_usecase.dart
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// Параметры для получения заказа по ID
class GetOrderByIdParams {
  final int orderId;

  const GetOrderByIdParams({
    required this.orderId,
  });
}

/// Use case для получения заказа по ID
class GetOrderByIdUseCase {
  final OrderRepository _orderRepository;

  const GetOrderByIdUseCase(this._orderRepository);

  Future<Either<Failure, Order>> call(GetOrderByIdParams params) async {
    try {
      final order = await _orderRepository.getOrderById(params.orderId);
      
      if (order == null) {
        return Left(ValidationFailure('Заказ с ID ${params.orderId} не найден'));
      }
      
      return Right(order);
    } catch (e) {
      return Left(NetworkFailure('Ошибка получения заказа: $e'));
    }
  }
}