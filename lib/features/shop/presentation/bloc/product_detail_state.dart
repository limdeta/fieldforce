// lib/features/shop/presentation/bloc/product_detail_state.dart

import 'package:fieldforce/features/shop/domain/entities/product.dart';

abstract class ProductDetailState {}
class ProductDetailInitial extends ProductDetailState {}
class ProductDetailLoading extends ProductDetailState {}
class ProductDetailLoaded extends ProductDetailState {
  final Product product;

  ProductDetailLoaded(this.product);
}
class ProductDetailError extends ProductDetailState {
  final String message;

  ProductDetailError(this.message);
}

class ProductDetailNotFound extends ProductDetailState {}