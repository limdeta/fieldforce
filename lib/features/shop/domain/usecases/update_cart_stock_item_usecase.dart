// lib/features/shop/domain/usecases/update_cart_stock_item_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';


/// Параметры для добавления/изменения конкретного StockItem в корзине
class UpdateCartStockItemParams {
  final int employeeId;
  final int outletId;
  final int stockItemId;
  final int quantity;

  const UpdateCartStockItemParams({
    required this.employeeId,
    required this.outletId,
    required this.stockItemId,
    required this.quantity,
  });
}

/// Use case для работы с конкретным StockItem в корзине
class UpdateCartStockItemUseCase {
  final OrderRepository _orderRepository;
  final StockItemRepository _stockItemRepository;

  const UpdateCartStockItemUseCase(this._orderRepository, this._stockItemRepository);

  Future<Either<Failure, Order>> call(UpdateCartStockItemParams params) async {
    try {
      if (params.quantity < 0) {
        return Left(ValidationFailure('Количество не может быть отрицательным'));
      }

      final stockItemResult = await _stockItemRepository.getById(params.stockItemId);
      final stockItem = stockItemResult.fold(
        (failure) => null,
        (item) => item,
      );

      if (stockItem == null) {
        return Left(NotFoundFailure('StockItem с ID ${params.stockItemId} не найден'));
      }

      // Проверяем остатки если добавляем товар
      if (params.quantity > 0 && params.quantity > stockItem.stock) {
        return Left(ValidationFailure(
          'Недостаточно товара на складе. Доступно: ${stockItem.stock}, запрошено: ${params.quantity}'
        ));
      }

      final draftOrder = await _orderRepository.getCurrentDraftOrder(
        params.employeeId,
        params.outletId,
      );

      OrderLine? existingLine;
      for (final line in draftOrder.lines) {
        if (line.stockItem.id == params.stockItemId) {
          existingLine = line;
          break;
        }
      }

      if (params.quantity == 0) {
        if (existingLine != null) {
          final result = await _orderRepository.updateOrderLineQuantity(
            orderLineId: existingLine.id!,
            newQuantity: 0, // Удаление через quantity = 0
          );

          return Right(result);
        }
        return Right(draftOrder);
      } else {
        if (existingLine != null) {
          final result = await _orderRepository.updateOrderLineQuantity(
            orderLineId: existingLine.id!,
            newQuantity: params.quantity,
          );

          return Right(result);
        } else {
          final newOrderLine = OrderLine(
            id: null,
            orderId: draftOrder.id!,
            stockItem: stockItem,
            quantity: params.quantity,
            pricePerUnit: stockItem.offerPrice ?? stockItem.defaultPrice,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final result = await _orderRepository.addOrderLine(newOrderLine);

          return Right(result);
        }
      }
    } catch (e) {
      return Left(NetworkFailure('Неожиданная ошибка: $e'));
    }
  }
}