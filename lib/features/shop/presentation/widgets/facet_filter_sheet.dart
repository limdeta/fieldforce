import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';

class FacetFilterSheet extends StatelessWidget {
  const FacetFilterSheet({super.key, this.showHeader = true, this.borderRadius});

  final bool showHeader;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<FacetFilterBloc, FacetFilterState>(
        builder: (context, state) {
          final hasGroups = state.groups.isNotEmpty;
          final hasPending = _hasPendingChanges(state);
          final canApply = hasGroups && hasPending && !state.isApplying;
          final canClear = hasGroups && !state.workingFilter.isEmpty;
          final showScopeHint = state.categoryId == null && !state.isLoading && state.errorMessage == null && !hasGroups;

          Widget body;
          if (showScopeHint) {
            body = const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Загрузите категории каталога или выберите раздел, чтобы применить фильтры.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          } else if (state.errorMessage != null) {
            body = Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _CopyableErrorMessage(message: state.errorMessage!),
                ),
              ),
            );
          } else if (state.isLoading && !hasGroups) {
            body = const Expanded(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!hasGroups) {
            body = const Expanded(
              child: Center(
                child: Text('Нет доступных фильтров для текущего контекста'),
              ),
            );
          } else {
            body = Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return _FacetGroupSection(group: group);
                },
              ),
            );
          }

          return Material(
            color: theme.colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            borderRadius: borderRadius ?? const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Column(
              children: [
                if (showHeader)
                  _SheetHeader(
                    isApplying: state.isApplying,
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                    height: 3,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: state.isApplying
                          ? const LinearProgressIndicator(key: ValueKey('apply-progress'))
                          : const SizedBox(key: ValueKey('apply-progress-hidden')),
                    ),
                  ),
                ),
                body,
                if (state.applyError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _CopyableErrorMessage(
                      message: state.applyError!,
                      dense: true,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: canClear
                              ? () => context.read<FacetFilterBloc>().add(const FacetFilterCleared())
                              : null,
                          child: const Text('Сбросить'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if (state.isApplying) {
                                return theme.colorScheme.primary;
                              }
                              return null;
                            }),
                          ),
                          onPressed: canApply
                              ? () => context.read<FacetFilterBloc>().add(const FacetFilterApplied())
                              : null,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: state.isApplying
                                ? _ApplyingIndicator(theme: theme)
                                : const Text(
                                    'Применить',
                                    key: ValueKey('apply-label'),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _hasPendingChanges(FacetFilterState state) {
    final a = state.workingFilter;
    final b = state.appliedFilter;
    return !_listEquals(a.brandIds, b.brandIds) ||
        !_listEquals(a.manufacturerIds, b.manufacturerIds) ||
        !_listEquals(a.seriesIds, b.seriesIds) ||
        !_listEquals(a.typeIds, b.typeIds) ||
        !_listEquals(a.selectedCategoryIds, b.selectedCategoryIds) ||
        a.onlyNovelty != b.onlyNovelty ||
        a.onlyPopular != b.onlyPopular ||
        !_mapEquals(a.selectedCharacteristics, b.selectedCharacteristics);
  }

  bool _listEquals(List<int> a, List<int> b) => listEquals(a, b);

  bool _mapEquals(Map<int, List<dynamic>> a, Map<int, List<dynamic>> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!listEquals(a[key], b[key])) return false;
    }
    return true;
  }
}

class _ApplyingIndicator extends StatelessWidget {
  final ThemeData theme;

  const _ApplyingIndicator({required this.theme});

  @override
  Widget build(BuildContext context) {
    final indicatorColor = theme.colorScheme.onPrimary;
    return Row(
      key: const ValueKey('apply-progress-indicator'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Применяем...',
          style: TextStyle(color: indicatorColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final bool isApplying;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.isApplying,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Фильтры',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Закрыть',
            onPressed: isApplying ? null : onClose,
          ),
        ],
      ),
    );
  }
}

class _FacetGroupSection extends StatelessWidget {
  final FacetGroup group;

  const _FacetGroupSection({required this.group});

  @override
  Widget build(BuildContext context) {
    if (group.type == FacetGroupType.toggle) {
      final value = group.values.isNotEmpty ? group.values.first : null;
      return SwitchListTile.adaptive(
        title: Text(group.title),
        subtitle: value != null ? Text('Доступно: ${value.count}') : null,
        value: value?.selected ?? false,
        onChanged: value == null
            ? null
            : (_) => context
                .read<FacetFilterBloc>()
                .add(FacetFilterValueToggled(groupKey: group.key, value: value.value)),
      );
    }

    return ExpansionTile(
      title: Text(group.title),
      children: group.values
          .map(
            (value) => CheckboxListTile(
              value: value.selected,
              onChanged: (_) => context
                  .read<FacetFilterBloc>()
                  .add(FacetFilterValueToggled(groupKey: group.key, value: value.value)),
              title: Text(value.label),
              secondary: Text(
                value.count.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CopyableErrorMessage extends StatelessWidget {
  final String message;
  final bool dense;

  const _CopyableErrorMessage({required this.message, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    final textStyle = TextStyle(color: color, fontSize: dense ? 13 : 14);

    return Container(
      padding: dense ? EdgeInsets.zero : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              message,
              style: textStyle,
            ),
          ),
          IconButton(
            tooltip: 'Скопировать',
            icon: const Icon(Icons.copy, size: 18),
            color: color,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка скопирована в буфер обмена.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
