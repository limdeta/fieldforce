import 'package:equatable/equatable.dart';

/// Модель прогресса синхронизации
class SyncProgress extends Equatable {
  /// Тип синхронизации
  final String type;

  /// Текущий прогресс (обработано элементов)
  final int current;

  /// Общее количество элементов для обработки
  final int total;

  /// Текущий статус операции
  final String status;

  /// Процент завершения (0.0 - 1.0)
  final double percentage;

  /// Оставшееся время в секундах (примерное)
  final int? estimatedTimeRemaining;

  const SyncProgress({
    required this.type,
    required this.current,
    required this.total,
    required this.status,
    required this.percentage,
    this.estimatedTimeRemaining,
  });

  /// Создает начальный прогресс
  factory SyncProgress.initial(String type) => SyncProgress(
        type: type,
        current: 0,
        total: 0,
        status: 'Подготовка...',
        percentage: 0.0,
      );

  /// Создает прогресс с неизвестным общим количеством
  factory SyncProgress.indeterminate({
    required String type,
    required int current,
    required String status,
  }) =>
      SyncProgress(
        type: type,
        current: current,
        total: 0,
        status: status,
        percentage: 0.0,
      );

  /// Создает завершенный прогресс
  factory SyncProgress.completed(String type, int total) => SyncProgress(
        type: type,
        current: total,
        total: total,
        status: 'Завершено',
        percentage: 1.0,
      );

  /// Создает прогресс с ошибкой
  factory SyncProgress.error(String type, String errorMessage) => SyncProgress(
        type: type,
        current: 0,
        total: 0,
        status: 'Ошибка',
        percentage: 0.0,
      );

  @override
  List<Object?> get props => [
        current,
        total,
        status,
        percentage,
        estimatedTimeRemaining,
      ];

  @override
  String toString() =>
      'SyncProgress(current: $current, total: $total, status: $status, percentage: ${(percentage * 100).toStringAsFixed(1)}%)';
}