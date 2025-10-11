part of 'data_sync_bloc.dart';

enum DataSyncTask {
  tradingPoints('Торговые точки'),
  categories('Категории прайса'),
  regionProducts('Продукты по региону'),
  regionStock('Остатки и базовые цены'),
  outletPrices('Цены торговых точек');

  const DataSyncTask(this.displayName);

  final String displayName;

  static const List<DataSyncTask> fullOrder = <DataSyncTask>[
    DataSyncTask.tradingPoints,
    DataSyncTask.categories,
    DataSyncTask.regionProducts,
    DataSyncTask.regionStock,
    DataSyncTask.outletPrices,
  ];
}

enum DataSyncStatus { idle, running, success, failure, cancelled }

class DataSyncLastRunInfo extends Equatable {
  const DataSyncLastRunInfo({
    this.timestamp,
    this.regionCode,
    this.tradingPointExternalId,
    this.details,
  });

  final DateTime? timestamp;
  final String? regionCode;
  final String? tradingPointExternalId;
  final Map<String, dynamic>? details;

  DataSyncLastRunInfo copyWith({
    DateTime? timestamp,
    String? regionCode,
    String? tradingPointExternalId,
    Map<String, dynamic>? details,
  }) {
    return DataSyncLastRunInfo(
      timestamp: timestamp ?? this.timestamp,
      regionCode: regionCode ?? this.regionCode,
      tradingPointExternalId: tradingPointExternalId ?? this.tradingPointExternalId,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        timestamp,
        regionCode,
        tradingPointExternalId,
        details,
      ];
}

class DataSyncTaskInfo extends Equatable {
  const DataSyncTaskInfo({
    required this.status,
    this.report,
    this.message,
    this.startedAt,
    this.finishedAt,
  });

