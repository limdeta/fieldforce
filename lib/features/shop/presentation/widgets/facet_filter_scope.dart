import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

typedef FacetScopeBuilder = Widget Function(
  BuildContext context,
  FacetFilterBloc bloc,
  Widget? child,
);

/// Provides a single [FacetFilterBloc] instance for a subtree and keeps it
/// synchronized with the desired catalog/search context. Pages wrap their
/// scaffold with this widget to get consistent filter behavior without
/// duplicating bloc wiring.
class FacetFilterScope extends StatefulWidget {
  const FacetFilterScope({
    super.key,
    required this.child,
    this.categoryId,
    this.autoLoad = true,
  });

  final Widget child;
  final int? categoryId;
  final bool autoLoad;

  static FacetFilterBloc? maybeBlocOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_FacetFilterScopeInherited>();
    return inherited?.bloc;
  }

  @override
  State<FacetFilterScope> createState() => _FacetFilterScopeState();
}

class _FacetFilterScopeState extends State<FacetFilterScope> {
  late final FacetFilterBloc _bloc;
  final Logger _logger = Logger('FacetFilterScope');

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.instance<FacetFilterBloc>();
    _logger.info('FacetFilterScope init, category=${widget.categoryId}');
    if (widget.autoLoad) {
      _requestCategory(widget.categoryId, forceReload: true);
    }
  }

  @override
  void didUpdateWidget(covariant FacetFilterScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      _logger.info('FacetFilterScope category change: ${oldWidget.categoryId} -> ${widget.categoryId}');
      _requestCategory(widget.categoryId, forceReload: true);
    }
  }

  @override
  void dispose() {
    _logger.info('FacetFilterScope dispose');
    _bloc.close();
    super.dispose();
  }

  void _requestCategory(int? categoryId, {required bool forceReload}) {
    _logger.info('FacetFilterScope request category=$categoryId force=$forceReload');
    _bloc.add(
      FacetFilterCategoryChanged(
        categoryId: categoryId,
        forceReload: forceReload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FacetFilterScopeInherited(
      bloc: _bloc,
      child: BlocProvider.value(
        value: _bloc,
        child: widget.child,
      ),
    );
  }
}

class _FacetFilterScopeInherited extends InheritedWidget {
  const _FacetFilterScopeInherited({required super.child, required this.bloc});

  final FacetFilterBloc bloc;

  @override
  bool updateShouldNotify(covariant _FacetFilterScopeInherited oldWidget) => false;
}
