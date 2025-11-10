import 'package:fieldforce/app/presentation/bloc/data_sync/data_sync_bloc.dart';
import 'package:fieldforce/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DataSyncBloc>.value(
      value: GetIt.instance<DataSyncBloc>(),
      child: const _DataSyncView(),
    );
  }
}

class _DataSyncView extends StatefulWidget {
  const _DataSyncView();

  @override
  State<_DataSyncView> createState() => _DataSyncViewState();
}

class _DataSyncViewState extends State<_DataSyncView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DataSyncBloc>().add(const DataSyncRefreshContextRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataSyncBloc, DataSyncState>(
      listenWhen: (previous, current) =>
          previous.globalMessage != current.globalMessage && current.globalMessage != null,
      listener: (context, state) {
        final message = state.globalMessage;
        if (message == null || message.isEmpty) {
          return;
        }

        final isError = message.toLowerCase().contains('остановлена') ||
            message.toLowerCase().contains('ошибка') ||
            message.toLowerCase().contains('отменена');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : AppColors.primary,
          ),
        );

        context.read<DataSyncBloc>().add(const DataSyncClearMessage());
      },
      builder: (context, state) {
        final bloc = context.read<DataSyncBloc>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Синхронизация данных'),
            actions: [
              IconButton(
                tooltip: 'Журнал синхронизаций',
                icon: const Icon(Icons.receipt_long),
                onPressed: () => Navigator.of(context).pushNamed('/sync-log'),
              ),
            ],
          ),
          body: state.isInitializing
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SyncContextCard(
                      regionCode: state.currentRegionCode.isEmpty
                          ? '—'
                          : state.currentRegionCode,
                      outletExternalId: state.currentOutletVendorIds.isNotEmpty
                          ? state.currentOutletVendorIds.first
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/sync-log'),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Журнал синхронизации'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FullSyncRow(
                      isRunning: state.isFullSyncInProgress,
                      isBusy: state.isBusy,
                      onRun: () => bloc.add(const DataSyncFullRequested()),
                      onCancel: () => bloc.add(const DataSyncFullCancelRequested()),
                    ),
                    const SizedBox(height: 24),
                    ...DataSyncTask.values.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TaskRow(
                          task: task,
                          info: state.tasks[task] ?? DataSyncTaskInfo.initial,
                          lastRun: state.lastRuns[task],
                          isBusy: state.isBusy,
                          onRun: () => bloc.add(DataSyncTaskRequested(task)),
                          onCancel: () => bloc.add(DataSyncTaskCancelRequested(task)),
                          onReset: () => bloc.add(DataSyncTaskReset(task)),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SyncContextCard extends StatelessWidget {
  const _SyncContextCard({
    required this.regionCode,
    this.outletExternalId,
  });

  final String regionCode;
  final String? outletExternalId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Текущий контекст',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _ContextLine(title: 'Регион', value: regionCode),
          _ContextLine(
            title: 'Торговая точка',
            value: outletExternalId ?? '—',
          ),
        ],
      ),
    );
  }
}

class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _FullSyncRow extends StatelessWidget {
  const _FullSyncRow({
    required this.isRunning,
    required this.isBusy,
    required this.onRun,
    required this.onCancel,
  });

