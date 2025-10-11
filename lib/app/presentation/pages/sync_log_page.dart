import 'package:fieldforce/app/database/repositories/sync_log_repository.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class SyncLogPage extends StatefulWidget {
  const SyncLogPage({super.key});

  @override
  State<SyncLogPage> createState() => _SyncLogPageState();
}

class _SyncLogPageState extends State<SyncLogPage> {
  static const int _pageSize = 500;

  late final SyncLogRepository _repository = GetIt.instance<SyncLogRepository>();
  late Future<List<String>> _tasksFuture = _repository.getAvailableTasks();
  int _currentLimit = _pageSize;
  String? _selectedTask;

  void _handleLoadMore() {
    setState(() {
      _currentLimit += _pageSize;
    });
  }

  void _handleTaskChanged(String? newTask) {
    setState(() {
      _selectedTask = (newTask == null || newTask.isEmpty) ? null : newTask;
      _currentLimit = _pageSize;
    });
  }

  void _refreshTaskList() {
    setState(() {
      _tasksFuture = _repository.getAvailableTasks();
    });
  }

  Future<void> _clearLogs(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить журнал?'),
        content: const Text('Все записи журнала синхронизации будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.clear();
      _refreshTaskList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал синхронизации'),
        actions: [
          IconButton(
            tooltip: 'Очистить журнал',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearLogs(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterPanel(
            tasksFuture: _tasksFuture,
            selectedTask: _selectedTask,
            onTaskChanged: _handleTaskChanged,
            onRefresh: _refreshTaskList,
          ),
          Expanded(
            child: StreamBuilder<List<SyncLogEntry>>(
              key: ValueKey('log-stream-${_selectedTask ?? 'all'}-$_currentLimit'),
              stream: _repository.watchRecentLogs(
                limit: _currentLimit,
                task: _selectedTask,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Не удалось загрузить журнал синхронизации: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final logs = snapshot.data;
                if (logs != null) {
                  if (logs.isEmpty) {
                    return const _EmptyState();
                  }
                  final bool hasMore = logs.length >= _currentLimit;
                  return _LogListView(
                    logs: logs,
                    hasMore: hasMore,
                    onLoadMore: hasMore ? _handleLoadMore : null,
                  );
                }

                return _InitialLogLoader(
                  repository: _repository,
                  limit: _currentLimit,
                  task: _selectedTask,
                  onLoadMore: _handleLoadMore,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.tasksFuture,
    required this.selectedTask,
    required this.onTaskChanged,
    required this.onRefresh,
  });

  final Future<List<String>> tasksFuture;
  final String? selectedTask;
  final ValueChanged<String?> onTaskChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: tasksFuture,
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? <String>[];
                final items = <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Все задачи'),
                  ),
                  ...tasks.map(
                    (task) => DropdownMenuItem<String?>(
                      value: task,
                      child: Text(task),
                    ),
                  ),
                ];

                return InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Фильтр по задаче',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: selectedTask,
                      items: items,
                      onChanged: snapshot.connectionState == ConnectionState.waiting
                          ? null
                          : onTaskChanged,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Обновить список задач',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _InitialLogLoader extends StatelessWidget {
  const _InitialLogLoader({
    required this.repository,
    required this.limit,
    required this.task,
    required this.onLoadMore,
  });

  final SyncLogRepository repository;
  final int limit;
  final String? task;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SyncLogEntry>>(
      future: repository.getRecentLogs(limit: limit, task: task),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Не удалось загрузить журнал синхронизации: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final logs = snapshot.data ?? <SyncLogEntry>[];
        if (logs.isEmpty) {
          return const _EmptyState();
        }

        final bool hasMore = logs.length >= limit;
        return _LogListView(
          logs: logs,
          hasMore: hasMore,
          onLoadMore: hasMore ? onLoadMore : null,
        );
      },
    );
  }
}

class _LogListView extends StatelessWidget {
  const _LogListView({
    required this.logs,
    required this.hasMore,
    this.onLoadMore,
  });

  final List<SyncLogEntry> logs;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final bool showLoadMore = hasMore && onLoadMore != null;
    final int totalItems = logs.length + (showLoadMore ? 1 : 0);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: totalItems,
      separatorBuilder: (context, _) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        if (showLoadMore && index == logs.length) {
          return _LoadMoreTile(onLoadMore: onLoadMore!);
        }

        final entry = logs[index];
        final int reverseIndex = logs.length - index;
        return _LogTile(entry: entry, sequence: reverseIndex);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Пока нет записей о синхронизации',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade600),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry, required this.sequence});

  final SyncLogEntry entry;
  final int sequence;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final _LogVisuals visuals = _LogVisuals.fromEntry(entry);
  final Color background = Theme.of(context)
    .colorScheme
    .surfaceContainerHighest
    .withValues(alpha: 0.25);
    final TextStyle baseStyle = TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 12,
      height: 1.3,
      color: Colors.blueGrey.shade900,
    );
    final TextStyle dimStyle = baseStyle.copyWith(color: Colors.blueGrey.shade600);

    final List<String> meta = <String>[];
    if (entry.regionCode != null && entry.regionCode!.isNotEmpty) {
      meta.add('region=${entry.regionCode}');
    }
    if (entry.tradingPointExternalId != null && entry.tradingPointExternalId!.isNotEmpty) {
      meta.add('tp=${entry.tradingPointExternalId}');
    }
    if (entry.durationMs != null) {
      final duration = Duration(milliseconds: entry.durationMs!);
      final seconds = duration.inSeconds;
      final millis = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
      meta.add('duration=${seconds}s${millis}ms');
    }

    final List<Widget> detailWidgets = <Widget>[];
    entry.details?.forEach((key, value) {
      if (value is Map) {
        detailWidgets.add(Text('   $key:', style: dimStyle));
        value.forEach((subKey, subValue) {
          detailWidgets.add(Text('      $subKey=$subValue', style: dimStyle));
        });
      } else if (value is Iterable) {
        detailWidgets.add(Text('   $key:', style: dimStyle));
        for (final item in value) {
          detailWidgets.add(Text('      • $item', style: dimStyle));
        }
      } else {
        detailWidgets.add(Text('   $key=$value', style: dimStyle));
      }
    });

    final String sequenceLabel = '#${sequence.toString().padLeft(4, '0')}';
    final String clipboardText = _buildClipboardPayload(
      formatter: formatter,
      visuals: visuals,
      meta: meta,
      details: entry.details,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: clipboardText));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Запись скопирована в буфер обмена'),
                duration: Duration(milliseconds: 900),
              ),
            );
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: Border(left: BorderSide(color: visuals.levelColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: baseStyle,
                    children: [
                      TextSpan(
                        text: sequenceLabel,
                        style: baseStyle.copyWith(color: Colors.blueGrey.shade500),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(text: formatter.format(entry.createdAt), style: dimStyle),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: visuals.levelLabel,
                        style: baseStyle.copyWith(color: visuals.levelColor, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(text: entry.task, style: dimStyle),
                      const TextSpan(text: '  '),
                      TextSpan(text: entry.message),
                    ],
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('   ${meta.join('  ')}', style: dimStyle),
                ],
                if (detailWidgets.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...detailWidgets,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildClipboardPayload({
    required DateFormat formatter,
    required _LogVisuals visuals,
    required List<String> meta,
    required Map<String, dynamic>? details,
  }) {
    final StringBuffer buffer = StringBuffer()
      ..write(sequence.toString().padLeft(4, '0'))
      ..write(' ')
      ..write(formatter.format(entry.createdAt))
      ..write(' ')
      ..write(visuals.levelLabel)
      ..write(' ')
      ..write(entry.task)
      ..write(' ')
      ..write(entry.message);

    if (meta.isNotEmpty) {
      buffer
        ..write('\n')
        ..write(meta.join('  '));
    }

    details?.forEach((key, value) {
      if (value is Map) {
        buffer
          ..write('\n')
          ..write('$key:');
        value.forEach((subKey, subValue) {
          buffer
            ..write('\n')
            ..write('  $subKey=$subValue');
        });
      } else if (value is Iterable) {
        buffer
          ..write('\n')
          ..write('$key:');
        for (final item in value) {
          buffer
            ..write('\n')
            ..write('  - $item');
        }
      } else {
        buffer
          ..write('\n')
          ..write('$key=$value');
      }
    });

    return buffer.toString();
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({required this.onLoadMore});

  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: onLoadMore,
          icon: const Icon(Icons.expand_more),
          label: const Text('Показать ещё'),
        ),
      ),
    );
  }
}

class _LogVisuals {
  const _LogVisuals({required this.levelLabel, required this.levelColor});

  final String levelLabel;
  final Color levelColor;

  static _LogVisuals fromEntry(SyncLogEntry entry) {
    final String event = entry.eventType.toLowerCase();
    switch (event) {
      case 'failure':
      case 'error':
        return _LogVisuals(levelLabel: 'ERROR', levelColor: Colors.red.shade600);
      case 'cancelled':
      case 'cancel-requested':
        return _LogVisuals(levelLabel: 'WARN', levelColor: Colors.orange.shade600);
      case 'success':
        return _LogVisuals(levelLabel: 'SUCCESS', levelColor: Colors.green.shade600);
      case 'start':
      case 'progress':
        return _LogVisuals(levelLabel: 'INFO', levelColor: Colors.blue.shade600);
      default:
        return _LogVisuals(levelLabel: event.toUpperCase(), levelColor: Colors.blueGrey.shade600);
    }
  }
}
