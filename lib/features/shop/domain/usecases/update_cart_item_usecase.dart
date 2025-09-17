// lib/features/shop/domain/usecases/update_cart_item_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/failures/shop_failures.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';


/// Параметры для изменения товара в корзине
class UpdateCartItemParams {
  final int employeeId;
  final int outletId;
  final String productCode;
  final int quantity; // 0 = удалить товар из корзины
  final String? warehouseId;

  const UpdateCartItemParams({
    required this.employeeId,
    required this.outletId,
    required this.productCode,
    required this.quantity,
    this.warehouseId,
  });
}

/// Use case для изменения количества товара в корзине
/// Может добавлять новые товары, изменять количество или удалять (quantity = 0)
class UpdateCartItemUseCase {
  final OrderRepository _orderRepository;
  final StockItemRepository _stockItemRepository;

  const UpdateCartItemUseCase(this._orderRepository, this._stockItemRepository);

  Future<Either<Failure, Order>> call(UpdateCartItemParams params) async {
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
          return Left(StockItemNotFoundFailure(params.productCode));
        },
        (stockItems) async {
          if (stockItems.isEmpty) {
            return Left(StockItemNotFoundFailure(params.productCode));
          }
          
          final stockItem = params.warehouseId != null
              ? stockItems.where((item) => item.warehouseId.toString() == params.warehouseId).firstOrNull ?? stockItems.first
              : stockItems.first;

          if (params.quantity > 0) {
            if (stockItem.stock <= 0) {
              return Left(OutOfStockFailure(params.productCode));
            }

            if (params.quantity > stockItem.stock) {
              return Left(InsufficientStockFailure(stockItem.stock, params.quantity));
            }
          }

          final existingOrderLine = draftOrder.lines.where(
            (line) => line.stockItem.productCode == stockItem.productCode &&
                     line.stockItem.warehouseId == stockItem.warehouseId
          ).firstOrNull;

          final Order updatedOrder;
          if (existingOrderLine != null) {
            // quantity = 0 означает удаление товара из корзины TODO проверить
            updatedOrder = await _orderRepository.updateOrderLineQuantity(
              orderLineId: existingOrderLine.id!,
              newQuantity: params.quantity,
            );
          } else if (params.quantity > 0) {
            final orderLine = OrderLine.create(
              orderId: draftOrder.id!,
              stockItem: stockItem,
              quantity: params.quantity,
            );
            updatedOrder = await _orderRepository.addOrderLine(orderLine);
          } else {
            updatedOrder = draftOrder;
          }

          return Right(updatedOrder);
        },
      );
    } catch (e) {
      return Left(CartOperationFailure('обновление товара', e.toString()));
    }
  }
}