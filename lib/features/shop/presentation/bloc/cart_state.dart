// lib/features/shop/presentation/bloc/cart_state.dart

part of 'cart_bloc.dart';

/// Состояния для управления корзиной
@immutable
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние корзины
class CartInitial extends CartState {
  const CartInitial();
}

/// Загружается корзина
class CartLoading extends CartState {
  const CartLoading();
}

/// Корзина загружена успешно
class CartLoaded extends CartState {
  final Order cart;
  final List<OrderLine> orderLines;
  final double totalAmount;
  final int totalItems;

  const CartLoaded({
    required this.cart,
    required this.orderLines,
    required this.totalAmount,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [cart, orderLines, totalAmount, totalItems];

  CartLoaded copyWith({
    Order? cart,
    List<OrderLine>? orderLines,
    double? totalAmount,
    int? totalItems,
  }) {
    return CartLoaded(
      cart: cart ?? this.cart,
      orderLines: orderLines ?? this.orderLines,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

class CartError extends CartState {
  final String message;
  final Object? error;

  const CartError({
    required this.message,
    this.error,
  });

  @override
  List<Object?> get props => [message, error];
}

class CartEmpty extends CartState {
  final Order cart;

  const CartEmpty({required this.cart});

  @override
  List<Object?> get props => [cart];
}

class CartSubmitted extends CartState {
  final Order submittedOrder;
  final Order newCart; // Новая пустая корзина

  const CartSubmitted({
    required this.submittedOrder,
    required this.newCart,
  });

  @override
  List<Object?> get props => [submittedOrder, newCart];
}

class CartSentToReview extends CartState {
  final Order reviewOrder;
  final Order newCart; // Новая пустая корзина

  const CartSentToReview({
    required this.reviewOrder,
    required this.newCart,
  });

  @override
  List<Object?> get props => [reviewOrder, newCart];
}