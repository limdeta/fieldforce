// lib/features/shop/domain/usecases/perform_protobuf_sync_usecase.dart

import 'dart:async';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

import '../../data/sync/services/protobuf_sync_coordinator.dart';
import '../entities/protobuf_sync_progress.dart';
import '../entities/protobuf_sync_result.dart';

/// Use case для выполнения protobuf синхронизации
/// 
/// Управляет процессом синхронизации региональных данных, остатков и цен
/// Предоставляет прогресс в реальном времени через Stream
class PerformProtobufSyncUseCase {
  static final Logger _logger = Logger('PerformProtobufSyncUseCase');
  
  final ProtobufSyncCoordinator _syncCoordinator;
  
  // Контроллеры для управления потоками
  StreamController<ProtobufSyncProgress>? _progressController;
  StreamController<ProtobufSyncResult>? _resultController;
  
  // Состояние синхронизации
  bool _isRunning = false;
  bool _isCancelled = false;
  DateTime? _startTime;

  PerformProtobufSyncUseCase(this._syncCoordinator);

  /// Поток прогресса синхронизации
  Stream<ProtobufSyncProgress> get progressStream {
    _progressController ??= StreamController<ProtobufSyncProgress>.broadcast();
    return _progressController!.stream;
  }

  /// Поток результатов синхронизации
  Stream<ProtobufSyncResult> get resultStream {
    _resultController ??= StreamController<ProtobufSyncResult>.broadcast();
    return _resultController!.stream;
  }

  /// Проверяет, выполняется ли синхронизация
  bool get isRunning => _isRunning;

  /// Выполняет полную региональную синхронизацию
  /// 
  /// [regionCode] - строковый код региона (например, P3V, M3V, K3V)
  /// [outletVendorIds] - список торговых точек (vendorId) для синхронизации цен
  /// [forceFullSync] - принудительная полная синхронизация (игнорировать кэш)
  Future<Either<Failure, ProtobufSyncResult>> call({
    required String regionCode,
    required List<String> outletVendorIds,
    bool forceFullSync = false,
  }) async {
    if (_isRunning) {
      return Left(ValidationFailure('Синхронизация уже выполняется'));
    }

  _logger.info('🚀 Начинаем protobuf синхронизацию: регион=$regionCode, точки=$outletVendorIds, полная=$forceFullSync');
    
    _isRunning = true;
    _isCancelled = false;
    _startTime = DateTime.now();
    
    try {
      // Инициализируем контроллеры, если нужно
      _progressController ??= StreamController<ProtobufSyncProgress>.broadcast();
      _resultController ??= StreamController<ProtobufSyncResult>.broadcast();
      
      // Отправляем начальный прогресс
      _emitProgress(ProtobufSyncProgress.initial());
      
      // Выполняем синхронизацию
      final result = await _performSyncWithProgress(
        regionCode,
  outletVendorIds,
        forceFullSync,
      );
      
      // Отправляем результат
      _resultController!.add(result);
      
      _logger.info('✅ Protobuf синхронизация завершена: $result');
      return Right(result);
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Критическая ошибка protobuf синхронизации: $e', e, stackTrace);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);
      
      final errorResult = ProtobufSyncResult.failure(
        duration: duration,
        errors: [e.toString()],
        detailedErrors: [
          ProtobufSyncError.fromException(
            ProtobufSyncStage.preparation,
            e,
            stackTrace,
          ),
        ],
        startTime: _startTime!,
        endTime: endTime,
  regionCode: regionCode,
  outletVendorIds: outletVendorIds,
        warehousesCount: 0,
      );
      
      _resultController?.add(errorResult);
      return Left(GeneralFailure('Ошибка синхронизации: $e', details: stackTrace));
      
    } finally {
      _isRunning = false;
    }
  }

  /// Отменяет текущую синхронизацию
  Future<void> cancel() async {
    if (!_isRunning) return;
    
    _logger.info('🛑 Отмена protobuf синхронизации');
    _isCancelled = true;
    
    // TODO: Добавить поддержку отмены в ProtobufSyncCoordinator
    // await _syncCoordinator.cancel();
  }

  /// Освобождает ресурсы
  void dispose() {
    _progressController?.close();
    _resultController?.close();
    _progressController = null;
    _resultController = null;
  }

