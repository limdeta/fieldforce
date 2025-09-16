// lib/features/shop/presentation/widgets/cart_control_widget.dart

import 'package:flutter/material.dart';

/// Виджет для управления добавлением товара в корзину
/// Показывает кнопку "В корзину" когда товара нет в корзине
/// Показывает контрол количества когда товар добавлен
class CartControlWidget extends StatefulWidget {
  final int initialQuantity;
  final int? amountInPackage;
  final VoidCallback? onAddToCart;
  final ValueChanged<int>? onQuantityChanged;
  final bool showCartIcon;

  const CartControlWidget({
    super.key,
    this.initialQuantity = 0,
    this.amountInPackage,
    this.onAddToCart,
    this.onQuantityChanged,
    this.showCartIcon = true,
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
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged?.call(_quantity);
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged?.call(_quantity);
    }
  }

  void _addToCart() {
    setState(() {
      _quantity = 1;
    });
    widget.onAddToCart?.call();
    widget.onQuantityChanged?.call(_quantity);
  }

  void _addPackage() {
    if (widget.amountInPackage != null && widget.amountInPackage! > 1) {
      setState(() {
        _quantity += widget.amountInPackage!;
      });
      widget.onQuantityChanged?.call(_quantity);
    }
  }

  void _clearQuantity() {
    setState(() {
      _quantity = 0;
    });
    widget.onQuantityChanged?.call(_quantity);
  }

  @override
  Widget build(BuildContext context) {
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
                  side: BorderSide(color: Colors.blue.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  '+${widget.amountInPackage}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
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
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }

    // Если количество > 0 - показываем контрол количества
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Иконка корзины (опционально)
        if (widget.showCartIcon) ...[
          Icon(
            Icons.shopping_cart,
            size: 20,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 8),
        ],

        // Кнопка быстрого добавления упаковки (если amountInPackage > 1)
        if (widget.amountInPackage != null && widget.amountInPackage! > 1) ...[
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: OutlinedButton(
              onPressed: _addPackage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(50, 36),
                side: BorderSide(color: Colors.blue.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                '+${widget.amountInPackage}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ],

        // Кнопка уменьшения
        IconButton(
          onPressed: _decrement,
          icon: const Icon(Icons.remove, size: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Иконка мусорки для сброса количества
        IconButton(
          onPressed: _clearQuantity,
          icon: const Icon(Icons.delete_outline, size: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Количество
        Container(
          constraints: const BoxConstraints(minWidth: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Кнопка увеличения
        IconButton(
          onPressed: _increment,
          icon: const Icon(Icons.add, size: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}