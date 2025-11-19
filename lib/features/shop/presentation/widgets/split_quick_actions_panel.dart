import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/catalog_app_bar_actions.dart';

/// Компактная плавающая панель быстрых действий для сплит-режима каталога.
/// 
/// Заменяет AppBar, освобождая максимум пространства для контента.
/// Содержит минимальный набор кнопок: Домой, Корзина, Фильтры.
class SplitQuickActionsPanel extends StatefulWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onFilterPressed;
  final int? categoryId;

  const SplitQuickActionsPanel({
    super.key,
    this.onHomePressed,
    this.onCartPressed,
    this.onFilterPressed,
    this.categoryId,
  });

  @override
  State<SplitQuickActionsPanel> createState() => _SplitQuickActionsPanelState();
}

class _SplitQuickActionsPanelState extends State<SplitQuickActionsPanel>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.zero,
        color: theme.colorScheme.surface,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопки действий (появляются при раскрытии)
              SizeTransition(
                sizeFactor: _expandAnimation,
                axis: Axis.horizontal,
                axisAlignment: -1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.home_outlined,
                      tooltip: 'Главная',
                      onPressed: widget.onHomePressed ?? () {
                        Navigator.pushReplacementNamed(context, '/menu');
                      },
                    ),
                    const SizedBox(width: 4),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        final itemCount = state is CartLoaded 
                            ? state.orderLines.length 
                            : 0;
                        
                        return _buildActionButton(
                          icon: Icons.shopping_cart_outlined,
                          tooltip: 'Корзина',
                          badge: itemCount > 0 ? itemCount.toString() : null,
                          onPressed: widget.onCartPressed ?? () {
                            Navigator.pushNamed(context, '/cart');
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.filter_list,
                      tooltip: 'Фильтры',
                      onPressed: widget.onFilterPressed ?? () => showCatalogFilters(
                        context,
                        categoryId: widget.categoryId,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              
              // Кнопка разворачивания/сворачивания
              _buildToggleButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    String? badge,
    VoidCallback? onPressed,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, size: 24),
          iconSize: 24,
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return IconButton(
      icon: AnimatedRotation(
        turns: _isExpanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _isExpanded ? Icons.close : Icons.menu,
          size: 26,
        ),
      ),
      iconSize: 26,
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(
        minWidth: 52,
        minHeight: 52,
      ),
      tooltip: _isExpanded ? 'Свернуть' : 'Меню',
      onPressed: _toggleExpand,
    );
  }
}
