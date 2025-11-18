import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_sheet.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_scope.dart';
import 'package:fieldforce/shared/presentation/widgets/home_icon_button.dart';
import 'package:get_it/get_it.dart';

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
  final int? categoryId;

  const CatalogAppBarActions({
    super.key,
    this.showCart = true,
    this.showFilter = true,
    this.showHome = true,
    this.onCartPressed,
    this.onFilterPressed,
    this.categoryId,
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
            onPressed: onFilterPressed ?? () => showCatalogFilters(
              context,
              categoryId: categoryId,
              blocOverride: FacetFilterScope.maybeBlocOf(context),
            ),
          ),
        // Умная кнопка домой - сама решает показываться или нет
        if (showHome)
          const HomeIconButton(),
        const SizedBox(width: 8),
      ],
    );
  }

}

class CatalogFilterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int? categoryId;

  const CatalogFilterButton({super.key, this.onPressed, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.tune_outlined),
      tooltip: 'Фильтры',
      onPressed: onPressed ?? () => showCatalogFilters(
        context,
        categoryId: categoryId,
        blocOverride: FacetFilterScope.maybeBlocOf(context),
      ),
    );
  }
}

Future<void> showCatalogFilters(
  BuildContext context, {
  int? categoryId,
  FacetFilterBloc? blocOverride,
}) async {
  final existingBloc = blocOverride ?? _maybeReadFacetBloc(context);
  if (existingBloc != null) {
    final shouldReload = existingBloc.state.categoryId != categoryId || !existingBloc.state.hasLoadedOnce;
    if (shouldReload) {
      existingBloc.add(
        FacetFilterCategoryChanged(
          categoryId: categoryId,
          forceReload: shouldReload,
        ),
      );
    }
    await _presentFacetSheet(context, existingBloc);
    return;
  }

  final FacetFilterBloc bloc = GetIt.instance<FacetFilterBloc>();
  bloc.add(
    FacetFilterCategoryChanged(
      categoryId: categoryId,
      forceReload: true,
    ),
  );
  await _presentFacetSheet(context, bloc);
  await bloc.close();
}

Future<void> _presentFacetSheet(BuildContext context, FacetFilterBloc bloc) async {
  bloc.add(const FacetFilterSheetOpened());
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Закрыть фильтры',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _FacetFilterDrawerSurface(
        child: BlocProvider.value(
          value: bloc,
          child: const FacetFilterSheet(),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
  bloc.add(const FacetFilterEditingCancelled());
}

FacetFilterBloc? _maybeReadFacetBloc(BuildContext context) {
  final scopeBloc = FacetFilterScope.maybeBlocOf(context);
  if (scopeBloc != null) {
    return scopeBloc;
  }
  try {
    return context.read<FacetFilterBloc>();
  } on ProviderNotFoundException {
    return null;
  }
}

class _FacetFilterDrawerSurface extends StatelessWidget {
  final Widget child;

  const _FacetFilterDrawerSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox.shrink(),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _FilterPanelWrapper(child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPanelWrapper extends StatefulWidget {
  final Widget child;

  const _FilterPanelWrapper({required this.child});

  @override
  State<_FilterPanelWrapper> createState() => _FilterPanelWrapperState();
}

class _FilterPanelWrapperState extends State<_FilterPanelWrapper> {
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => setState(() => _dragOffset = Offset.zero),
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += Offset(details.primaryDelta ?? 0, 0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragOffset.dx < -80 || (details.primaryVelocity ?? 0) < -600) {
          Navigator.of(context).maybePop();
        }
        setState(() {
          _dragOffset = Offset.zero;
        });
      },
      onHorizontalDragCancel: () => setState(() => _dragOffset = Offset.zero),
      child: Transform.translate(
        offset: Offset(_dragOffset.dx.clamp(-80, 0), 0),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 12,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
          child: widget.child,
        ),
      ),
    );
  }
}
