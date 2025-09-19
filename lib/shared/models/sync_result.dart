import 'package:equatable/equatable.dart';

/// Результат синхронизации
class SyncResult extends Equatable {
  /// Количество успешно обработанных элементов
  final int successCount;

  /// Количество элементов с ошибками
  final int errorCount;

  /// Список ошибок (ограниченный для производительности)
  final List<String> errors;

  /// Общее время выполнения
  final Duration duration;

  /// Время начала синхронизации
  final DateTime startTime;

  /// Время окончания синхронизации
  final DateTime? endTime;

  const SyncResult({
    required this.successCount,
    required this.errorCount,
    required this.errors,
    required this.duration,
    required this.startTime,
    this.endTime,
  });

  /// Общее количество обработанных элементов
  int get totalCount => successCount + errorCount;

  /// Процент успешных операций
  double get successRate =>
      totalCount > 0 ? successCount / totalCount : 0.0;

  /// Была ли синхронизация успешной (без ошибок)
  bool get isSuccessful => errorCount == 0 && successCount > 0;

  /// Была ли синхронизация частично успешной
  bool get isPartiallySuccessful => successCount > 0 && errorCount > 0;

  /// Завершилась ли синхронизация с ошибками
  bool get hasErrors => errorCount > 0;

  /// Создает успешный результат
  factory SyncResult.success({
    required int successCount,
    required Duration duration,
    required DateTime startTime,
  }) =>
      SyncResult(
        successCount: successCount,
        errorCount: 0,
        errors: [],
        duration: duration,
        startTime: startTime,
        endTime: startTime.add(duration),
      );

  /// Создает результат с ошибками
  factory SyncResult.withErrors({
    required int successCount,
    required int errorCount,
    required List<String> errors,
    required Duration duration,
    required DateTime startTime,
  }) =>
      SyncResult(
        successCount: successCount,
        errorCount: errorCount,
        errors: errors.take(10).toList(), // Ограничиваем для производительности
        duration: duration,
        startTime: startTime,
        endTime: startTime.add(duration),
      );

  /// Создает результат полной неудачи
  factory SyncResult.failure({
    required List<String> errors,
    required Duration duration,
    required DateTime startTime,
  }) =>
      SyncResult(
        successCount: 0,
        errorCount: 1,
        errors: errors.take(10).toList(),
        duration: duration,
        startTime: startTime,
        endTime: startTime.add(duration),
      );

  @override
  List<Object?> get props => [
        successCount,
        errorCount,
        errors,
        duration,
        startTime,
        endTime,
      ];

  @override
  String toString() =>
      'SyncResult(success: $successCount, errors: $errorCount, duration: ${duration.inSeconds}s, rate: ${(successRate * 100).toStringAsFixed(1)}%)';
}