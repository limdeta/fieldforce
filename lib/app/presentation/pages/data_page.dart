import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import '../../../shared/models/sync_config.dart';
import '../../../shared/models/sync_progress.dart';
import '../../../shared/models/sync_result.dart';
import '../../../features/shop/data/services/product_sync_service_impl.dart';
import '../../theme/app_colors.dart';
import '../widgets/sync_progress_widget.dart';

/// Страница раздела "Данные" - управление синхронизацией и данными
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final ProductSyncServiceImpl _syncService = GetIt.instance<ProductSyncServiceImpl>();
  static final Logger _logger = Logger('DataPage');

  SyncProgress? _currentProgress;
  SyncResult? _lastResult;
  bool _isLoading = false;

  // Состояние для синхронизации категорий
  SyncProgress? _categoryProgress;
  SyncResult? _categoryResult;
  bool _isCategoryLoading = false;

  // Настройки синхронизации
  String _categories = '29, 156'; // Дефолтные категории
  final TextEditingController _categoriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesController.text = _categories;
    _setupProgressListener();
  }

  @override
  void dispose() {
    _categoriesController.dispose();
    super.dispose();
  }

  void _setupProgressListener() {
    _syncService.syncProgress.listen((progress) {
      if (mounted) {
        setState(() {
          if (progress.type == 'products') {
            _currentProgress = progress;
          } else if (progress.type == 'categories') {
            _categoryProgress = progress;
          }
        });
      }
    });

    _syncService.syncResults.listen((result) {
      if (mounted) {
        setState(() {
          if (result.type == 'products') {
            _lastResult = result;
            _isLoading = false;
          } else if (result.type == 'categories') {
            _categoryResult = result;
            _isCategoryLoading = false;
          }
        });
      }
    });
  }

  Future<void> _startProductSync() async {
    setState(() {
      _isLoading = true;
      _currentProgress = null;
      _lastResult = null;
    });

    try {
      // Парсим категории - если пустое поле, не передаем параметр categories
      final trimmedCategories = _categoriesController.text.trim();
      final categoriesParam = trimmedCategories.isEmpty ? null : trimmedCategories;
      
      final config = SyncConfig.api(
        categories: categoriesParam,
        limit: 100, // Фиксированный размер страницы для внутренней пагинации  
        offset: 0,
        maxConcurrent: 1,
      );

      _logger.info('Запуск синхронизации продуктов с конфигом: $config');
      final result = await _syncService.syncProducts(config);
      _logger.info('Синхронизация завершена: $result');

      if (mounted) {
        setState(() {
          _lastResult = result;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Синхронизация завершена: ${result.successCount} продуктов'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      _logger.severe('Ошибка синхронизации продуктов', e, st);
      
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

  Future<void> _startCategorySync() async {
    setState(() {
      _isCategoryLoading = true;
      _categoryProgress = null;
      _categoryResult = null;
    });

    try {
      // Парсим категории - если пустое поле, не передаем параметр categories
      final trimmedCategories = _categoriesController.text.trim();
      final categoriesParam = trimmedCategories.isEmpty ? null : trimmedCategories;
      
      final config = SyncConfig.api(
        categories: categoriesParam,
        limit: 20,
        offset: 0,
        maxConcurrent: 1,
      );

      _logger.info('Запуск синхронизации категорий с конфигом: $config');
      final result = await _syncService.syncCategories(config);
      _logger.info('Синхронизация категорий завершена: $result');

      if (mounted) {
        setState(() {
          _categoryResult = result;
          _isCategoryLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Синхронизация завершена: ${result.successCount} категорий'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      _logger.severe('Ошибка синхронизации категорий', e, st);
      
      if (mounted) {
        setState(() {
          _isCategoryLoading = false;
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

  Future<void> _startFullSync() async {
    // Сначала синхронизируем категории
    await _startCategorySync();
    
    // Затем синхронизируем продукты
    await _startProductSync();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Полная синхронизация завершена'),
          backgroundColor: Colors.green,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Данные'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок раздела
              const Text(
                'Управление данными',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Синхронизация продуктов и управление локальными данными',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Раздел синхронизации продуктов
              _buildProductSyncSection(),

              const SizedBox(height: 32),

              // Раздел синхронизации категорий
              _buildCategorySyncSection(),

              const SizedBox(height: 32),

              // Раздел статистики
              if (_lastResult != null) _buildStatisticsSection(),

              const SizedBox(height: 16),

              // Раздел ошибок
              if (_lastResult != null && _lastResult!.hasErrors) _buildErrorsSection(),

              const SizedBox(height: 32),

              // Кнопки действий
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildProductSyncSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Продукты',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _startProductSync,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Синхронизировать',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Настройки категорий для продуктов
            TextFormField(
              controller: _categoriesController,
              decoration: const InputDecoration(
                labelText: 'Категории продуктов',
                hintText: 'Например: 29, 156 (через запятую)',
                helperText: 'Оставьте пустым для загрузки всех категорий',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 12),

            // Прогресс синхронизации
            if (_currentProgress != null)
              SyncProgressWidget(
                progress: _currentProgress!,
                isActive: _isLoading,
              ),

            const SizedBox(height: 16),

            // Статус
            Text(
              _getSyncStatusText(),
              style: TextStyle(
                color: _getSyncStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySyncSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isCategoryLoading ? null : _startCategorySync,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Синхронизировать',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Прогресс синхронизации
            if (_categoryProgress != null)
              SyncProgressWidget(
                progress: _categoryProgress!,
                isActive: _isCategoryLoading,
              ),

            const SizedBox(height: 16),

            // Статус
            Text(
              _getCategorySyncStatusText(),
              style: TextStyle(
                color: _getCategorySyncStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Статистика последней синхронизации',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Успешно',
                  _lastResult!.successCount.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  'Ошибок',
                  _lastResult!.errorCount.toString(),
                  Colors.red,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  'Время',
                  '${_lastResult!.duration.inSeconds}с',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorsSection() {
    final errorText = _lastResult!.errors.join('\n');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Ошибки синхронизации',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyErrorToClipboard(errorText),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Копировать ошибки',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текст ошибок (можно выделить и скопировать):',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    errorText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_isLoading || _isCategoryLoading) ? null : _startFullSync,
            icon: const Icon(Icons.sync),
            label: const Text('Синхронизировать всё'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (_isLoading || _isCategoryLoading) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cancelSync,
              icon: const Icon(Icons.cancel),
              label: const Text('Отменить синхронизацию'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getSyncStatusText() {
    if (_isLoading) {
      return _currentProgress?.status ?? 'Синхронизация продуктов...';
    }

    if (_lastResult != null) {
      if (_lastResult!.isSuccessful) {
        return 'Продукты синхронизированы успешно';
      } else if (_lastResult!.hasErrors) {
        return 'Синхронизация продуктов завершена с ошибками';
      }
    }

    return 'Продукты готовы к синхронизации';
  }

  Color _getSyncStatusColor() {
    if (_isLoading) {
      return Colors.blue;
    }

    if (_lastResult != null) {
      if (_lastResult!.isSuccessful) {
        return Colors.green;
      } else if (_lastResult!.hasErrors) {
        return Colors.orange;
      }
    }

    return Colors.grey;
  }

  String _getCategorySyncStatusText() {
    if (_isCategoryLoading) {
      return _categoryProgress?.status ?? 'Синхронизация категорий...';
    }

    if (_categoryResult != null) {
      if (_categoryResult!.isSuccessful) {
        return 'Категории синхронизированы успешно';
      } else if (_categoryResult!.hasErrors) {
        return 'Синхронизация категорий завершена с ошибками';
      }
    }

    return 'Категории готовы к синхронизации';
  }

  Color _getCategorySyncStatusColor() {
    if (_isCategoryLoading) {
      return Colors.blue;
    }

    if (_categoryResult != null) {
      if (_categoryResult!.isSuccessful) {
        return Colors.green;
      } else if (_categoryResult!.hasErrors) {
        return Colors.orange;
      }
    }

    return Colors.grey;
  }

  Future<void> _copyErrorToClipboard(String errorText) async {
    await Clipboard.setData(ClipboardData(text: errorText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибки скопированы в буфер обмена'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}