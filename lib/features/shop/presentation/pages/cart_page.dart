// lib/features/shop/presentation/pages/cart_page.dart

import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/cart_item_widget.dart';
import 'product_detail_page.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';

/// Страница корзины (текущий draft заказ)
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  
  @override
  void initState() {
    super.initState();
    // Загружаем корзину при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(const LoadCartEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearCartDialog(),
            tooltip: 'Очистить корзину',
          ),
          // Кнопка перехода к заказам
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/orders'),
            tooltip: 'Мои заказы',
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartInitial) {
              return const Center(child: Text('Инициализация корзины...'));
            } else if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CartError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки корзины',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Перезагрузить корзину
                        context.read<CartBloc>().add(const LoadCartEvent());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              );
            } else if (state is CartEmpty) {
              return _buildEmptyCart();
            } else if (state is CartLoaded) {
              return _buildLoadedCart(state);
            } else if (state is CartSubmitted) {
              return _buildCartSubmitted(state);
            }

            return const Center(child: Text('Неизвестное состояние корзины'));
          },
        ),
      floatingActionButton: NavigationFabWidget(
        heroTagPrefix: 'cart',
        showCart: false, // Мы уже в корзине
        showHome: true,
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 96,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Корзина пуста',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Добавьте товары из каталога',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/products/catalog'),
            icon: const Icon(Icons.inventory),
            label: const Text('Перейти в каталог'),
            style: ElevatedButton.styleFrom(
              // Цвета берутся из темы
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Виджет загруженной корзины
  Widget _buildLoadedCart(CartLoaded state) {
    return Column(
      children: [
        // Информация о корзине
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Заказ #${state.cart.id}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Товаров: ${state.totalItems}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Сумма: ${state.totalAmount.toStringAsFixed(2)} ₽',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Список товаров в корзине
        Expanded(
          child: ListView.builder(
            itemCount: state.orderLines.length,
            itemBuilder: (context, index) {
              final orderLine = state.orderLines[index];
              
              return CartItemWidget(
                orderLine: orderLine,
                showNavigation: true,
                onTap: () => _navigateToProductDetails(orderLine),
                onRemove: orderLine.id != null 
                  ? () {
                      _removeItem(orderLine.id!);
                    }
                  : null,
              );
            },
          ),
        ),

        // Кнопки действий
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Кнопка оформления заказа
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _submitOrder(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Оформить заказ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Кнопка отправки на проверку

            ],
          ),
        ),
      ],
    );
  }

  /// Виджет успешной отправки заказа
  Widget _buildCartSubmitted(CartSubmitted state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 96,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Заказ отправлен!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.green.shade600,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Заказ #${state.submittedOrder.id} успешно отправлен.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/orders'),
                child: const Text('Мои заказы'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  // Возвращаемся к каталогу
                  Navigator.of(context).pop();
                },
                child: const Text('Продолжить покупки'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Показать диалог очистки корзины
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Все товары будут удалены из корзины. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartBloc>().add(const ClearCartEvent());
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  /// Удалить товар из корзины
  void _removeItem(int orderLineId) {
    context.read<CartBloc>().add(RemoveFromCartEvent(orderLineId));
  }

  /// Оформить заказ
  void _submitOrder() {
    context.read<CartBloc>().add(const SubmitCartEvent());
  }

  /// Навигация к деталям продукта из корзины
  void _navigateToProductDetails(OrderLine orderLine) async {
    // Для навигации к деталям нужен ProductWithStock, создаем его из OrderLine
    if (orderLine.product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Информация о товаре недоступна')),
      );
      return;
    }

    // Создаем ProductWithStock из данных OrderLine
    final productWithStock = ProductWithStock(
      product: orderLine.product!,
      totalStock: orderLine.stockItem.stock,
      maxPrice: orderLine.stockItem.defaultPrice,
      minPrice: orderLine.stockItem.availablePrice ?? orderLine.stockItem.defaultPrice,
      hasDiscounts: orderLine.stockItem.discountValue > 0,
    );

    // Навигация к ProductDetailPage
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productWithStock: productWithStock),
      ),
    );
  }

  @override
  void dispose() {
    // Не dispose блок здесь, так как он может использоваться в других местах
    super.dispose();
  }
}