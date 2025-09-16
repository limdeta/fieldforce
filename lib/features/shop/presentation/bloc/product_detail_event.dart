// lib/features/shop/presentation/bloc/product_detail_event.dart

/// События для BLoC деталей продукта
abstract class ProductDetailEvent {}
class ProductDetailLoadProduct extends ProductDetailEvent {
  final int productId;

  ProductDetailLoadProduct(this.productId);
}

class ProductDetailReloadProduct extends ProductDetailEvent {}