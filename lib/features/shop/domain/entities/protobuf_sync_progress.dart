// lib/features/shop/domain/entities/protobuf_sync_progress.dart

/// Прогресс выполнения protobuf синхронизации
class ProtobufSyncProgress {
  /// Текущий этап синхронизации
  final ProtobufSyncStage currentStage;
  
  /// Общий прогресс (0.0 - 1.0)
  final double overallProgress;
  
  /// Прогресс текущего этапа (0.0 - 1.0)
  final double stageProgress;
  
  /// Количество обработанных элементов в текущем этапе
  final int processedItems;
  
  /// Общее количество элементов в текущем этапе
  final int totalItems;
  
  /// Сообщение о текущем состоянии
  final String message;
  
  /// Время начала синхронизации
  final DateTime startTime;
  
  /// Время последнего обновления
  final DateTime lastUpdateTime;

  const ProtobufSyncProgress({
    required this.currentStage,
    required this.overallProgress,
    required this.stageProgress,
    required this.processedItems,
    required this.totalItems,
    required this.message,
    required this.startTime,
    required this.lastUpdateTime,
  });

  /// Создает начальное состояние прогресса
  factory ProtobufSyncProgress.initial() {
    final now = DateTime.now();
    return ProtobufSyncProgress(
      currentStage: ProtobufSyncStage.preparation,
      overallProgress: 0.0,
      stageProgress: 0.0,
      processedItems: 0,
      totalItems: 0,
      message: 'Подготовка к синхронизации...',
      startTime: now,
      lastUpdateTime: now,
    );
  }

  /// Создает копию с обновленными значениями
  ProtobufSyncProgress copyWith({
    ProtobufSyncStage? currentStage,
    double? overallProgress,
    double? stageProgress,
    int? processedItems,
    int? totalItems,
    String? message,
    DateTime? startTime,
    DateTime? lastUpdateTime,
  }) {
    return ProtobufSyncProgress(
      currentStage: currentStage ?? this.currentStage,
      overallProgress: overallProgress ?? this.overallProgress,
      stageProgress: stageProgress ?? this.stageProgress,
      processedItems: processedItems ?? this.processedItems,
      totalItems: totalItems ?? this.totalItems,
      message: message ?? this.message,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? DateTime.now(),
    );
  }

  /// Вычисляет скорость обработки (элементов в секунду)
  double get processingSpeed {
    final elapsed = lastUpdateTime.difference(startTime).inSeconds;
    if (elapsed <= 0) return 0.0;
    return processedItems / elapsed;
  }

  /// Оценивает оставшееся время
  Duration? get estimatedTimeRemaining {
    final speed = processingSpeed;
    if (speed <= 0) return null;
    
    final remainingItems = totalItems - processedItems;
    if (remainingItems <= 0) return Duration.zero;
    
    final secondsRemaining = (remainingItems / speed).round();
    return Duration(seconds: secondsRemaining);
  }

  @override
  String toString() {
    return 'ProtobufSyncProgress('
        'stage: ${currentStage.displayName}, '
        'overall: ${(overallProgress * 100).toStringAsFixed(1)}%, '
        'stage: ${(stageProgress * 100).toStringAsFixed(1)}%, '
        'items: $processedItems/$totalItems, '
        'message: $message'
        ')';
  }
}

/// Этапы protobuf синхронизации
enum ProtobufSyncStage {
  preparation('Подготовка'),
  regionalData('Региональные данные'),
  stockData('Остатки на складах'),
  outletPricing('Цены торговых точек'),
  finalizing('Завершение'),
  completed('Завершено');

  const ProtobufSyncStage(this.displayName);
  
  final String displayName;

  /// Возвращает эмодзи для этапа
  String get emoji {
    switch (this) {
      case ProtobufSyncStage.preparation:
        return '🔧';
      case ProtobufSyncStage.regionalData:
        return '📦';
      case ProtobufSyncStage.stockData:
        return '📊';
      case ProtobufSyncStage.outletPricing:
        return '💰';
      case ProtobufSyncStage.finalizing:
        return '✅';
      case ProtobufSyncStage.completed:
        return '🎉';
    }
  }

  /// Возвращает вес этапа для расчета общего прогресса
  double get weight {
    switch (this) {
      case ProtobufSyncStage.preparation:
        return 0.05; // 5%
      case ProtobufSyncStage.regionalData:
        return 0.5;  // 50% (основной этап)
      case ProtobufSyncStage.stockData:
        return 0.3;  // 30%
      case ProtobufSyncStage.outletPricing:
        return 0.1;  // 10%
      case ProtobufSyncStage.finalizing:
        return 0.05; // 5%
      case ProtobufSyncStage.completed:
        return 0.0;  // 0%
    }
  }
}