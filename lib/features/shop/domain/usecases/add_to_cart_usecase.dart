// lib/features/shop/domain/usecases/add_to_cart_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/features/shop/domain/failures/shop_failures.dart';

class AddToCartParams {
  final int employeeId;
  final int outletId;
  final String productCode;
  final int quantity;
  final String? warehouseId;

  const AddToCartParams({
    required this.employeeId,
    required this.outletId,
    required this.productCode,
    required this.quantity,
    this.warehouseId,
  });
}

/// Use case для добавления товара в корзину
class AddToCartUseCase {
  final OrderRepository _orderRepository;
  final StockItemRepository _stockItemRepository;

  const AddToCartUseCase(this._orderRepository, this._stockItemRepository);

  Future<Either<Failure, Order>> call(AddToCartParams params) async {
    try {
      if (params.quantity < 0) {
        return Left(InvalidQuantityFailure('не может быть отрицательным'));
      }

      final draftOrder = await _orderRepository.getCurrentDraftOrder(
        params.employeeId,
        params.outletId,
      );

      final productCodeInt = int.tryParse(params.productCode);
      if (productCodeInt == null) {
        return Left(InvalidProductCodeFailure(params.productCode));
      }

      final stockItemsResult = await _stockItemRepository.getStockItemsByProductCode(productCodeInt);
      
      return await stockItemsResult.fold(
        (failure) async {
          // Если StockItem не найден - возвращаем domain-ошибку
          return Left(StockItemNotFoundFailure(params.productCode));
        },
        (stockItems) async {
          if (stockItems.isEmpty) {
            return Left(StockItemNotFoundFailure(params.productCode));
          }

          final stockItem = stockItems.first;

          // Проверяем доступное количество
          if (stockItem.stock <= 0) {
            return Left(OutOfStockFailure(params.productCode));
          }

          if (params.quantity > stockItem.stock) {
            return Left(InsufficientStockFailure(stockItem.stock, params.quantity));
          }

          // Ищем существующую OrderLine для этого товара и склада
          final existingOrderLine = draftOrder.lines.where(
            (line) => line.stockItem.productCode == stockItem.productCode &&
                     line.stockItem.warehouseId == stockItem.warehouseId
          ).firstOrNull;

          final Order updatedOrder;
          if (existingOrderLine != null) {
            // УСТАНАВЛИВАЕМ абсолютное количество (не добавляем к существующему)
            updatedOrder = await _orderRepository.updateOrderLineQuantity(
              orderLineId: existingOrderLine.id!,
              newQuantity: params.quantity,
            );
          } else {
            // Создаем новую строку заказа
            final orderLine = OrderLine.create(
              orderId: draftOrder.id!,
              stockItem: stockItem,
              quantity: params.quantity,
            );
            updatedOrder = await _orderRepository.addOrderLine(orderLine);
          }

          return Right(updatedOrder);
        },
      );
    } catch (e) {
      return Left(CartOperationFailure('добавление товара', e.toString()));
    }
  }
}