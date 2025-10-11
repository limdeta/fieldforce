// lib/features/shop/presentation/pages/protobuf_sync_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/protobuf_sync_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/sync/services/protobuf_sync_coordinator.dart';

/// Страница для синхронизации данных через протобуф
class ProtobufSyncPage extends StatelessWidget {
  const ProtobufSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<ProtobufSyncBloc>(),
      child: const _ProtobufSyncView(),
    );
  }
}

class _ProtobufSyncView extends StatelessWidget {
  const _ProtobufSyncView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Протобуф синхронизация'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProtobufSyncBloc, ProtobufSyncState>(
        listener: (context, state) {
          if (state is ProtobufSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Синхронизация завершена: продукты ${state.syncedProductsCount}, склады ${state.syncedWarehousesCount}, позиции ${state.syncedStockItemsCount}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is WarehouseSyncOnlySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Склады синхронизированы: ${state.syncedWarehouses} (регион ${state.regionCode})',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is ProtobufSyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка синхронизации: ${state.errorMessage}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: 'Детали',
                  textColor: Colors.white,
                  onPressed: () => _showErrorDetails(context, state),
                ),
              ),
            );
          } else if (state is WarehouseSyncOnlyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка синхронизации складов: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 6),
              ),
            );
          } else if (state is ProtobufSyncCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Синхронизация отменена'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 20),
                _buildSyncContent(context, state),
                const SizedBox(height: 20),
                _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Протобуф синхронизация',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Синхронизация данных о продуктах и складских позициях через Protocol Buffers. '
              'Этот метод обеспечивает быструю и эффективную передачу больших объемов данных.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Продукты с категориями и характеристиками\n'
              '• Складские остатки и цены\n'
              '• Автоматическое управление конфликтами',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncContent(BuildContext context, ProtobufSyncState state) {
    if (state is ProtobufSyncInitial) {
      return _buildInitialContent();
    } else if (state is ProtobufSyncInProgress) {
      return _buildProgressContent(state);
    } else if (state is ProtobufSyncSuccess) {
      return _buildSuccessContent(state);
    } else if (state is ProtobufSyncFailure) {
      return _buildFailureContent(context, state);
    } else if (state is ProtobufSyncCancelled) {
      return _buildCancelledContent();
    } else if (state is WarehouseSyncOnlyInProgress) {
      return _buildWarehouseOnlyProgress();
    } else if (state is WarehouseSyncOnlySuccess) {
      return _buildWarehouseOnlySuccess(state);
    } else if (state is WarehouseSyncOnlyFailure) {
      return _buildWarehouseOnlyFailure(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildInitialContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.cloud_download,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Готово к синхронизации',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите кнопку ниже, чтобы начать синхронизацию данных',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressContent(ProtobufSyncInProgress state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  state.currentStage.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.stageMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Обработано: ${state.progress.processedItems} из ${state.progress.totalItems}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: state.progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(state.progressPercentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (state.estimatedTimeRemaining != null)
                  Text(
                    'Осталось: ${_formatDuration(state.estimatedTimeRemaining!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(ProtobufSyncSuccess state) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Синхронизация завершена успешно!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildResultStats(
              'Продукты',
              state.syncedProductsCount,
              Icons.inventory,
            ),
            const SizedBox(height: 8),
            _buildResultStats(
              'Склады',
              state.syncedWarehousesCount,
              Icons.apartment,
            ),
            const SizedBox(height: 8),
            _buildResultStats(
              'Складские позиции',
              state.syncedStockItemsCount,
              Icons.warehouse,
            ),
            const SizedBox(height: 8),
            _buildResultStats(
              'Время выполнения',
              _formatDuration(state.duration),
              Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureContent(BuildContext context, ProtobufSyncFailure state) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.error,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ошибка синхронизации',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showErrorDetails(context, state),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Детали'),
                ),
                TextButton.icon(
                  onPressed: () => _copySupportLog(context, state),
                  icon: const Icon(Icons.copy),
                  label: const Text('Скопировать лог'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledContent() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.cancel,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Синхронизация отменена',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Операция была остановлена пользователем',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStats(String label, dynamic value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseOnlyProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Синхронизация складов...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Запрашиваем данные со склада и сохраняем их локально',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseOnlySuccess(WarehouseSyncOnlySuccess state) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.apartment, size: 32, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Склады синхронизированы',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResultStats('Регион', state.regionCode, Icons.map),
            const SizedBox(height: 8),
            _buildResultStats('Всего складов', state.syncedWarehouses, Icons.warehouse),
            if (state.syncTimestamp > 0) ...[
              const SizedBox(height: 8),
              _buildResultStats('Метка синхронизации', state.syncTimestamp, Icons.schedule),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseOnlyFailure(WarehouseSyncOnlyFailure state) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Не удалось синхронизировать склады',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProtobufSyncState state) {
    if (state is ProtobufSyncInProgress) {
      return ElevatedButton(
        onPressed: () {
          context.read<ProtobufSyncBloc>().add(const CancelProtobufSyncEvent());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Отменить синхронизацию'),
      );
    } else if (state is WarehouseSyncOnlyInProgress) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Синхронизация складов...'),
      );
    } else if (state is ProtobufSyncSuccess || 
               state is ProtobufSyncFailure || 
               state is ProtobufSyncCancelled) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ProtobufSyncBloc>().add(const ResetProtobufSyncEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Запустить заново'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Назад'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showSyncStats(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Проверить данные в БД'),
          ),
          const SizedBox(height: 12),
          _buildWarehouseOnlyButton(context),
        ],
      );
    } else if (state is WarehouseSyncOnlySuccess || state is WarehouseSyncOnlyFailure) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<ProtobufSyncBloc>().add(const ResetProtobufSyncEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Сбросить состояние'),
          ),
          const SizedBox(height: 12),
          _buildWarehouseOnlyButton(context),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<ProtobufSyncBloc>().add(const StartProtobufSyncEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Запустить полную синхронизацию'),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<ProtobufSyncBloc>().add(const StartProtobufSyncEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Начать синхронизацию'),
          ),
          const SizedBox(height: 12),
          _buildWarehouseOnlyButton(context),
        ],
      );
    }
  }

  Widget _buildWarehouseOnlyButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context.read<ProtobufSyncBloc>().add(const SyncWarehousesOnlyEvent());
      },
      icon: const Icon(Icons.apartment),
      label: const Text('Синхронизировать только склады'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  void _showErrorDetails(BuildContext context, ProtobufSyncFailure state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Детали ошибки'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ошибка:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(state.errorMessage),
              if (state.errorDetails != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Детали:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  state.errorDetails!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copySupportLog(context, state);
            },
            child: const Text('Скопировать лог'),
          ),
        ],
      ),
    );
  }

  void _copySupportLog(BuildContext context, ProtobufSyncFailure state) {
    Clipboard.setData(ClipboardData(text: state.supportLog));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Лог поддержки скопирован в буфер обмена'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hoursч $minutesм $secondsс';
    } else if (minutes > 0) {
      return '$minutesм $secondsс';
    } else {
      return '$secondsс';
    }
  }

  void _showSyncStats(BuildContext context) async {
    // Показать индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Проверка данных...'),
          ],
        ),
      ),
    );

    try {
      final coordinator = GetIt.instance<ProtobufSyncCoordinator>();
      final stats = await coordinator.getSyncStats();
      
      Navigator.of(context).pop(); // Закрыть индикатор загрузки
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Статистика данных'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatItem('Продукты в БД', stats['products']),
                _buildStatItem('Остатки в БД', stats['stock_items']),
                _buildStatItem('Остатки с товаром', stats['stock_items_with_stock']),
                _buildStatItem('Склады в БД', stats['warehouses']),
                if (stats['sample_stock_item'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Пример остатка:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...((stats['sample_stock_item'] as Map<String, dynamic>).entries.map(
                    (entry) => _buildStatItem(entry.key, entry.value),
                  )),
                ],
                if (stats['error'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка: ${stats['error']}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Закрыть индикатор загрузки
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка получения статистики: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }
}