  /// Выполняет синхронизацию с отслеживанием прогресса
  Future<ProtobufSyncResult> _performSyncWithProgress(
    String regionCode,
    List<String> outletVendorIds,
    bool forceFullSync,
  ) async {
    final errors = <String>[];
    final detailedErrors = <ProtobufSyncError>[];
    
  var productsCount = 0;
  var stockItemsCount = 0;
  var warehousesCount = 0;
  var outletPricingCount = 0;

    try {
      // Этап 1: Подготовка
      _emitProgress(_createProgress(
        ProtobufSyncStage.preparation,
        0.0,
        'Подготовка к синхронизации...',
      ));
      
      if (_isCancelled) throw Exception('Синхронизация отменена пользователем');

      // Этап 2: Региональные данные
      _emitProgress(_createProgress(
        ProtobufSyncStage.regionalData,
        0.0,
        'Загрузка региональных данных...',
      ));

      final syncResult = await _syncCoordinator.performFullSync(
        regionCode,
        outletVendorIds: outletVendorIds,
      );

      if (syncResult['success'] as bool) {
        productsCount = syncResult['products_synced'] as int;
        stockItemsCount = syncResult['stock_synced'] as int;
        warehousesCount = (syncResult['warehouses_synced'] as int?) ?? 0;
        outletPricingCount = syncResult['prices_synced'] as int;
        
        _emitProgress(_createProgress(
          ProtobufSyncStage.completed,
          1.0,
          'Синхронизация завершена успешно',
          processedItems: productsCount + stockItemsCount + outletPricingCount + warehousesCount,
          totalItems: productsCount + stockItemsCount + outletPricingCount + warehousesCount,
        ));
      } else {
        final errorList = syncResult['errors'] as List<String>;
        if (errorList.isNotEmpty) {
          errors.addAll(errorList);
          for (final errorMsg in errorList) {
            detailedErrors.add(ProtobufSyncError(
              stage: ProtobufSyncStage.regionalData,
              message: errorMsg,
              timestamp: DateTime.now(),
            ));
          }
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);

      if ((syncResult['success'] as bool) && errors.isEmpty) {
        return ProtobufSyncResult.success(
          duration: duration,
          productsCount: productsCount,
          stockItemsCount: stockItemsCount,
          warehousesCount: warehousesCount,
          outletPricingCount: outletPricingCount,
          startTime: _startTime!,
          endTime: endTime,
          regionCode: regionCode,
          outletVendorIds: outletVendorIds,
        );
      } else {
        return ProtobufSyncResult.failure(
          duration: duration,
          errors: errors,
          detailedErrors: detailedErrors,
          startTime: _startTime!,
          endTime: endTime,
          regionCode: regionCode,
          outletVendorIds: outletVendorIds,
          productsCount: productsCount,
          stockItemsCount: stockItemsCount,
          warehousesCount: warehousesCount,
          outletPricingCount: outletPricingCount,
        );
      }

    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка в процессе синхронизации: $e', e, stackTrace);
      
      errors.add(e.toString());
      detailedErrors.add(ProtobufSyncError.fromException(
        ProtobufSyncStage.regionalData,
        e,
        stackTrace,
      ));

      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);

      return ProtobufSyncResult.failure(
        duration: duration,
        errors: errors,
        detailedErrors: detailedErrors,
        startTime: _startTime!,
        endTime: endTime,
        regionCode: regionCode,
        outletVendorIds: outletVendorIds,
        productsCount: productsCount,
        stockItemsCount: stockItemsCount,
        warehousesCount: warehousesCount,
        outletPricingCount: outletPricingCount,
      );
    }
  }

  /// Создает объект прогресса с базовыми параметрами
  ProtobufSyncProgress _createProgress(
    ProtobufSyncStage stage,
    double stageProgress,
    String message, {
    int processedItems = 0,
    int totalItems = 0,
  }) {
    // Вычисляем общий прогресс на основе весов этапов
    double overallProgress = 0.0;
    
    // Добавляем прогресс завершенных этапов
    for (final completedStage in ProtobufSyncStage.values) {
      if (completedStage.index < stage.index) {
        overallProgress += completedStage.weight;
      } else if (completedStage == stage) {
        overallProgress += completedStage.weight * stageProgress;
        break;
      }
    }

    return ProtobufSyncProgress(
      currentStage: stage,
      overallProgress: overallProgress.clamp(0.0, 1.0),
      stageProgress: stageProgress.clamp(0.0, 1.0),
      processedItems: processedItems,
      totalItems: totalItems,
      message: message,
      startTime: _startTime!,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Отправляет обновление прогресса в поток
  void _emitProgress(ProtobufSyncProgress progress) {
    _logger.fine('📊 Прогресс: ${progress.currentStage.displayName} - ${(progress.overallProgress * 100).toStringAsFixed(1)}%');
    _progressController?.add(progress);
  }
}