// lib/features/shop/presentation/bloc/protobuf_sync_state.dart

part of 'protobuf_sync_bloc.dart';

@immutable
abstract class ProtobufSyncState extends Equatable {
  const ProtobufSyncState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние - синхронизация не запущена
class ProtobufSyncInitial extends ProtobufSyncState {
  const ProtobufSyncInitial();
}

/// Синхронизация в процессе
class ProtobufSyncInProgress extends ProtobufSyncState {
  final ProtobufSyncProgress progress;

  const ProtobufSyncInProgress(this.progress);

  @override
  List<Object?> get props => [progress];

  /// Процент завершения (0.0 - 1.0)
  double get progressPercentage => progress.overallProgress;

  /// Текущий этап синхронизации
  ProtobufSyncStage get currentStage => progress.currentStage;

  /// Сообщение о текущем этапе
  String get stageMessage => progress.currentStage.displayName;

  /// Оценка времени до завершения
  Duration? get estimatedTimeRemaining => progress.estimatedTimeRemaining;
}

/// Синхронизация завершена успешно
class ProtobufSyncSuccess extends ProtobufSyncState {
  final ProtobufSyncResult result;

  const ProtobufSyncSuccess(this.result);

  @override
  List<Object?> get props => [result];

  /// Количество синхронизированных продуктов
  int get syncedProductsCount => result.productsCount;

  /// Количество синхронизированных позиций склада
  int get syncedStockItemsCount => result.stockItemsCount;

  /// Время выполнения синхронизации
  Duration get duration => result.duration;
}

/// Синхронизация завершена с ошибкой
class ProtobufSyncFailure extends ProtobufSyncState {
  final ProtobufSyncResult result;

  const ProtobufSyncFailure(this.result);

  @override
  List<Object?> get props => [result];

  /// Сообщение об ошибке
  String get errorMessage => result.errors.isNotEmpty 
      ? result.errors.first 
      : 'Неизвестная ошибка';

  /// Лог поддержки для копирования
  String get supportLog => result.supportLog;

  /// Детали ошибки
  String? get errorDetails => result.detailedErrors.isNotEmpty 
      ? result.detailedErrors.map((e) => e.toString()).join('\n')
      : null;
}

/// Синхронизация была отменена пользователем
class ProtobufSyncCancelled extends ProtobufSyncState {
  const ProtobufSyncCancelled();
}