  final bool isRunning;
  final bool isBusy;
  final VoidCallback onRun;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.all_inclusive, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Полная синхронизация',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              _StatusBadge(status: isRunning ? DataSyncStatus.running : DataSyncStatus.idle),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Запускает последовательное обновление всех сущностей: точки, категории каталога, продукты, остатки и цены.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: isBusy ? null : onRun,
                  child: Text(isRunning ? 'Выполняется…' : 'Запуск'),
                ),
                TextButton(
                  onPressed: isRunning ? onCancel : null,
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.info,
    required this.lastRun,
    required this.isBusy,
    required this.onRun,
    required this.onCancel,
    required this.onReset,
  });

  final DataSyncTask task;
  final DataSyncTaskInfo info;
  final DataSyncLastRunInfo? lastRun;
  final bool isBusy;
  final VoidCallback onRun;
  final VoidCallback onCancel;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final descriptor = _taskDescriptors[task]!;
  final isRunning = info.status == DataSyncStatus.running;
  final canRun = !isBusy && !isRunning;
    final hasHistory = lastRun?.timestamp != null || info.status != DataSyncStatus.idle;
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    final timestamp = lastRun?.timestamp ?? info.finishedAt;

    final String lastSyncText;
    if (timestamp != null) {
      final buffer = StringBuffer(formatter.format(timestamp));
      if (lastRun?.regionCode != null && lastRun!.regionCode!.isNotEmpty) {
        buffer.write('  •  регион ${lastRun!.regionCode}');
      }
      if (lastRun?.tradingPointExternalId != null && lastRun!.tradingPointExternalId!.isNotEmpty) {
        buffer.write('  •  точка ${lastRun!.tradingPointExternalId}');
      }
      lastSyncText = buffer.toString();
    } else {
      lastSyncText = 'Нет зафиксированных запусков';
    }

    final Color borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(descriptor.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            descriptor.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _StatusBadge(status: info.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descriptor.subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Последняя синхронизация: $lastSyncText',
            style: const TextStyle(color: Colors.black54),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _StatusDetails(info: info),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: canRun ? onRun : null,
                  child: const Text('Запуск'),
                ),
                TextButton(
                  onPressed: isRunning
                      ? onCancel
                      : hasHistory
                          ? onReset
                          : null,
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DataSyncStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case DataSyncStatus.running:
        color = Colors.blue;
        label = 'В процессе';
        break;
      case DataSyncStatus.success:
        color = Colors.green;
        label = 'Готово';
        break;
      case DataSyncStatus.failure:
        color = Colors.red;
        label = 'Ошибка';
        break;
      case DataSyncStatus.cancelled:
        color = Colors.orange;
        label = 'Отменено';
        break;
      case DataSyncStatus.idle:
        color = Colors.grey;
        label = 'Ожидает';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: status == DataSyncStatus.running
            ? Row(
                key: const ValueKey('badge-running'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                key: ValueKey(label),
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _StatusDetails extends StatelessWidget {
  const _StatusDetails({required this.info});

  final DataSyncTaskInfo info;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (info.status == DataSyncStatus.failure && info.message != null) {
      child = Padding(
        key: const ValueKey('status-failure'),
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          info.message!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (info.status == DataSyncStatus.cancelled) {
      child = const Padding(
        key: ValueKey('status-cancelled'),
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Операция отменена пользователем',
          style: TextStyle(color: Colors.orange),
        ),
      );
    } else {
      child = const SizedBox.shrink();
    }

    return child;
  }
}

class _TaskDescriptor {
  const _TaskDescriptor({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const Map<DataSyncTask, _TaskDescriptor> _taskDescriptors = <DataSyncTask, _TaskDescriptor>{
  DataSyncTask.tradingPoints: _TaskDescriptor(
    title: 'Торговые точки',
    subtitle: 'Обновление точек и назначений сотруднику.',
    icon: Icons.store,
  ),
  DataSyncTask.categories: _TaskDescriptor(
    title: 'Категории каталога',
    subtitle: 'Структура каталога и фильтров.',
    icon: Icons.category,
  ),
  DataSyncTask.regionProducts: _TaskDescriptor(
    title: 'Продукты региона',
    subtitle: 'Ассортимент и карточки товаров для текущего региона.',
    icon: Icons.inventory_2,
  ),
  DataSyncTask.regionStock: _TaskDescriptor(
    title: 'Остатки и базовые цены',
    subtitle: 'Склады, остатки и цены по складам.',
    icon: Icons.warehouse,
  ),
  DataSyncTask.outletPrices: _TaskDescriptor(
    title: 'Цены торговой точки',
    subtitle: 'Дифференциальные цены выбранной точки.',
    icon: Icons.price_change,
  ),
};