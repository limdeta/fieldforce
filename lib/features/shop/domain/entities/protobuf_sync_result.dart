// lib/features/shop/domain/entities/protobuf_sync_result.dart

import 'protobuf_sync_progress.dart';

/// Результат выполнения protobuf синхронизации
class ProtobufSyncResult {
  /// Успешность выполнения
  final bool success;
  
  /// Общее время выполнения
  final Duration duration;
  
  /// Количество синхронизированных продуктов
  final int productsCount;
  
  /// Количество синхронизированных остатков
  final int stockItemsCount;

  /// Количество синхронизированных складов
  final int warehousesCount;
  
  /// Количество синхронизированных цен
  final int outletPricingCount;
  
  /// Список ошибок (если есть)
  final List<String> errors;
  
  /// Детальная информация об ошибках для отладки
  final List<ProtobufSyncError> detailedErrors;
  
  /// Время начала синхронизации
  final DateTime startTime;
  
  /// Время завершения синхронизации
  final DateTime endTime;
  
  /// Регион, для которого выполнялась синхронизация
  final String regionCode;
  
  /// Список торговых точек (vendorId)
  final List<String> outletVendorIds;

  const ProtobufSyncResult({
    required this.success,
    required this.duration,
    required this.productsCount,
    required this.stockItemsCount,
    required this.warehousesCount,
    required this.outletPricingCount,
    required this.errors,
    required this.detailedErrors,
    required this.startTime,
    required this.endTime,
    required this.regionCode,
  required this.outletVendorIds,
  });

  /// Проверяет, есть ли ошибки
  bool get hasErrors => errors.isNotEmpty || detailedErrors.isNotEmpty;

  /// Возвращает общее количество синхронизированных элементов
  int get totalItemsCount => productsCount + stockItemsCount + outletPricingCount + warehousesCount;

  /// Возвращает общее количество ошибок
  int get errorCount => errors.length + detailedErrors.length;

  /// Создает успешный результат
  factory ProtobufSyncResult.success({
    required Duration duration,
    required int productsCount,
    required int stockItemsCount,
    required int warehousesCount,
    required int outletPricingCount,
    required DateTime startTime,
    required DateTime endTime,
    required String regionCode,
    required List<String> outletVendorIds,
  }) {
    return ProtobufSyncResult(
      success: true,
      duration: duration,
      productsCount: productsCount,
      stockItemsCount: stockItemsCount,
      warehousesCount: warehousesCount,
      outletPricingCount: outletPricingCount,
      errors: [],
      detailedErrors: [],
      startTime: startTime,
      endTime: endTime,
      regionCode: regionCode,
      outletVendorIds: outletVendorIds,
    );
  }

  /// Создает результат с ошибкой
  factory ProtobufSyncResult.failure({
    required Duration duration,
    required List<String> errors,
    required List<ProtobufSyncError> detailedErrors,
    required DateTime startTime,
    required DateTime endTime,
    required String regionCode,
    required List<String> outletVendorIds,
    int productsCount = 0,
    int stockItemsCount = 0,
    int warehousesCount = 0,
    int outletPricingCount = 0,
  }) {
    return ProtobufSyncResult(
      success: false,
      duration: duration,
      productsCount: productsCount,
      stockItemsCount: stockItemsCount,
      warehousesCount: warehousesCount,
      outletPricingCount: outletPricingCount,
      errors: errors,
      detailedErrors: detailedErrors,
      startTime: startTime,
      endTime: endTime,
      regionCode: regionCode,
      outletVendorIds: outletVendorIds,
    );
  }

  /// Форматирует результат для отображения в UI
  String get displaySummary {
    if (success) {
      return 'Синхронизация успешна: $totalItemsCount элементов за ${_formatDuration(duration)}';
    } else {
      return 'Ошибка синхронизации: $errorCount ошибок, обработано $totalItemsCount элементов';
    }
  }

  /// Создает лог для копирования в поддержку
  String get supportLog {
    final buffer = StringBuffer();
    buffer.writeln('=== PROTOBUF SYNC LOG ===');
    buffer.writeln('Время: ${startTime.toIso8601String()} - ${endTime.toIso8601String()}');
    buffer.writeln('Длительность: ${_formatDuration(duration)}');
    buffer.writeln('Регион: $regionCode');
  buffer.writeln('Торговые точки: ${outletVendorIds.join(", ")}');
    buffer.writeln('Результат: ${success ? "УСПЕХ" : "ОШИБКА"}');
    buffer.writeln('');
    buffer.writeln('=== СТАТИСТИКА ===');
    buffer.writeln('Продукты: $productsCount');
    buffer.writeln('Остатки: $stockItemsCount');
  buffer.writeln('Склады: $warehousesCount');
    buffer.writeln('Цены: $outletPricingCount');
    buffer.writeln('Всего элементов: $totalItemsCount');
    
    if (hasErrors) {
      buffer.writeln('');
      buffer.writeln('=== ОШИБКИ ===');
      for (int i = 0; i < errors.length; i++) {
        buffer.writeln('${i + 1}. ${errors[i]}');
      }
      
      for (int i = 0; i < detailedErrors.length; i++) {
        final error = detailedErrors[i];
        buffer.writeln('${errors.length + i + 1}. [${error.stage.displayName}] ${error.message}');
        if (error.stackTrace != null) {
          buffer.writeln('   StackTrace: ${error.stackTrace}');
        }
      }
    }
    
    return buffer.toString();
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}с';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}м ${remainingSeconds}с';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}ч ${minutes}м';
    }
  }

  @override
  String toString() {
    return 'ProtobufSyncResult('
        'success: $success, '
        'items: $totalItemsCount, '
        'errors: $errorCount, '
        'duration: ${_formatDuration(duration)}'
        ')';
  }
}

/// Детальная информация об ошибке синхронизации
class ProtobufSyncError {
  /// Этап, на котором произошла ошибка
  final ProtobufSyncStage stage;
  
  /// Сообщение об ошибке
  final String message;
  
  /// Стек вызовов (для отладки)
  final String? stackTrace;
  
  /// Время возникновения ошибки
  final DateTime timestamp;
  
  /// Дополнительные данные об ошибке
  final Map<String, dynamic>? metadata;

  const ProtobufSyncError({
    required this.stage,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    this.metadata,
  });

  factory ProtobufSyncError.fromException(
    ProtobufSyncStage stage,
    Object exception,
    StackTrace? stackTrace,
  ) {
    return ProtobufSyncError(
      stage: stage,
      message: exception.toString(),
      stackTrace: stackTrace?.toString(),
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ProtobufSyncError(stage: ${stage.displayName}, message: $message)';
  }
}