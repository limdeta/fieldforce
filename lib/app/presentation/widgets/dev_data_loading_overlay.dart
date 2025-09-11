import 'package:flutter/material.dart';
import 'package:fieldforce/app/providers/dev_data_loading_notifier.dart';

/// Виджет-индикатор загрузки dev данных
/// Показывается поверх приложения во время инициализации тестовых данных в dev режиме
class DevDataLoadingOverlay extends StatelessWidget {
  final Widget child;

  const DevDataLoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DevDataLoadingState>(
      valueListenable: devDataLoadingNotifier,
      builder: (context, state, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              child,
              if (state == DevDataLoadingState.loading)
                _buildLoadingOverlay(context),
              if (state == DevDataLoadingState.error)
                _buildErrorOverlay(context),
            ],
          ),
        );
      },
    );
  }

  /// Строит оверлей с индикатором загрузки
  Widget _buildLoadingOverlay(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '🔧 Инициализация dev данных...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Создание пользователей, маршрутов и торговых точек',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Строит оверлей с сообщением об ошибке
  Widget _buildErrorOverlay(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '❌ Ошибка инициализации dev данных',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    devDataLoadingNotifier.errorMessage ?? 'Неизвестная ошибка',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      devDataLoadingNotifier.reset();
                    },
                    child: const Text('Продолжить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
