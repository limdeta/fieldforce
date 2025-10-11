part of 'data_sync_bloc.dart';

abstract class DataSyncEvent extends Equatable {
  const DataSyncEvent();

  @override
  List<Object?> get props => const [];
}

class DataSyncTaskRequested extends DataSyncEvent {
  const DataSyncTaskRequested(this.task);

  final DataSyncTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class DataSyncFullRequested extends DataSyncEvent {
  const DataSyncFullRequested();
}

class DataSyncInitialize extends DataSyncEvent {
  const DataSyncInitialize();
}

class DataSyncTaskReset extends DataSyncEvent {
  const DataSyncTaskReset(this.task);

  final DataSyncTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class DataSyncClearMessage extends DataSyncEvent {
  const DataSyncClearMessage();
}

class DataSyncRefreshContextRequested extends DataSyncEvent {
  const DataSyncRefreshContextRequested();
}

class DataSyncTaskCancelRequested extends DataSyncEvent {
  const DataSyncTaskCancelRequested(this.task);

  final DataSyncTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class DataSyncFullCancelRequested extends DataSyncEvent {
  const DataSyncFullCancelRequested();
}
