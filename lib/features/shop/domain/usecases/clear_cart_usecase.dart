// lib/features/shop/domain/usecases/clear_cart_usecase.dart


import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/features/shop/domain/failures/shop_failures.dart';

/// Параметры для очистки корзины
class ClearCartParams {
  final int employeeId;
  final int outletId;

  const ClearCartParams({
    required this.employeeId,
    required this.outletId,
  });
}

/// Use case для очистки корзины
class ClearCartUseCase {
  final OrderRepository _orderRepository;

  const ClearCartUseCase(this._orderRepository);

  Future<Either<Failure, Order>> call(ClearCartParams params) async {
    try {
      final clearedOrder = await _orderRepository.clearCart(
        employeeId: params.employeeId,
        outletId: params.outletId,
      );
      
      return Right(clearedOrder);
    } catch (e) {
      return Left(CartOperationFailure('очистка корзины', e.toString()));
    }
  }
}