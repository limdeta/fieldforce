// lib/features/shop/presentation/bloc/protobuf_sync_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/features/shop/domain/usecases/perform_protobuf_sync_usecase.dart';
import 'package:fieldforce/features/shop/domain/entities/protobuf_sync_progress.dart';
import 'package:fieldforce/features/shop/domain/entities/protobuf_sync_result.dart';

part 'protobuf_sync_event.dart';
part 'protobuf_sync_state.dart';

class ProtobufSyncBloc extends Bloc<ProtobufSyncEvent, ProtobufSyncState> {
  static final Logger _logger = Logger('ProtobufSyncBloc');

  final PerformProtobufSyncUseCase _performProtobufSyncUseCase;
  
  StreamSubscription<ProtobufSyncProgress>? _progressSubscription;
  StreamSubscription<ProtobufSyncResult>? _resultSubscription;

  ProtobufSyncBloc({
    required PerformProtobufSyncUseCase performProtobufSyncUseCase,
  })  : _performProtobufSyncUseCase = performProtobufSyncUseCase,
        super(const ProtobufSyncInitial()) {
    
    on<StartProtobufSyncEvent>(_onStartProtobufSync);
    on<CancelProtobufSyncEvent>(_onCancelProtobufSync);
    on<_UpdateProgressEvent>(_onUpdateProgress);
    on<_SyncCompletedEvent>(_onSyncCompleted);
    on<ResetProtobufSyncEvent>(_onResetProtobufSync);
  }

  Future<void> _onStartProtobufSync(
    StartProtobufSyncEvent event,
    Emitter<ProtobufSyncState> emit,
  ) async {
    if (state is ProtobufSyncInProgress) {
      _logger.warning('Попытка запустить синхронизацию когда она уже выполняется');
      return;
    }

    _logger.info('Запуск протобуф синхронизации');
    
    try {
      // Отменяем предыдущие подписки
      await _cancelSubscriptions();

      // Подписываемся на прогресс
      _progressSubscription = _performProtobufSyncUseCase.progressStream.listen(
        (progress) {
          add(_UpdateProgressEvent(progress));
        },
        onError: (error, stackTrace) {
          _logger.severe('Ошибка в потоке прогресса', error, stackTrace);
        },
      );

      // Подписываемся на результат
      _resultSubscription = _performProtobufSyncUseCase.resultStream.listen(
        (result) {
          add(_SyncCompletedEvent(result));
        },
        onError: (error, stackTrace) {
          _logger.severe('Ошибка в потоке результата', error, stackTrace);
        },
      );

      // Запускаем синхронизацию (используем дефолтные параметры для тестирования)
      await _performProtobufSyncUseCase.call(
        regionFiasId: AppConfig.defaultRegionFiasId, // Владивосток (реальный FIAS)
        outletIds: [], // Пустой список для начала
      );

    } catch (error, stackTrace) {
      _logger.severe('Ошибка при запуске протобуф синхронизации', error, stackTrace);
      
      // Создаем результат с ошибкой
      final now = DateTime.now();
      final errorResult = ProtobufSyncResult.failure(
        errors: ['Ошибка запуска синхронизации: $error'],
        detailedErrors: [],
        duration: Duration.zero,
        startTime: now,
        endTime: now,
        regionFiasId: AppConfig.defaultRegionFiasId,
        outletIds: [],
      );
      
      emit(ProtobufSyncFailure(errorResult));
    }
  }

  Future<void> _onCancelProtobufSync(
    CancelProtobufSyncEvent event,
    Emitter<ProtobufSyncState> emit,
  ) async {
    _logger.info('Отмена протобуф синхронизации');
    
    // Отменяем use case
    _performProtobufSyncUseCase.cancel();
    
    // Отменяем подписки
    await _cancelSubscriptions();
    
    emit(const ProtobufSyncCancelled());
  }

  void _onUpdateProgress(
    _UpdateProgressEvent event,
    Emitter<ProtobufSyncState> emit,
  ) {
    _logger.fine('Обновление прогресса: ${event.progress.currentStage.displayName}');
    emit(ProtobufSyncInProgress(event.progress));
  }

  void _onSyncCompleted(
    _SyncCompletedEvent event,
    Emitter<ProtobufSyncState> emit,
  ) {
    _logger.info('Протобуф синхронизация завершена');
    
    // Отменяем подписки
    _cancelSubscriptions();
    
    if (event.result.success) {
      _logger.info('Синхронизация успешна: ${event.result.productsCount} продуктов, ${event.result.stockItemsCount} позиций склада');
      emit(ProtobufSyncSuccess(event.result));
    } else {
      _logger.warning('Синхронизация завершилась с ошибкой: ${event.result.errors.join(", ")}');
      emit(ProtobufSyncFailure(event.result));
    }
  }

  void _onResetProtobufSync(
    ResetProtobufSyncEvent event,
    Emitter<ProtobufSyncState> emit,
  ) {
    _logger.fine('Сброс состояния протобуф синхронизации');
    
    // Отменяем любые активные операции
    _performProtobufSyncUseCase.cancel();
    _cancelSubscriptions();
    
    emit(const ProtobufSyncInitial());
  }

  Future<void> _cancelSubscriptions() async {
    await _progressSubscription?.cancel();
    await _resultSubscription?.cancel();
    _progressSubscription = null;
    _resultSubscription = null;
  }

  @override
  Future<void> close() async {
    _logger.fine('Закрытие ProtobufSyncBloc');
    
    // Отменяем use case
    _performProtobufSyncUseCase.cancel();
    
    // Отменяем подписки
    await _cancelSubscriptions();
    
    return super.close();
  }
}