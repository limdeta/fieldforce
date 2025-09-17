// lib/features/shop/presentation/bloc/cart_event.dart

part of 'cart_bloc.dart';

@immutable
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузить текущую корзину (создать draft заказ если его нет)
class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

/// Добавить товар в корзину (старый способ)
class AddToCartEvent extends CartEvent {
  final String productCode;
  final int quantity;
  final String? warehouseId;

  const AddToCartEvent({
    required this.productCode,
    required this.quantity,
    this.warehouseId,
  });

  @override
  List<Object?> get props => [productCode, quantity, warehouseId];
}

class AddStockItemToCartEvent extends CartEvent {
  final int stockItemId;
  final int quantity;

  const AddStockItemToCartEvent({
    required this.stockItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [stockItemId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final int orderLineId;

  const RemoveFromCartEvent(this.orderLineId);

  @override
  List<Object?> get props => [orderLineId];
}

class UpdateCartLineEvent extends CartEvent {
  final int orderLineId;
  final int newQuantity;

  const UpdateCartLineEvent({
    required this.orderLineId,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [orderLineId, newQuantity];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

/// Обновить параметры заказа (способ оплаты, доставка и т.д.)
class UpdateCartDetailsEvent extends CartEvent {
  final PaymentKind? paymentKind;
  final bool? isPickup;
  final DateTime? approvedDeliveryDay;
  final DateTime? approvedAssemblyDay;
  final String? comment;
  final int? outletId;

  const UpdateCartDetailsEvent({
    this.paymentKind,
    this.isPickup,
    this.approvedDeliveryDay,
    this.approvedAssemblyDay,
    this.comment,
    this.outletId,
  });

  @override
  List<Object?> get props => [
        paymentKind,
        isPickup,
        approvedDeliveryDay,
        approvedAssemblyDay,
        comment,
        outletId,
      ];
}

/// Отправить заказ (изменить статус с draft на pending)
class SubmitCartEvent extends CartEvent {
  final bool withoutRealization;

  const SubmitCartEvent({
    this.withoutRealization = false,
  });

  @override
  List<Object?> get props => [withoutRealization];
}

/// Отправить заказ на ручную проверку. TODO проверить нужно ли это оставлять
class SendCartToReviewEvent extends CartEvent {
  const SendCartToReviewEvent();
}