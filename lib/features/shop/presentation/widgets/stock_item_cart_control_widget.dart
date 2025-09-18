// lib/features/shop/presentation/widgets/stock_item_cart_control_widget.dart

import 'package:fieldforce/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/stock_item.dart';
import '../bloc/cart_bloc.dart';

/// Виджет для управления добавлением конкретного товара в корзину
/// Товар = Product + StockItem (продукт на конкретном складе)
/// Показывает реальное количество этого товара в корзине
class StockItemCartControlWidget extends StatefulWidget {
  final StockItem stockItem;
  final VoidCallback? onRemove; // Колбэк для удаления из корзины
  final bool showCartIcon;
  final bool isInCart; // Режим корзины (только контрол) или каталога (кнопка + контрол)

  const StockItemCartControlWidget({
    super.key,
    required this.stockItem,
    this.onRemove,
    this.showCartIcon = true,
    this.isInCart = false,
  });

  @override
  State<StockItemCartControlWidget> createState() => _StockItemCartControlWidgetState();
}

class _StockItemCartControlWidgetState extends State<StockItemCartControlWidget> {
  static final Logger _logger = Logger('StockItemCartControlWidget');

  void _addToCart() {
    _logger.info('Добавляем товар ${widget.stockItem.id} (продукт ${widget.stockItem.productCode} со склада ${widget.stockItem.warehouseName}) в корзину');
    context.read<CartBloc>().add(AddStockItemToCartEvent(
      stockItemId: widget.stockItem.id,
      quantity: 1,
    ));
  }

  void _updateQuantity(int newQuantity) {
    _logger.info('Обновляем количество товара ${widget.stockItem.id} на $newQuantity');
    context.read<CartBloc>().add(AddStockItemToCartEvent(
      stockItemId: widget.stockItem.id,
      quantity: newQuantity,
    ));
  }

  void _addPackage() {
    final amountInPackage = widget.stockItem.multiplicity ?? 1;
    final currentQuantity = _getCurrentQuantity();
    _logger.info('Добавляем упаковку товара ${widget.stockItem.id}: $amountInPackage шт');
    
    context.read<CartBloc>().add(AddStockItemToCartEvent(
      stockItemId: widget.stockItem.id,
      quantity: currentQuantity + amountInPackage,
    ));
  }

  int _getCurrentQuantity() {
    final state = context.read<CartBloc>().state;
    if (state is CartLoaded) {
      // Ищем OrderLine для этого конкретного товара (Product + StockItem)
      for (final line in state.orderLines) {
        if (line.stockItem.id == widget.stockItem.id) {
          return line.quantity;
        }
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final currentQuantity = _getCurrentQuantity();
        
        if (widget.isInCart) {
          // Режим корзины - только контрол количества
          return _buildQuantityControl(currentQuantity);
        } else {
          // Режим каталога - кнопка или контрол в зависимости от количества
          if (currentQuantity == 0) {
            return _buildAddButton();
          } else {
            return _buildQuantityControl(currentQuantity);
          }
        }
      },
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: widget.stockItem.stock > 0 ? _addToCart : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.completedStatus,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showCartIcon) ...[
            const Icon(Icons.shopping_cart, size: 16),
            const SizedBox(width: 4),
          ],
          const Text(
            'В корзину',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int quantity) {
    final amountInPackage = widget.stockItem.multiplicity ?? 1;
    final showPackageButton = amountInPackage > 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Кнопка добавления упаковки (всегда показываем если есть)
        if (showPackageButton) ...[
          _buildPackageButton(amountInPackage),
          const SizedBox(width: 4),
        ],
        
        // Кнопка удаления (в режиме корзины)
        if (widget.isInCart && widget.onRemove != null) ...[
          _buildDeleteButton(),
          const SizedBox(width: 4),
        ],
        
        // Кнопка уменьшения
        _buildQuantityButton(
          icon: Icons.remove,
          onPressed: quantity > 0 ? () => _updateQuantity(quantity - 1) : null,
        ),
        
        // Отображение количества
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        
        // Кнопка увеличения
        _buildQuantityButton(
          icon: Icons.add,
          onPressed: quantity < widget.stockItem.stock ? () => _updateQuantity(quantity + 1) : null,
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 16,
        style: IconButton.styleFrom(
          backgroundColor: onPressed != null ? Colors.blue : Colors.grey.shade300,
          foregroundColor: onPressed != null ? Colors.white : Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        icon: Icon(icon),
      ),
    );
  }

  Widget _buildPackageButton(int amountInPackage) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: _addPackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          '+$amountInPackage',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        onPressed: widget.onRemove,
        padding: EdgeInsets.zero,
        iconSize: 16,
        style: IconButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          foregroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}