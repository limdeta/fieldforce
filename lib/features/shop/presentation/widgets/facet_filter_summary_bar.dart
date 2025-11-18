import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';

class FacetFilterSummaryBar extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const FacetFilterSummaryBar({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(12, 6, 12, 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipLabelColor = theme.colorScheme.onSurface;
    final chipBackgroundColor = theme.colorScheme.surface;

    return BlocBuilder<FacetFilterBloc, FacetFilterState>(
      builder: (context, state) {
        if (!state.hasActiveFilters) {
          return const SizedBox.shrink();
        }

        final color = theme.colorScheme.surfaceVariant.withValues(alpha: 0.5);

        return Container(
          width: double.infinity,
          color: color,
          padding: padding,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...state.appliedBadges.map(
                (badge) => InputChip(
                  label: Text(badge.label),
                  labelStyle: TextStyle(
                    color: chipLabelColor,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: chipBackgroundColor,
                  deleteIconColor: chipLabelColor.withValues(alpha: 0.7),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  onDeleted: state.isApplying
                      ? null
                      : () => _removeBadge(context, badge),
                ),
              ),
              TextButton.icon(
                onPressed: state.isApplying ? null : () => _clearAll(context),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Очистить'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeBadge(BuildContext context, FacetSelectionBadge badge) {
    final bloc = context.read<FacetFilterBloc>();
    bloc
      ..add(
        FacetFilterValueToggled(groupKey: badge.groupKey, value: badge.value),
      )
      ..add(const FacetFilterApplied());
  }

  void _clearAll(BuildContext context) {
    final bloc = context.read<FacetFilterBloc>();
    bloc
      ..add(const FacetFilterCleared())
      ..add(const FacetFilterApplied());
  }
}
