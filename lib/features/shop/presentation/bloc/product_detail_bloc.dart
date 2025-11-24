// lib/features/shop/presentation/bloc/product_detail_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

/// BLoC для управления деталями продукта
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository _productRepository;

  ProductDetailBloc()
      : _productRepository = GetIt.instance<ProductRepository>(),
        super(ProductDetailInitial()) {
    on<ProductDetailLoadProduct>(_onLoadProduct);
    on<ProductDetailReloadProduct>(_onReloadProduct);
  }

  Future<void> _onLoadProduct(
    ProductDetailLoadProduct event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());

    final result = await _productRepository.getProductById(event.productId);

    result.fold(
      (failure) {
        emit(ProductDetailError(failure.message));
      },
      (product) {
        if (product != null) {
          emit(ProductDetailLoaded(product));
        } else {
          emit(ProductDetailNotFound());
        }
      },
    );
  }

  Future<void> _onReloadProduct(
    ProductDetailReloadProduct event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (state is ProductDetailLoaded) {
      final currentProduct = (state as ProductDetailLoaded).product;
      await _onLoadProduct(
        ProductDetailLoadProduct(currentProduct.catalogId),
        emit,
      );
    }
  }
}