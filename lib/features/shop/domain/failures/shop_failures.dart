// lib/features/shop/domain/failures/shop_failures.dart

import 'package:fieldforce/shared/failures.dart';

/// Базовая ошибка shop домена
abstract class ShopFailure extends Failure {
  const ShopFailure(super.message);
}

/// Ошибки связанные с продуктами
class ProductNotFoundFailure extends ShopFailure {
  const ProductNotFoundFailure(String productCode) 
    : super('Продукт с кодом $productCode не найден');
}

class ProductUnavailableFailure extends ShopFailure {
  const ProductUnavailableFailure(String productCode) 
    : super('Продукт с кодом $productCode недоступен для заказа');
}

/// Ошибки связанные с остатками и складами
class StockItemNotFoundFailure extends ShopFailure {
  const StockItemNotFoundFailure(String productCode) 
    : super('Товар с кодом $productCode отсутствует на складах');
}

class InsufficientStockFailure extends ShopFailure {
  final int available;
  final int requested;
  
  const InsufficientStockFailure(this.available, this.requested) 
    : super('Недостаточно товара на складе. Доступно: $available, запрошено: $requested');
}

class OutOfStockFailure extends ShopFailure {
  const OutOfStockFailure(String productCode) 
    : super('Товар с кодом $productCode отсутствует на складе');
}

/// Ошибки валидации корзины
class InvalidQuantityFailure extends ShopFailure {
  const InvalidQuantityFailure(String reason) 
    : super('Некорректное количество: $reason');
}

class InvalidProductCodeFailure extends ShopFailure {
  const InvalidProductCodeFailure(String productCode) 
    : super('Некорректный код товара: $productCode');
}

/// Ошибки корзины/заказа
class CartOperationFailure extends ShopFailure {
  const CartOperationFailure(String operation, String reason) 
    : super('Ошибка операции с корзиной ($operation): $reason');
}

class OrderLineNotFoundFailure extends ShopFailure {
  const OrderLineNotFoundFailure(int orderLineId) 
    : super('Строка заказа $orderLineId не найдена');
}

class DraftOrderNotFoundFailure extends ShopFailure {
  const DraftOrderNotFoundFailure(int employeeId, int outletId) 
    : super('Черновик заказа не найден для сотрудника $employeeId в точке $outletId');
}