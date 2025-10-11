import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/database/repositories/sync_log_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_report.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_categories_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_outlet_prices_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_region_products_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_region_stock_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/sync_trading_points_usecase.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

part 'data_sync_event.dart';
part 'data_sync_state.dart';

class DataSyncBloc extends Bloc<DataSyncEvent, DataSyncState> {
  DataSyncBloc({
    required SyncTradingPointsUseCase syncTradingPointsUseCase,
    required SyncCategoriesUseCase syncCategoriesUseCase,
    required SyncRegionProductsUseCase syncRegionProductsUseCase,
    required SyncRegionStockUseCase syncRegionStockUseCase,
    required SyncOutletPricesUseCase syncOutletPricesUseCase,
    required SyncLogRepository syncLogRepository,
  })  : _syncTradingPointsUseCase = syncTradingPointsUseCase,
        _syncCategoriesUseCase = syncCategoriesUseCase,
        _syncRegionProductsUseCase = syncRegionProductsUseCase,
        _syncRegionStockUseCase = syncRegionStockUseCase,
        _syncOutletPricesUseCase = syncOutletPricesUseCase,
        _syncLogRepository = syncLogRepository,
        super(DataSyncState.initial()) {
    on<DataSyncInitialize>(_onInitialize);
    on<DataSyncTaskRequested>(_onTaskRequested);
    on<DataSyncTaskCancelRequested>(_onTaskCancelRequested);
    on<DataSyncTaskReset>(_onTaskReset);
    on<DataSyncFullRequested>(_onFullRequested);
    on<DataSyncFullCancelRequested>(_onFullCancelRequested);
    on<DataSyncClearMessage>(_onClearMessage);
    on<DataSyncRefreshContextRequested>(_onRefreshContextRequested);
  }

  static final Logger _logger = Logger('DataSyncBloc');

  final SyncTradingPointsUseCase _syncTradingPointsUseCase;
  final SyncCategoriesUseCase _syncCategoriesUseCase;
  final SyncRegionProductsUseCase _syncRegionProductsUseCase;
  final SyncRegionStockUseCase _syncRegionStockUseCase;
  final SyncOutletPricesUseCase _syncOutletPricesUseCase;
  final SyncLogRepository _syncLogRepository;

  final Set<DataSyncTask> _cancelledTasks = <DataSyncTask>{};
  bool _fullSyncCancellationRequested = false;

  Future<void> _onInitialize(
    DataSyncInitialize event,
    Emitter<DataSyncState> emit,
  ) async {
    emit(state.copyWith(isInitializing: true));

    final context = await _resolveSyncContext();
    final lastRuns = await _loadLastRuns(context);

    emit(state.copyWith(
      isInitializing: false,
      currentRegionCode: context.regionCode,
      currentOutletVendorIds: context.outletVendorIds,
      lastRuns: lastRuns,
    ));
  }

  Future<void> _onRefreshContextRequested(
    DataSyncRefreshContextRequested event,
    Emitter<DataSyncState> emit,
  ) async {
    final context = await _resolveSyncContext();
    final lastRuns = await _loadLastRuns(context);

    emit(state.copyWith(
      currentRegionCode: context.regionCode,
      currentOutletVendorIds: context.outletVendorIds,
      lastRuns: lastRuns,
    ));
  }

  Future<void> _onTaskRequested(
    DataSyncTaskRequested event,
    Emitter<DataSyncState> emit,
  ) async {
    if (state.isBusy || state.isInitializing) {
      _logger.warning('Попытка запустить синхронизацию, пока предыдущая еще выполняется');
      return;
    }

    final context = await _resolveSyncContext();
    emit(state.copyWith(
      currentRegionCode: context.regionCode,
      currentOutletVendorIds: context.outletVendorIds,
    ));

    await _runTask(event.task, context, emit, asPartOfFullSync: false);
  }

