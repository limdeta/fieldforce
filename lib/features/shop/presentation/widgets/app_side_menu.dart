// lib/features/shop/presentation/widgets/app_side_menu.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_sheet.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_constants.dart';

/// Переиспользуемое выдвижное боковое меню для навигации и фильтров
class AppSideMenu extends StatefulWidget {
  const AppSideMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.facetBloc,
    this.showFilters = true,
    this.horizontalGap = 16.0,
    this.animationDuration = kFacetFilterAnimationDuration,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final FacetFilterBloc facetBloc;
  final bool showFilters;
  final double horizontalGap;
  final Duration animationDuration;

  @override
  State<AppSideMenu> createState() => _AppSideMenuState();
}

class _AppSideMenuState extends State<AppSideMenu> {
  static const double _menuWidth = 360;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final isLandscape = mq.orientation == Orientation.landscape;

    // Use viewPadding to account for system UI that may overlay our content
    // (navigation bar, insets, etc). viewPadding provides the raw system
    // insets which is better for avoiding overlap with the OS chrome.
    final leftInset = mq.viewPadding.left; // system left inset
    final rightInset = mq.viewPadding.right; // system right inset (navigation)
    final sideGap = widget.horizontalGap; // small buffer from system UI, configurable
    // Determine maximum available width between system insets so we never
    // allow the side menu to overlap the Android nav/menus.
    final maxAvailableWidth = math.max(0.0, screenWidth - leftInset - rightInset - (sideGap * 2));
    final double panelWidth = isLandscape
      ? math.min(math.min(screenWidth * 0.9, 900), maxAvailableWidth)
      : _menuWidth; // in landscape use up to 90% of screen or cap to 900

    final closedRight = -panelWidth;
    final closedLeft = screenWidth + 10; // offscreen to the right

    // Respect system UI paddings (status bar, navigation bar) to avoid
    // overlapping Android navigation/menu areas. Clamp the openLeft to
    // stay within the safe area horizontally.
    // leftInset/rightInset/sideGap defined above
    final minLeft = (leftInset + sideGap).clamp(0.0, screenWidth);
    final maxLeft = (screenWidth - panelWidth - rightInset - sideGap).clamp(0.0, screenWidth);
    // Ensure clamping min/max are valid: clamp() will throw if min > max.
    final clampLower = math.min(minLeft, maxLeft);
    final clampUpper = math.max(minLeft, maxLeft);
    double openLeftComputed = ((screenWidth - panelWidth) / 2);
    // On devices where system UI (navigation) is present on one side more than
    // the other, prefer to shift the menu to avoid overlapping that UI.
    if (isLandscape) {
      if (rightInset > leftInset) {
        // Align to the right side, leaving gap
        openLeftComputed = (screenWidth - rightInset - sideGap - panelWidth);
      } else if (leftInset > rightInset) {
        // Align to the left side, leaving gap
        openLeftComputed = leftInset + sideGap;
      }
    }
    final openLeft = openLeftComputed.clamp(clampLower, clampUpper);

    if (widget.animationDuration.inMilliseconds > 0) {
      return AnimatedPositioned(
        duration: widget.animationDuration,
        curve: Curves.easeOut,
      top: 0,
      bottom: 0,
      left: isLandscape ? (widget.isOpen ? openLeft : closedLeft) : null,
      right: isLandscape ? null : (widget.isOpen ? (rightInset + sideGap) : closedRight),
      width: panelWidth,
        child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: _buildMenuContent(),
        ),
      ),
      );
    }

    return Positioned(
      top: 0,
      bottom: 0,
      left: isLandscape ? (widget.isOpen ? openLeft : closedLeft) : null,
      right: isLandscape ? null : (widget.isOpen ? (rightInset + sideGap) : closedRight),
      width: panelWidth,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: _buildMenuContent(),
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

// Removed `_SideMenuHandle` - app now uses AppBar FAB for opening filters
