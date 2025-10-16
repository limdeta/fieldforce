import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// Загружает заказы, связанные с конкретной торговой точкой.
class GetTradingPointOrdersUseCase {
  final OrderRepository _orderRepository;

  const GetTradingPointOrdersUseCase(this._orderRepository);

  Future<Either<Failure, List<Order>>> call(int tradingPointId) async {
    try {
      final orders = await _orderRepository.getOrdersByOutlet(tradingPointId);
      return Right(orders);
    } catch (error) {
      return Left(
        DatabaseFailure(
          'Не удалось получить заказы торговой точки: $error',
          details: error,
        ),
      );
    }
  }
}
