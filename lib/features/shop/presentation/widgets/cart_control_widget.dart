// lib/features/shop/presentation/widgets/cart_control_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/app/theme/app_colors.dart';

/// Виджет для управления добавлением товара в корзину
/// Показывает кнопку "В корзину" когда товара нет в корзине (режим каталога)
/// Показывает только контрол количества в корзине (режим корзины)
class CartControlWidget extends StatefulWidget {
  final int initialQuantity;
  final int? amountInPackage;
  final VoidCallback? onAddToCart;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove; // Колбэк для удаления из корзины
  final bool showCartIcon;
  final bool isInCart; // Новый параметр для режима корзины

  const CartControlWidget({
    super.key,
    this.initialQuantity = 0,
    this.amountInPackage,
    this.onAddToCart,
    this.onQuantityChanged,
    this.onRemove,
    this.showCartIcon = true,
    this.isInCart = false, // По умолчанию режим каталога
  });

  @override
  State<CartControlWidget> createState() => _CartControlWidgetState();
}

class _CartControlWidgetState extends State<CartControlWidget> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  void didUpdateWidget(CartControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuantity != widget.initialQuantity) {
      _quantity = widget.initialQuantity;
    }
  }

  void _increment() {
    print('🛒 [CartControlWidget] _increment вызван, новое количество: ${_quantity + 1}');
    setState(() {
      _quantity++;
    });
    print('🛒 [CartControlWidget] Вызываем onQuantityChanged($_quantity) колбэк');
    widget.onQuantityChanged?.call(_quantity);
  }

  void _decrement() {
    if (_quantity > 0) {
      print('🛒 [CartControlWidget] _decrement вызван, новое количество: ${_quantity - 1}');
      setState(() {
        _quantity--;
      });
      print('🛒 [CartControlWidget] Вызываем onQuantityChanged($_quantity) колбэк');
      widget.onQuantityChanged?.call(_quantity);
    } else {
      print('🛒 [CartControlWidget] _decrement: количество уже 0, ничего не делаем');
    }
  }

  void _addToCart() {
    print('🛒 [CartControlWidget] _addToCart вызван, добавляем 1 штуку');
    setState(() {
      _quantity = 1;
    });
    // Вызываем только onQuantityChanged с quantity = 1
    // onAddToCart НЕ нужен - достаточно onQuantityChanged
    print('🛒 [CartControlWidget] Вызываем onQuantityChanged(1) для добавления в корзину');
    widget.onQuantityChanged?.call(1);
  }

  void _addPackage() {
    if (widget.amountInPackage != null && widget.amountInPackage! > 1) {
      print('🛒 [CartControlWidget] _addPackage вызван, добавляем ${widget.amountInPackage} штук, новое количество: ${_quantity + widget.amountInPackage!}');
      setState(() {
        _quantity += widget.amountInPackage!;
      });
      print('🛒 [CartControlWidget] Вызываем onQuantityChanged($_quantity) колбэк после добавления упаковки');
      widget.onQuantityChanged?.call(_quantity);
    }
  }

  /// Виджет контроля количества для переиспользования
  Widget _buildQuantityControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Иконка корзины (опционально, только в режиме каталога)
        if (widget.showCartIcon && !widget.isInCart) ...[
          Icon(
            Icons.shopping_cart,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
        ],

        // Кнопка быстрого добавления упаковки (если amountInPackage > 1)
        if (widget.amountInPackage != null && 
            widget.amountInPackage! > 1) ...[
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: OutlinedButton(
              onPressed: _addPackage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(50, 36),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                '+${widget.amountInPackage}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],

        // Кнопка удаления (только в режиме корзины)
        if (widget.isInCart && widget.onRemove != null) ...[
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade600,
            iconSize: 20,
            tooltip: 'Удалить из корзины',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ],

        // Кнопка уменьшения
        IconButton(
          onPressed: _decrement,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),

        // Количество
        Text(
          '$_quantity',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Кнопка увеличения
        IconButton(
          onPressed: _increment,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // В режиме корзины показываем только контрол количества
    if (widget.isInCart) {
      return _buildQuantityControl();
    }

    // Если количество 0 - показываем кнопку "В корзину" с опциональной кнопкой упаковки
    if (_quantity == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка быстрого добавления упаковки (если amountInPackage > 1)
          if (widget.amountInPackage != null && widget.amountInPackage! > 1) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: _addPackage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: const Size(50, 36),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  '+${widget.amountInPackage}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],

          // Кнопка "В корзину"
          ElevatedButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('В корзину'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      );
    }

    // Если количество > 0 - показываем контрол количества
    return _buildQuantityControl();
  }
}