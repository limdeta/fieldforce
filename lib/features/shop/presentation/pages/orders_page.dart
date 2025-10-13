// lib/features/shop/presentation/pages/orders_page.dart

import 'dart:async';

import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/presentation/bloc/orders_bloc.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';
import 'package:fieldforce/shared/services/image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const List<OrderState> _filterableStates = [
    OrderState.pending,
    OrderState.confirmed,
    OrderState.error,
  ];

  static const Map<OrderState, _OrderStatusPresentation> _statusPresentation = {
    OrderState.pending: _OrderStatusPresentation(
      label: 'В обработке',
      color: Color(0xFFF59E0B),
      icon: Icons.hourglass_bottom,
    ),
    OrderState.confirmed: _OrderStatusPresentation(
      label: 'Подтверждён',
      color: Color(0xFF2563EB),
      icon: Icons.verified_outlined,
    ),
    OrderState.error: _OrderStatusPresentation(
      label: 'Требует внимания',
      color: Color(0xFFDC2626),
      icon: Icons.report_problem,
    ),
  };

  static const List<_SortOption> _sortOptions = [
    _SortOption(
      sortType: OrderSortType.byCreatedAt,
      ascending: false,
      label: 'Сначала новые',
      icon: Icons.schedule,
    ),
    _SortOption(
      sortType: OrderSortType.byCreatedAt,
      ascending: true,
      label: 'Сначала старые',
      icon: Icons.history,
    ),
    _SortOption(
      sortType: OrderSortType.byUpdatedAt,
      ascending: false,
      label: 'Недавно обновлённые',
      icon: Icons.update,
    ),
    _SortOption(
      sortType: OrderSortType.byUpdatedAt,
      ascending: true,
      label: 'Давно не обновлялись',
      icon: Icons.history_toggle_off,
    ),
    _SortOption(
      sortType: OrderSortType.byTotalAmount,
      ascending: false,
      label: 'По сумме (убыв.)',
      icon: Icons.payments,
    ),
    _SortOption(
      sortType: OrderSortType.byTotalAmount,
      ascending: true,
      label: 'По сумме (возр.)',
      icon: Icons.payments_outlined,
    ),
    _SortOption(
      sortType: OrderSortType.byOutletName,
      ascending: true,
      label: 'По названию точки',
      icon: Icons.storefront,
    ),
  ];

  late final OrdersBloc _ordersBloc;
  OrdersFilter _lastFilter = const OrdersFilter();
  int? _employeeId;
  final Set<int> _retryingOrders = <int>{};

  @override
  void initState() {
    super.initState();
    _ordersBloc = GetIt.instance<OrdersBloc>();
    _loadOrders();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      sessionResult.fold(
        (failure) => _showErrorSnack(
          'КРИТИЧЕСКАЯ ОШИБКА: Нет активной сессии пользователя. Необходимо войти в систему.',
        ),
        (session) {
          if (session == null) {
            _showErrorSnack(
              'КРИТИЧЕСКАЯ ОШИБКА: Сессия не найдена. Необходимо войти в систему.',
            );
            return;
          }

          final employeeId = session.appUser.employee.id;
          if (employeeId <= 0) {
            _showErrorSnack(
              'КРИТИЧЕСКАЯ ОШИБКА: Некорректный ID сотрудника. Обратитесь к администратору.',
            );
            return;
          }

          _employeeId = employeeId;
          _ordersBloc.add(LoadOrdersEvent(employeeId: employeeId));
        },
      );
    } catch (e) {
      _showErrorSnack('КРИТИЧЕСКАЯ ОШИБКА при загрузке заказов: $e');
    }
  }

  Future<void> _refreshOrders({int? employeeId}) async {
    final id = employeeId ?? _employeeId;
    if (id == null) {
      return;
    }

    final completer = Completer<void>();
    late final StreamSubscription<OrdersState> subscription;

    subscription = _ordersBloc.stream.listen((state) {
      if (state is OrdersLoaded && state.employeeId == id) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription.cancel();
      } else if (state is OrdersError) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription.cancel();
      }
    });

    _ordersBloc.add(RefreshOrdersEvent(employeeId: id));

    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Игнорируем таймаут, чтобы не ронять refresh indicator
    } finally {
      await subscription.cancel();
    }
  }

  void _showErrorSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  void _showInfoSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ordersBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои заказы'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterSheet(_lastFilter),
              tooltip: 'Фильтры',
            ),
            PopupMenuButton<_SortOption>(
              icon: const Icon(Icons.sort),
              tooltip: 'Сортировка',
              initialValue: _currentSortOption(_lastFilter),
              onSelected: (option) => _applyFilter(
                _lastFilter.copyWith(
                  sortType: option.sortType,
                  ascending: option.ascending,
                ),
              ),
              itemBuilder: (context) {
                final current = _currentSortOption(_lastFilter);
                return _sortOptions
                    .map(
                      (option) => PopupMenuItem<_SortOption>(
                        value: option,
                        child: ListTile(
                          leading: Icon(option.icon),
                          title: Text(option.label),
                          trailing: option == current
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                        ),
                      ),
                    )
                    .toList();
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              tooltip: 'Корзина',
            ),
          ],
        ),
        body: BlocConsumer<OrdersBloc, OrdersState>(
          listenWhen: (previous, current) => current is OrdersActionState,
          buildWhen: (previous, current) => current is! OrdersActionState,
          listener: (context, state) {
            if (state is OrderRetryInProgress) {
              if (!mounted) {
                return;
              }
              setState(() {
                _retryingOrders.add(state.orderId);
              });
            } else if (state is OrderRetrySuccess) {
              if (!mounted) {
                return;
              }
              setState(() {
                _retryingOrders.remove(state.orderId);
              });
              _showInfoSnack('Заказ #${state.orderId} отправлен повторно.');
            } else if (state is OrderRetryFailure) {
              if (!mounted) {
                return;
              }
              setState(() {
                _retryingOrders.remove(state.orderId);
              });
              _showErrorSnack(
                'Не удалось отправить заказ #${state.orderId}: ${state.message}',
              );
            }
          },
          builder: (context, state) {
            final filter = _updateFilterFromState(state);
            final statusCounts = _statusCountsForState(state);
            final employeeId = _employeeId;

            if (state is OrdersInitial) {
              return const Center(child: Text('Инициализация...'));
            }
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrdersError) {
              return _buildError(state, employeeId, filter);
            }
            if (state is OrdersEmpty) {
              return _buildEmptyOrders(filter, statusCounts, employeeId);
            }
            if (state is OrdersLoaded) {
              return _buildLoadedOrders(state, statusCounts);
            }
            if (state is OrderDetailLoaded) {
              return _buildOrderDetail(state);
            }

            return const Center(child: Text('Неизвестное состояние'));
          },
        ),
        floatingActionButton: const NavigationFabWidget(
          heroTagPrefix: 'orders',
          showCart: true,
          showHome: true,
        ),
      ),
    );
  }

  OrdersFilter _updateFilterFromState(OrdersState state) {
    if (state is OrdersLoaded) {
      _lastFilter = state.currentFilter;
      _employeeId = state.employeeId;
      return state.currentFilter;
    }
    if (state is OrdersEmpty) {
      _lastFilter = state.currentFilter;
      _employeeId = state.employeeId;
      return state.currentFilter;
    }
    return _lastFilter;
  }

  Map<OrderState, int> _statusCountsForState(OrdersState state) {
    final counts = {
      for (final status in _filterableStates) status: 0,
    };

    if (state is OrdersLoaded) {
      for (final entry in state.statusCounts.entries) {
        counts[entry.key] = entry.value;
      }
    }

    return counts;
  }

  _SortOption _currentSortOption(OrdersFilter filter) {
    return _sortOptions.firstWhere(
      (option) =>
          option.sortType == filter.sortType &&
          option.ascending == filter.ascending,
      orElse: () => _sortOptions.first,
    );
  }

  void _applyFilter(OrdersFilter newFilter) {
    if (_filtersEqual(newFilter, _lastFilter)) {
      return;
    }
    _ordersBloc.add(UpdateOrdersFilterEvent(newFilter));
  }

  bool _filtersEqual(OrdersFilter a, OrdersFilter b) {
    return _sameStates(a.states, b.states) &&
        a.dateFrom == b.dateFrom &&
        a.dateTo == b.dateTo &&
        a.searchQuery == b.searchQuery &&
        a.sortType == b.sortType &&
        a.ascending == b.ascending;
  }

  bool _sameStates(List<OrderState>? a, List<OrderState>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    final setA = Set<OrderState>.from(a);
    final setB = Set<OrderState>.from(b);
    return setA.containsAll(setB) && setB.containsAll(setA);
  }

  void _showFilterSheet(OrdersFilter filter) {
    final initialStates = filter.states?.toSet() ?? _filterableStates.toSet();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final searchController =
            TextEditingController(text: filter.searchQuery ?? '');
        final selectedStates = <OrderState>{...initialStates};
        DateTime? tempFrom = filter.dateFrom;
        DateTime? tempTo = filter.dateTo;

        Future<void> pickDateRange() async {
          final now = DateTime.now();
          final range = await showDateRangePicker(
            context: context,
            initialDateRange: (tempFrom != null && tempTo != null)
                ? DateTimeRange(start: tempFrom!, end: tempTo!)
                : null,
            firstDate: DateTime(now.year - 1),
            lastDate: DateTime(now.year + 1),
            helpText: 'Выберите период',
            cancelText: 'Отмена',
            saveText: 'Применить',
          );

          if (range != null) {
            tempFrom = DateTime(
              range.start.year,
              range.start.month,
              range.start.day,
            );
            tempTo = DateTime(
              range.end.year,
              range.end.month,
              range.end.day,
            );
          }
        }

        void resetFilters(StateSetter modalSetState) {
          modalSetState(() {
            selectedStates
              ..clear()
              ..addAll(_filterableStates);
            tempFrom = null;
            tempTo = null;
            searchController.clear();
          });
        }

        return StatefulBuilder(
          builder: (context, modalSetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final allSelected =
                selectedStates.length == _filterableStates.length;

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + bottomInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Фильтры заказов',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: () => resetFilters(modalSetState),
                            child: const Text('Очистить'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Поиск по номеру или комментарию',
                          prefixIcon: Icon(Icons.search),
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Статусы',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      CheckboxListTile(
                        value: allSelected,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        title: const Text('Все статусы'),
                        onChanged: (value) {
                          modalSetState(() {
                            if (value ?? false) {
                              selectedStates
                                ..clear()
                                ..addAll(_filterableStates);
                            } else {
                              selectedStates.clear();
                            }
                          });
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filterableStates.length,
                          itemBuilder: (context, index) {
                            final status = _filterableStates[index];
                            final meta = _statusPresentation[status] ??
                                _OrderStatusPresentation(
                                  label: status.name,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  icon: Icons.help_outline,
                                );

                            return CheckboxListTile(
                              value: selectedStates.contains(status),
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              title: Text(meta.label),
                              secondary: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(meta.icon, color: meta.color),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    tooltip: 'Оставить только этот статус',
                                    icon: const Icon(Icons.filter_alt_outlined),
                                    onPressed: () {
                                      modalSetState(() {
                                        selectedStates
                                          ..clear()
                                          ..add(status);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              onChanged: (value) {
                                modalSetState(() {
                                  if (value ?? false) {
                                    selectedStates.add(status);
                                  } else {
                                    selectedStates.remove(status);
                                  }
                                  if (selectedStates.isEmpty) {
                                    selectedStates.add(status);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.date_range),
                        title: const Text('Период'),
                        subtitle: Text(_formatDateRangeLabel(
                          OrdersFilter(
                            dateFrom: tempFrom,
                            dateTo: tempTo,
                            states: selectedStates.length ==
                                    _filterableStates.length
                                ? null
                                : selectedStates.toList(),
                            searchQuery: searchController.text,
                          ),
                        )),
                        onTap: () async {
                          await pickDateRange();
                          modalSetState(() {});
                        },
                        trailing: tempFrom != null || tempTo != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  modalSetState(() {
                                    tempFrom = null;
                                    tempTo = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => resetFilters(modalSetState),
                              child: const Text('Сбросить'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                final normalizedStates =
                  selectedStates.length ==
                      _filterableStates.length
                    ? null
                    : selectedStates.toList();
                final trimmedSearch =
                  searchController.text.trim();
                final hasSearch =
                  trimmedSearch.isNotEmpty;

                _applyFilter(
                  filter.copyWith(
                  states: normalizedStates,
                  clearStates:
                    normalizedStates == null,
                  dateFrom: tempFrom,
                  clearDateFrom: tempFrom == null,
                  dateTo: tempTo,
                  clearDateTo: tempTo == null,
                  searchQuery:
                    hasSearch ? trimmedSearch : null,
                  clearSearch: !hasSearch,
                  ),
                );

                                Navigator.pop(context);
                              },
                              child: const Text('Применить'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateRangeLabel(OrdersFilter filter) {
    final from = filter.dateFrom;
    final to = filter.dateTo;
    if (from == null && to == null) {
      return 'Не выбран';
    }
    if (from != null && to != null) {
      return '${_formatDate(from)} — ${_formatDate(to)}';
    }
    if (from != null) {
      return 'С ${_formatDate(from)}';
    }
    return 'По ${_formatDate(to!)}';
  }

  Widget _buildLoadedOrders(
    OrdersLoaded state,
    Map<OrderState, int> statusCounts,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refreshOrders(employeeId: state.employeeId),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: _buildFilterPanel(
                filter: state.currentFilter,
                statusCounts: statusCounts,
                totalCount: state.totalCount,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = state.orders[index];
                final isFirst = index == 0;
                return Column(
                  children: [
                    if (isFirst) const Divider(height: 0),
                    _buildOrderCard(order),
                    const Divider(height: 0),
                  ],
                );
              },
              childCount: state.orders.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 72,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel({
    required OrdersFilter filter,
    required Map<OrderState, int> statusCounts,
    required int totalCount,
  }) {
    final visibleStates = filter.states ?? _filterableStates;
    final statusSummary = visibleStates.length == _filterableStates.length
        ? 'Все статусы'
        : visibleStates
            .map((state) => _statusPresentation[state]?.label ?? state.name)
            .join(', ');
    final hasDateFilter = filter.dateFrom != null || filter.dateTo != null;
    final searchSummary = filter.searchQuery;
  final statusDetails = statusCounts.entries
    .where((entry) => entry.value > 0)
    .map(
      (entry) =>
        '${_statusPresentation[entry.key]?.label ?? entry.key.name}: ${entry.value}',
    )
    .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Выбранные фильтры',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                statusSummary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (statusDetails.isNotEmpty) ...[
                const SizedBox(height: 6),
                ...statusDetails.map(
                  (line) => Text(
                    line,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              if (hasDateFilter) ...[
                const SizedBox(height: 6),
                Text(
                  'Период: ${_formatDateRangeLabel(filter)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (searchSummary != null && searchSummary.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Поиск: "$searchSummary"',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showFilterSheet(filter),
                  icon: const Icon(Icons.tune),
                  label: const Text('Изменить фильтры'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Всего заказов: $totalCount',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrders(
    OrdersFilter filter,
    Map<OrderState, int> statusCounts,
    int? employeeId,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refreshOrders(employeeId: employeeId),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: _buildFilterPanel(
                filter: filter,
                statusCounts: statusCounts,
                totalCount: 0,
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 96,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Нет заказов',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ваши заказы будут отображаться здесь, как только они появятся.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Перейти в корзину'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    OrdersError state,
    int? employeeId,
    OrdersFilter filter,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки заказов',
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
              onPressed: () => _refreshOrders(employeeId: employeeId),
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final meta = _statusPresentation[order.state] ??
        const _OrderStatusPresentation(
          label: 'Неизвестный статус',
          color: Color(0xFF6B7280),
          icon: Icons.help_outline,
        );

  final totalAmount = _formatMoney(order.totalCost);
  final orderId = order.id;
  final bool canRetry = order.state == OrderState.error && orderId != null;
  final int? retryOrderId = canRetry ? orderId : null;
  final bool isRetrying =
    retryOrderId != null && _retryingOrders.contains(retryOrderId);

    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => _openOrderDetail(order.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Заказ #${order.id ?? '—'}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(meta),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Создан: ${_formatDate(order.createdAt)}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Торговая точка: ${order.outlet.name}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: meta.color,
                ),
                const SizedBox(width: 6),
                Text(
                  '${order.totalQuantity} шт. · $totalAmount',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: meta.color,
                  ),
                ),
              ],
            ),
            if (order.failureReason?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                order.failureReason!,
                style: textTheme.bodySmall?.copyWith(
                  color: meta.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (retryOrderId != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed:
                      isRetrying ? null : () => _retryOrder(retryOrderId),
                  icon: isRetrying
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.restart_alt),
                  label: Text(
                    isRetrying ? 'Отправляем...' : 'Отправить снова',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(_OrderStatusPresentation meta) {
    return Container(
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 18, color: meta.color),
          const SizedBox(width: 6),
          Text(
            meta.label,
            style: TextStyle(
              color: meta.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _openOrderDetail(int? orderId) {
    if (orderId == null) {
      _showErrorSnack('Не удалось открыть заказ: отсутствует идентификатор');
      return;
    }
    _ordersBloc.add(GetOrderByIdEvent(orderId));
  }

  void _retryOrder(int orderId) {
    if (_retryingOrders.contains(orderId)) {
      return;
    }
  _ordersBloc.add(RetryOrderSubmissionEvent(orderId));
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _describePaymentKind(PaymentKind paymentKind) {
    if (!paymentKind.isValid()) {
      return 'Не указан';
    }

    final paymentLabel = paymentKind.paymentLabel;
    final documentLabel = paymentKind.documentLabel;

    if (documentLabel != '—' && documentLabel.isNotEmpty) {
      return '$paymentLabel · $documentLabel';
    }

    return paymentLabel;
  }

  String _formatMoney(int amountInCents) {
    final sign = amountInCents < 0 ? '-' : '';
    final absValue = amountInCents.abs();
    final rubles = absValue ~/ 100;
    final pennies = absValue % 100;

    final rublesStr = rubles
        .toString()
        .replaceAll(RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'), ' ');

    return '$sign$rublesStr,${pennies.toString().padLeft(2, '0')} ₽';
  }

  Widget _buildOrderDetail(OrderDetailLoaded state) {
    final order = state.order;
    final meta = _statusPresentation[order.state] ??
        const _OrderStatusPresentation(
          label: 'Неизвестный статус',
          color: Color(0xFF6B7280),
          icon: Icons.help_outline,
        );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${order.id ?? '—'}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final id = _employeeId ?? order.creator.id;
            _ordersBloc.add(
              LoadOrdersEvent(
                employeeId: id,
                filter: _lastFilter,
              ),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.outlet.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Создан: ${_formatDate(order.createdAt)}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Обновлён: ${_formatDate(order.updatedAt)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildStatusChip(meta),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Итого: ${_formatMoney(order.totalCost)}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.totalQuantity} товар(ов) · ${order.itemCount} позиций',
            style: textTheme.bodyMedium,
          ),
          if (order.failureReason?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              'Причина ошибки',
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              order.failureReason!,
              style: textTheme.bodyMedium?.copyWith(color: meta.color),
            ),
          ],
          const SizedBox(height: 16),
          _buildDetailInfoSection(order),
          const SizedBox(height: 16),
          Text(
            'Товары',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._buildDetailLineItems(order.lines),
        ],
      ),
    );
  }

  Widget _buildDetailInfoSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Торговая точка', order.outlet.name),
        _buildDetailRow(
          'Комментарий',
          order.comment?.isNotEmpty == true ? order.comment! : '—',
        ),
        _buildDetailRow(
          'Способ оплаты',
          _describePaymentKind(order.paymentKind),
        ),
      ],
    );
  }

  List<Widget> _buildDetailLineItems(List<OrderLine> lines) {
    if (lines.isEmpty) {
      return [
        Text(
          'В заказе пока нет товаров',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ];
    }

    final widgets = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      widgets.add(_buildDetailLineRow(lines[i]));
      if (i < lines.length - 1) {
        widgets.add(const Divider(height: 14));
      }
    }
    return widgets;
  }

  Widget _buildDetailLineRow(OrderLine line) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openProductDetail(line),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductThumbnail(line),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.productTitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Артикул: ${line.productVendorCode}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Склад: ${line.warehouseName}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${line.quantity} шт.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(line.totalCost),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(OrderLine line) {
    final image = line.product?.defaultImage;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageCacheService.getCachedThumbnail(
                imageUrl: image.getOptimalUrl(),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.image_not_supported_outlined,
              size: 24,
              color: Colors.grey.shade400,
            ),
    );
  }

  void _openProductDetail(OrderLine line) {
    final product = line.product;
    if (product == null) {
      _showErrorSnack('Информация о товаре недоступна');
      return;
    }

    final productWithStock = ProductWithStock(
      product: product,
      totalStock: line.stockItem.stock,
      maxPrice: line.stockItem.defaultPrice,
      minPrice: line.stockItem.availablePrice ?? line.stockItem.defaultPrice,
      hasDiscounts: line.stockItem.discountValue > 0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailPage(productWithStock: productWithStock),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusPresentation {
  final String label;
  final Color color;
  final IconData icon;

  const _OrderStatusPresentation({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _SortOption {
  final OrderSortType sortType;
  final bool ascending;
  final String label;
  final IconData icon;

  const _SortOption({
    required this.sortType,
    required this.ascending,
    required this.label,
    required this.icon,
  });
}