  final DataSyncStatus status;
  final SyncReport? report;
  final String? message;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  DataSyncTaskInfo copyWith({
    DataSyncStatus? status,
    SyncReport? report,
    String? message,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return DataSyncTaskInfo(
      status: status ?? this.status,
      report: report ?? this.report,
      message: message ?? this.message,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  static const DataSyncTaskInfo initial = DataSyncTaskInfo(status: DataSyncStatus.idle);

  @override
  List<Object?> get props => <Object?>[
        status,
        report,
        message,
        startedAt,
        finishedAt,
      ];
}

class DataSyncState extends Equatable {
  const DataSyncState({
    required this.tasks,
    required this.isFullSyncInProgress,
    required this.isInitializing,
    required this.lastRuns,
    required this.currentRegionCode,
    required this.currentOutletVendorIds,
    this.globalMessage,
  });

  final Map<DataSyncTask, DataSyncTaskInfo> tasks;
  final bool isFullSyncInProgress;
  final bool isInitializing;
  final Map<DataSyncTask, DataSyncLastRunInfo> lastRuns;
  final String currentRegionCode;
  final List<String> currentOutletVendorIds;
  final String? globalMessage;

  static DataSyncState initial() {
    final initialTasks = <DataSyncTask, DataSyncTaskInfo>{
      for (final task in DataSyncTask.values) task: DataSyncTaskInfo.initial,
    };

    return DataSyncState(
      tasks: initialTasks,
      isFullSyncInProgress: false,
      isInitializing: true,
      lastRuns: <DataSyncTask, DataSyncLastRunInfo>{},
      currentRegionCode: '',
      currentOutletVendorIds: const <String>[],
      globalMessage: null,
    );
  }

  bool get isBusy =>
      isFullSyncInProgress || tasks.values.any((info) => info.status == DataSyncStatus.running);

  DataSyncState copyWith({
    Map<DataSyncTask, DataSyncTaskInfo>? tasks,
    bool? isFullSyncInProgress,
    bool? isInitializing,
    Map<DataSyncTask, DataSyncLastRunInfo>? lastRuns,
    String? currentRegionCode,
    List<String>? currentOutletVendorIds,
    String? globalMessage,
    bool updateMessage = false,
  }) {
    return DataSyncState(
      tasks: tasks ?? this.tasks,
      isFullSyncInProgress: isFullSyncInProgress ?? this.isFullSyncInProgress,
      isInitializing: isInitializing ?? this.isInitializing,
      lastRuns: lastRuns ?? this.lastRuns,
      currentRegionCode: currentRegionCode ?? this.currentRegionCode,
      currentOutletVendorIds: currentOutletVendorIds ?? this.currentOutletVendorIds,
      globalMessage: updateMessage ? globalMessage : this.globalMessage,
    );
  }

  DataSyncState markTaskRunning(
    DataSyncTask task, {
    required bool asPartOfFullSync,
  }) {
    final updatedTasks = Map<DataSyncTask, DataSyncTaskInfo>.from(tasks);
    updatedTasks[task] = DataSyncTaskInfo(
      status: DataSyncStatus.running,
      startedAt: DateTime.now(),
    );

    return DataSyncState(
      tasks: updatedTasks,
      isFullSyncInProgress: asPartOfFullSync ? true : isFullSyncInProgress,
      isInitializing: isInitializing,
      lastRuns: lastRuns,
      currentRegionCode: currentRegionCode,
      currentOutletVendorIds: currentOutletVendorIds,
      globalMessage: globalMessage,
    );
  }

  DataSyncState markTaskSucceeded(DataSyncTask task, SyncReport report) {
    final updatedTasks = Map<DataSyncTask, DataSyncTaskInfo>.from(tasks);
    updatedTasks[task] = DataSyncTaskInfo(
      status: DataSyncStatus.success,
      report: report,
      message: report.description ?? 'Шаг завершен успешно',
      startedAt: tasks[task]?.startedAt,
      finishedAt: DateTime.now(),
    );

    return DataSyncState(
      tasks: updatedTasks,
      isFullSyncInProgress: isFullSyncInProgress,
      isInitializing: isInitializing,
      lastRuns: lastRuns,
      currentRegionCode: currentRegionCode,
      currentOutletVendorIds: currentOutletVendorIds,
      globalMessage: globalMessage,
    );
  }

  DataSyncState markTaskFailed(DataSyncTask task, String message) {
    final updatedTasks = Map<DataSyncTask, DataSyncTaskInfo>.from(tasks);
    updatedTasks[task] = DataSyncTaskInfo(
      status: DataSyncStatus.failure,
      message: message,
      startedAt: tasks[task]?.startedAt,
      finishedAt: DateTime.now(),
    );

    return DataSyncState(
      tasks: updatedTasks,
      isFullSyncInProgress: false,
      isInitializing: isInitializing,
      lastRuns: lastRuns,
      currentRegionCode: currentRegionCode,
      currentOutletVendorIds: currentOutletVendorIds,
      globalMessage: globalMessage,
    );
  }

  DataSyncState resetTask(DataSyncTask task) {
    final updatedTasks = Map<DataSyncTask, DataSyncTaskInfo>.from(tasks);
    updatedTasks[task] = DataSyncTaskInfo.initial;

    return DataSyncState(
      tasks: updatedTasks,
      isFullSyncInProgress: isFullSyncInProgress,
      isInitializing: isInitializing,
      lastRuns: lastRuns,
      currentRegionCode: currentRegionCode,
      currentOutletVendorIds: currentOutletVendorIds,
      globalMessage: globalMessage,
    );
  }

  DataSyncState setLastRun(DataSyncTask task, DataSyncLastRunInfo info) {
    final updated = Map<DataSyncTask, DataSyncLastRunInfo>.from(lastRuns)
      ..[task] = info;

    return copyWith(lastRuns: updated);
  }

  DataSyncState markTaskCancelled(DataSyncTask task, {String? message}) {
    final updatedTasks = Map<DataSyncTask, DataSyncTaskInfo>.from(tasks);
    updatedTasks[task] = DataSyncTaskInfo(
      status: DataSyncStatus.cancelled,
      message: message,
      startedAt: tasks[task]?.startedAt,
      finishedAt: DateTime.now(),
    );

    return DataSyncState(
      tasks: updatedTasks,
      isFullSyncInProgress: false,
      isInitializing: isInitializing,
      lastRuns: lastRuns,
      currentRegionCode: currentRegionCode,
      currentOutletVendorIds: currentOutletVendorIds,
      globalMessage: globalMessage,
    );
  }

  List<DataSyncTaskInfo> get _orderedTaskInfo =>
      DataSyncTask.values.map((task) => tasks[task] ?? DataSyncTaskInfo.initial).toList();

  @override
  List<Object?> get props => <Object?>[
        _orderedTaskInfo,
        isFullSyncInProgress,
        isInitializing,
        lastRuns,
        currentRegionCode,
        currentOutletVendorIds,
        globalMessage,
      ];
}
