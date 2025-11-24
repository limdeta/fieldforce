// lib/features/shop/presentation/widgets/app_side_menu.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_sheet.dart';

/// Переиспользуемое выдвижное боковое меню для навигации и фильтров
class AppSideMenu extends StatefulWidget {
  const AppSideMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.facetBloc,
    this.showFilters = true,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final FacetFilterBloc facetBloc;
  final bool showFilters;

  @override
  State<AppSideMenu> createState() => _AppSideMenuState();
}

class _AppSideMenuState extends State<AppSideMenu> {
  static const double _menuWidth = 360;
  static const double _handleWidth = 36;
  static const double _handleHeight = 120;
  static const double _handlePeek = 42;

  @override
  Widget build(BuildContext context) {
    final panelWidth = _menuWidth + _handleWidth;
    final closedRight = -(panelWidth - _handlePeek);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      right: widget.isOpen ? 0 : closedRight,
      width: panelWidth,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _handleWidth,
                child: Align(
                  alignment: Alignment.center,
                  child: _SideMenuHandle(
                    width: _handleWidth,
                    height: _handleHeight,
                    isOpen: widget.isOpen,
                    onToggle: widget.onToggle,
                  ),
                ),
              ),
              Expanded(
                child: _buildMenuContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    final theme = Theme.of(context);
    
    return Material(
      elevation: 12,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SideMenuHeader(
            onHomePressed: () => Navigator.pushReplacementNamed(context, '/menu'),
            onCartPressed: () => Navigator.pushNamed(context, '/cart'),
            onClose: widget.onToggle,
          ),
          const Divider(height: 1),
          if (widget.showFilters) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Фильтры',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: FacetFilterSheet(
                showHeader: false,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Дополнительные опции меню',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SideMenuHeader extends StatelessWidget {
  const _SideMenuHeader({
    required this.onHomePressed,
    required this.onCartPressed,
    required this.onClose,
  });

  final VoidCallback onHomePressed;
  final VoidCallback onCartPressed;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Главная',
            onPressed: onHomePressed,
          ),
          const SizedBox(width: 4),
          _CartIconButton(onPressed: onCartPressed),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Скрыть меню',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final count = state is CartLoaded ? state.orderLines.length : 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Корзина',
              onPressed: onPressed,
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SideMenuHandle extends StatefulWidget {
  const _SideMenuHandle({
    required this.width,
    required this.height,
    required this.isOpen,
    required this.onToggle,
  });

  final double width;
  final double height;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  State<_SideMenuHandle> createState() => _SideMenuHandleState();
}

class _SideMenuHandleState extends State<_SideMenuHandle> {
  double _dragDelta = 0;

  void _resetDrag() => _dragDelta = 0;

  bool _shouldToggle(double velocity) {
    const threshold = 40.0;
    const velocityThreshold = 400.0;
    if (widget.isOpen) {
      return _dragDelta > threshold || velocity > velocityThreshold;
    }
    return _dragDelta < -threshold || velocity < -velocityThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        onHorizontalDragStart: (_) => _resetDrag(),
        onHorizontalDragUpdate: (details) => _dragDelta += details.primaryDelta ?? 0,
        onHorizontalDragEnd: (details) {
          if (_shouldToggle(details.primaryVelocity ?? 0)) {
            widget.onToggle();
          }
          _resetDrag();
        },
        onHorizontalDragCancel: _resetDrag,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(9),
              bottomLeft: Radius.circular(9),
            ),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                offset: Offset(-2, 2),
                color: Colors.black26,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final gripWidth = (widget.width - 12).clamp(12, widget.width).toDouble();
                return Container(
                  width: gripWidth,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: index == 1 ? 5 : 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
