import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/catalog_app_bar_actions.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_scope.dart';

/// Adds invisible edge swipe zones that call [showCatalogFilters].
/// Let's users open the filter drawer with a horizontal swipe instead of
/// tapping the toolbar button.
class FacetFilterSwipeOverlay extends StatelessWidget {
  const FacetFilterSwipeOverlay({
    super.key,
    required this.child,
    this.categoryId,
    this.edgeWidth = 28,
    this.enabled = true,
    this.blocOverride,
  });

  final Widget child;
  final int? categoryId;
  final double edgeWidth;
  final bool enabled;
  final FacetFilterBloc? blocOverride;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    final scopedBloc = blocOverride ?? FacetFilterScope.maybeBlocOf(context);

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Row(
              children: [
                _EdgeSwipeHandle(
                  width: edgeWidth,
                  direction: _SwipeDirection.fromLeft,
                  onTriggered: () => _openFilters(context, scopedBloc),
                ),
                const Expanded(child: SizedBox.shrink()),
                _EdgeSwipeHandle(
                  width: edgeWidth,
                  direction: _SwipeDirection.fromRight,
                  onTriggered: () => _openFilters(context, scopedBloc),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openFilters(BuildContext context, FacetFilterBloc? bloc) {
    showCatalogFilters(
      context,
      categoryId: categoryId,
      blocOverride: bloc,
    );
  }
}

enum _SwipeDirection { fromLeft, fromRight }

class _EdgeSwipeHandle extends StatefulWidget {
  const _EdgeSwipeHandle({
    required this.direction,
    required this.onTriggered,
    required this.width,
  });

  final _SwipeDirection direction;
  final VoidCallback onTriggered;
  final double width;

  @override
  State<_EdgeSwipeHandle> createState() => _EdgeSwipeHandleState();
}

class _EdgeSwipeHandleState extends State<_EdgeSwipeHandle> {
  static const double _triggerDistance = 40;
  static const double _triggerVelocity = 400;

  double _dragDelta = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => _dragDelta = 0,
        onHorizontalDragUpdate: (details) => _dragDelta += details.primaryDelta ?? 0,
        onHorizontalDragCancel: () => _dragDelta = 0,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          final bool shouldTrigger;
          if (widget.direction == _SwipeDirection.fromLeft) {
            shouldTrigger = _dragDelta > _triggerDistance || velocity > _triggerVelocity;
          } else {
            shouldTrigger = _dragDelta < -_triggerDistance || velocity < -_triggerVelocity;
          }
          if (shouldTrigger) {
            widget.onTriggered();
          }
          _dragDelta = 0;
        },
      ),
    );
  }
}
