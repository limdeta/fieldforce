import 'package:flutter/material.dart';

/// Общие действия верхней панели каталога (домой, корзина, фильтр).
///
/// Используем этот виджет вместо плавающих FAB, чтобы освободить пространство
/// и разместить компактные иконки в `AppBar`. Заглушка фильтра пока просто
/// показывает диалог, но оставлена точка расширения через колбеки.
class CatalogAppBarActions extends StatelessWidget {
  final bool showCart;
  final bool showFilter;
  final bool showHome;
  final VoidCallback? onCartPressed;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onHomePressed;

  const CatalogAppBarActions({
    super.key,
    this.showCart = true,
    this.showFilter = true,
    this.showHome = true,
    this.onCartPressed,
    this.onFilterPressed,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCart)
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Корзина',
            onPressed: onCartPressed ?? () => Navigator.pushNamed(context, '/cart'),
          ),
        if (showFilter)
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Фильтры',
            onPressed: onFilterPressed ?? () => showCatalogFilterPlaceholder(context),
          ),
        if (showHome)
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Домой',
            onPressed: onHomePressed ?? () => Navigator.of(context).pushNamedAndRemoveUntil(
              '/sales-home',
              (route) => false,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

}

class CatalogFilterButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CatalogFilterButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.tune_outlined),
      tooltip: 'Фильтры',
      onPressed: onPressed ?? () => showCatalogFilterPlaceholder(context),
    );
  }
}

void showCatalogFilterPlaceholder(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Фильтры скоро будут'),
      content: const Text(
        'Фасетные фильтры появятся в одном из следующих обновлений. '
        'Пока можно продолжать пользоваться поиском и категориями.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}
