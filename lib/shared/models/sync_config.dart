import 'package:equatable/equatable.dart';

/// Источник данных для синхронизации
enum SyncDataSource {
  /// Синхронизация через API
  api,

  /// Импорт из JSON файла
  jsonFile,

  /// Импорт из сжатого архива
  archive,
}

/// Конфигурация синхронизации
class SyncConfig extends Equatable {
  /// Источник данных
  final SyncDataSource source;

  /// Категории для фильтрации (для API)
  final String? categories;

  /// Размер страницы (для API)
  final int limit;

  /// Смещение для пагинации (для API)
  final int offset;

  /// Максимальное количество одновременных запросов
  final int maxConcurrent;

  /// Таймаут для запросов
  final Duration timeout;

  /// Максимальное количество повторных попыток при ошибке
  final int maxRetries;

  /// Задержка между повторными попытками
  final Duration retryDelay;

  /// Путь к файлу (для jsonFile и archive)
  final String? filePath;

  const SyncConfig({
    required this.source,
    this.categories = '29',
    this.limit = 20,
    this.offset = 0,
    this.maxConcurrent = 1,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.filePath,
  });

  /// Конфигурация для API синхронизации
  factory SyncConfig.api({
    String? categories = '29',
    int limit = 20,
    int offset = 0,
    int maxConcurrent = 1,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) =>
      SyncConfig(
        source: SyncDataSource.api,
        categories: categories,
        limit: limit,
        offset: offset,
        maxConcurrent: maxConcurrent,
        timeout: timeout,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );

  /// Конфигурация для импорта из JSON файла
  factory SyncConfig.jsonFile({
    required String filePath,
    Duration timeout = const Duration(minutes: 5),
    int maxRetries = 1,
  }) =>
      SyncConfig(
        source: SyncDataSource.jsonFile,
        filePath: filePath,
        timeout: timeout,
        maxRetries: maxRetries,
      );

  /// Конфигурация для импорта из архива
  factory SyncConfig.archive({
    required String filePath,
    Duration timeout = const Duration(minutes: 10),
    int maxRetries = 1,
  }) =>
      SyncConfig(
        source: SyncDataSource.archive,
        filePath: filePath,
        timeout: timeout,
        maxRetries: maxRetries,
      );

  @override
  List<Object?> get props => [
        source,
        categories,
        limit,
        offset,
        maxConcurrent,
        timeout,
        maxRetries,
        retryDelay,
        filePath,
      ];

  @override
  String toString() =>
      'SyncConfig(source: $source, categories: $categories, limit: $limit, offset: $offset, maxConcurrent: $maxConcurrent)';
}