  Future<void> _onFullRequested(
    DataSyncFullRequested event,
    Emitter<DataSyncState> emit,
  ) async {
    if (state.isBusy || state.isInitializing) {
      _logger.warning('Полная синхронизация не может быть запущена — уже идет другая операция');
      return;
    }

    _fullSyncCancellationRequested = false;
    await _logFullSyncEvent(eventType: 'start', message: 'Полная синхронизация запущена');

    emit(state.copyWith(isFullSyncInProgress: true, globalMessage: null, updateMessage: true));

    final context = await _resolveSyncContext();
    emit(state.copyWith(
      currentRegionCode: context.regionCode,
      currentOutletVendorIds: context.outletVendorIds,
    ));

    for (final task in DataSyncTask.fullOrder) {
      if (_fullSyncCancellationRequested) {
        await _logFullSyncEvent(eventType: 'cancelled', message: 'Полная синхронизация отменена пользователем');
        emit(state.copyWith(
          isFullSyncInProgress: false,
          globalMessage: 'Полная синхронизация отменена пользователем',
          updateMessage: true,
        ));
        return;
      }

      final success = await _runTask(task, context, emit, asPartOfFullSync: true);
      if (!success) {
        await _logFullSyncEvent(eventType: 'failed', message: 'Полная синхронизация остановлена на шаге "${task.displayName}"');
        emit(state.copyWith(
          isFullSyncInProgress: false,
          globalMessage: 'Полная синхронизация остановлена на шаге "${task.displayName}"',
          updateMessage: true,
        ));
        return;
      }
    }

    await _logFullSyncEvent(eventType: 'success', message: 'Полная синхронизация успешно завершена');
    emit(state.copyWith(
      isFullSyncInProgress: false,
      globalMessage: 'Полная синхронизация успешно завершена',
      updateMessage: true,
    ));
  }

  Future<void> _onFullCancelRequested(
    DataSyncFullCancelRequested event,
    Emitter<DataSyncState> emit,
  ) async {
    if (!state.isFullSyncInProgress) {
      return;
    }

    _fullSyncCancellationRequested = true;
    await _logFullSyncEvent(
      eventType: 'cancel-requested',
      message: 'Пользователь запросил отмену полной синхронизации',
    );
  }

  void _onTaskReset(
    DataSyncTaskReset event,
    Emitter<DataSyncState> emit,
  ) {
    if (state.isBusy) {
      _logger.warning('Нельзя сбросить состояние во время активной синхронизации');
      return;
    }

    emit(state.resetTask(event.task));
  }

  Future<void> _onTaskCancelRequested(
    DataSyncTaskCancelRequested event,
    Emitter<DataSyncState> emit,
  ) async {
    final info = state.tasks[event.task] ?? DataSyncTaskInfo.initial;
    if (info.status == DataSyncStatus.running) {
      _cancelledTasks.add(event.task);
      await _logTaskEvent(
        task: event.task,
        eventType: 'cancel-requested',
        message: 'Пользователь запросил отмену операции',
        status: 'cancelled',
      );
    } else {
      emit(state.resetTask(event.task));
    }
  }

  void _onClearMessage(
    DataSyncClearMessage event,
    Emitter<DataSyncState> emit,
  ) {
    emit(state.copyWith(globalMessage: null, updateMessage: true));
  }

  Future<bool> _runTask(
    DataSyncTask task,
    _SyncContext context,
    Emitter<DataSyncState> emit, {
    required bool asPartOfFullSync,
  }) async {
    _cancelledTasks.remove(task);

    await _logTaskEvent(
      task: task,
      eventType: 'start',
      message: 'Синхронизация "${task.displayName}" запущена',
      status: 'running',
      context: context,
    );

    emit(state
        .markTaskRunning(task, asPartOfFullSync: asPartOfFullSync)
        .copyWith(currentRegionCode: context.regionCode, currentOutletVendorIds: context.outletVendorIds));

    final start = DateTime.now();
    final Either<Failure, SyncReport> result = await _executeTask(task, context);
    final duration = DateTime.now().difference(start);

    if (_cancelledTasks.remove(task) || (_fullSyncCancellationRequested && asPartOfFullSync)) {
      await _logTaskEvent(
        task: task,
        eventType: 'cancelled',
        message: 'Синхронизация "${task.displayName}" отменена пользователем',
        status: 'cancelled',
        duration: duration,
        context: context,
      );

      emit(state.markTaskCancelled(task, message: 'Отменено пользователем'));
      return false;
    }

    return await result.fold(
      (failure) async {
        _logger.warning('Шаг синхронизации "${task.displayName}" завершился ошибкой: ${failure.message}');
        final Map<String, dynamic> failureDetails = <String, dynamic>{
          'type': failure.runtimeType.toString(),
        };

        final Object? extra = failure.details;
        if (extra is Map<String, dynamic>) {
          failureDetails.addAll(extra);
        } else if (extra is Iterable) {
          failureDetails['errors'] = extra.toList();
        } else if (extra != null) {
          failureDetails['detail'] = extra;
        }

        await _logTaskEvent(
          task: task,
          eventType: 'failure',
          message: failure.message,
          status: 'failure',
          duration: duration,
          details: failureDetails,
          context: context,
        );
        emit(state.markTaskFailed(task, failure.message));
        return false;
      },
      (report) async {
        final info = DataSyncLastRunInfo(
          timestamp: DateTime.now(),
          regionCode: context.regionCode,
          tradingPointExternalId: context.primaryOutletId,
          details: report.details,
        );

        await _logTaskEvent(
          task: task,
          eventType: 'success',
          message: report.description ?? 'Синхронизация "${task.displayName}" завершена',
          status: 'success',
          duration: duration,
          details: <String, dynamic>{
            'processedCount': report.processedCount,
            ...report.details,
          },
          context: context,
        );

        emit(state
            .markTaskSucceeded(task, report)
            .setLastRun(task, info));

        return true;
      },
    );
  }

