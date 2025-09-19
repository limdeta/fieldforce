import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../app/presentation/widgets/sync_progress_widget.dart';
import '../../../../features/shop/data/services/product_sync_service_impl.dart';
import '../../../../shared/models/sync_config.dart';
import '../../../../shared/models/sync_progress.dart';
import '../../../../shared/models/sync_result.dart';
import '../../../../app/theme/app_colors.dart';

/// Страница синхронизации продуктов
class ProductSyncPage extends StatefulWidget {
  const ProductSyncPage({super.key});

  @override
  State<ProductSyncPage> createState() => _ProductSyncPageState();
}

class _ProductSyncPageState extends State<ProductSyncPage> {
  final ProductSyncServiceImpl _syncService = GetIt.instance<ProductSyncServiceImpl>();

  SyncProgress? _currentProgress;
  SyncResult? _lastResult;
  bool _isLoading = false;

  // Настройки синхронизации
  String _categories = '29';
  int _limit = 20;
  int _maxConcurrent = 1;

  @override
  void initState() {
    super.initState();
    _setupProgressListener();
  }

  void _setupProgressListener() {
    _syncService.syncProgress.listen((progress) {
      if (mounted) {
        setState(() {
          _currentProgress = progress;
        });
      }
    });

    _syncService.syncResults.listen((result) {
      if (mounted) {
        setState(() {
          _lastResult = result;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _startSync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final config = SyncConfig.api(
        categories: _categories,
        limit: _limit,
        maxConcurrent: _maxConcurrent,
      );

      final result = await _syncService.sync(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Синхронизация завершена: ${result.successCount} продуктов'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка синхронизации: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelSync() async {
    await _syncService.cancel();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Синхронизация отменена'),
        ),
      );
    }
  }

  Future<void> _pauseSync() async {
    await _syncService.pause();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Синхронизация приостановлена'),
        ),
      );
    }
  }

  Future<void> _resumeSync() async {
    await _syncService.resume();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Синхронизация возобновлена'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Синхронизация продуктов'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading) ...[
            IconButton(
              onPressed: _pauseSync,
              icon: const Icon(Icons.pause),
              tooltip: 'Приостановить',
            ),
            IconButton(
              onPressed: _cancelSync,
              icon: const Icon(Icons.cancel),
              tooltip: 'Отменить',
            ),
          ] else if (_syncService.isPaused) ...[
            IconButton(
              onPressed: _resumeSync,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Возобновить',
            ),
            IconButton(
              onPressed: _cancelSync,
              icon: const Icon(Icons.cancel),
              tooltip: 'Отменить',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            const Text(
              'Синхронизация продуктов',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Загрузка актуального каталога продуктов из внешнего источника',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Настройки синхронизации
            _buildSettingsSection(),

            const SizedBox(height: 32),

            // Прогресс синхронизации
            if (_currentProgress != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Прогресс синхронизации',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SyncProgressWidget(
                        progress: _currentProgress!,
                        isActive: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Результаты последней синхронизации
            if (_lastResult != null) _buildResultsSection(),

            const SizedBox(height: 32),

            // Кнопка запуска
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _startSync,
                icon: const Icon(Icons.sync),
                label: Text(_isLoading ? 'Синхронизация...' : 'Начать синхронизацию'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки синхронизации',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Категории
            TextFormField(
              initialValue: _categories,
              decoration: const InputDecoration(
                labelText: 'Категории',
                hintText: 'Например: 29',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _categories = value,
            ),
            const SizedBox(height: 16),

            // Размер страницы
            TextFormField(
              initialValue: _limit.toString(),
              decoration: const InputDecoration(
                labelText: 'Размер страницы',
                hintText: 'Например: 20',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _limit = int.tryParse(value) ?? 20,
            ),
            const SizedBox(height: 16),

            // Максимум одновременных запросов
            TextFormField(
              initialValue: _maxConcurrent.toString(),
              decoration: const InputDecoration(
                labelText: 'Максимум одновременных запросов',
                hintText: 'Например: 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _maxConcurrent = int.tryParse(value) ?? 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Результаты последней синхронизации',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Статистика
            Row(
              children: [
                Expanded(
                  child: _buildResultItem(
                    'Успешно',
                    _lastResult!.successCount.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildResultItem(
                    'Ошибок',
                    _lastResult!.errorCount.toString(),
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildResultItem(
                    'Всего',
                    _lastResult!.totalCount.toString(),
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Время выполнения
            Row(
              children: [
                const Icon(Icons.timer, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Время выполнения: ${_formatDuration(_lastResult!.duration)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Ошибки (если есть)
            if (_lastResult!.hasErrors) ...[
              const SizedBox(height: 16),
              const Text(
                'Ошибки:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ..._lastResult!.errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $error',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '$seconds сек';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes мин $remainingSeconds сек';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours ч $minutes мин';
    }
  }
}