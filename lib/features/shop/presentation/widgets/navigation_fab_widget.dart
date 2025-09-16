// lib/features/shop/presentation/widgets/navigation_fab_widget.dart

import 'package:flutter/material.dart';

/// Виджет с плавающими кнопками навигации
/// Содержит иконки корзины и дома для быстрой навигации
class NavigationFabWidget extends StatelessWidget {
  final VoidCallback? onCartPressed;
  final VoidCallback? onHomePressed;
  final bool showCart;
  final bool showHome;
  final String? heroTagPrefix;

  const NavigationFabWidget({
    super.key,
    this.onCartPressed,
    this.onHomePressed,
    this.showCart = true,
    this.showHome = true,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Кнопка корзины
        if (showCart) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FloatingActionButton(
              heroTag: "${heroTagPrefix ?? 'default'}_cart",
              onPressed: onCartPressed ?? () {
                // TODO: Переход к корзине
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Переход к корзине'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 6,
              tooltip: 'Корзина',
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],

        // Кнопка дома
        if (showHome) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: FloatingActionButton(
              heroTag: "${heroTagPrefix ?? 'default'}_home",
              onPressed: onHomePressed ?? () {
                // Переход на домашнюю страницу торгового представителя
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/sales-home',
                  (route) => false, // Удаляем все предыдущие маршруты
                );
              },
              backgroundColor: const Color.fromARGB(255, 73, 67, 160),
              foregroundColor: Colors.white,
              elevation: 6,
              tooltip: 'Домой',
              child: const Icon(Icons.home),
            ),
          ),
        ],
      ],
    );
  }
}