  Future<Either<Failure, SyncReport>> _executeTask(DataSyncTask task, _SyncContext context) async {
    switch (task) {
      case DataSyncTask.tradingPoints:
        return _syncTradingPointsUseCase();
      case DataSyncTask.categories:
        return _syncCategoriesUseCase();
      case DataSyncTask.regionProducts:
        return _syncRegionProductsUseCase(context.regionCode);
      case DataSyncTask.regionStock:
        return _syncRegionStockUseCase(context.regionCode);
      case DataSyncTask.outletPrices:
        return _syncOutletPricesUseCase(context.outletVendorIds);
    }
  }

  Future<Map<DataSyncTask, DataSyncLastRunInfo>> _loadLastRuns(_SyncContext context) async {
    final Map<DataSyncTask, DataSyncLastRunInfo> lastRuns = <DataSyncTask, DataSyncLastRunInfo>{};

    Future<void> load(DataSyncTask task, {String? regionCode, String? tradingPointExternalId}) async {
      final entry = await _syncLogRepository.getLastSuccessEntryForTask(
        _taskKey(task),
        regionCode: regionCode,
        tradingPointExternalId: tradingPointExternalId,
      );

      if (entry != null) {
        lastRuns[task] = DataSyncLastRunInfo(
          timestamp: entry.createdAt,
          regionCode: entry.regionCode,
          tradingPointExternalId: entry.tradingPointExternalId,
          details: entry.details,
        );
      }
    }

    await load(DataSyncTask.tradingPoints);
    await load(DataSyncTask.categories);
    await load(DataSyncTask.regionProducts, regionCode: context.regionCode);
    await load(DataSyncTask.regionStock, regionCode: context.regionCode);
    final primaryOutlet = context.primaryOutletId;
    if (primaryOutlet != null) {
      await load(DataSyncTask.outletPrices, tradingPointExternalId: primaryOutlet);
    }

    return lastRuns;
  }

  Future<void> _logFullSyncEvent({
    required String eventType,
    required String message,
  }) async {
    try {
      await _syncLogRepository.logEvent(
        task: _fullSyncKey,
        eventType: eventType,
        message: message,
        status: eventType,
      );
    } catch (e, stackTrace) {
      _logger.warning('Не удалось записать событие полной синхронизации: $e', e, stackTrace);
    }
  }

  Future<void> _logTaskEvent({
    required DataSyncTask task,
    required String eventType,
    required String message,
    String? status,
    Duration? duration,
    Map<String, dynamic>? details,
    _SyncContext? context,
  }) async {
    try {
      await _syncLogRepository.logEvent(
        task: _taskKey(task),
        eventType: eventType,
        message: message,
        status: status,
        duration: duration,
        details: details,
        regionCode: context?.regionCode,
        tradingPointExternalId: context?.primaryOutletId,
      );
    } catch (e, stackTrace) {
      _logger.warning('Не удалось записать лог синхронизации для ${task.displayName}: $e', e, stackTrace);
    }
  }

  Future<_SyncContext> _resolveSyncContext() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();

    return sessionResult.fold(
      (failure) {
        _logger.warning('Не удалось получить текущую сессию: ${failure.message}');
        return _SyncContext(regionCode: AppConfig.defaultRegionCode, outletVendorIds: const <String>[]);
      },
      (session) {
        final tradingPoint = session?.appUser.selectedTradingPoint;
        final regionRaw = tradingPoint?.region;
        final region = regionRaw?.trim();
        String resolvedRegion = AppConfig.defaultRegionCode;
        if (region != null && region.isNotEmpty) {
          resolvedRegion = region;
        }

        final vendorIdRaw = tradingPoint?.externalId;
        final vendorId = vendorIdRaw?.trim();
        final outletIds = <String>[];
        if (vendorId != null && vendorId.isNotEmpty) {
          outletIds.add(vendorId);
        }

        return _SyncContext(regionCode: resolvedRegion, outletVendorIds: outletIds);
      },
    );
  }

  String _taskKey(DataSyncTask task) => task.name;

  static const String _fullSyncKey = 'full';
}

class _SyncContext {
  const _SyncContext({
    required this.regionCode,
    required this.outletVendorIds,
  });

  final String regionCode;
  final List<String> outletVendorIds;

  String? get primaryOutletId => outletVendorIds.isNotEmpty ? outletVendorIds.first : null;
}
