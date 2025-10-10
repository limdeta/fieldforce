// lib/features/shop/presentation/bloc/protobuf_sync_event.dart

part of 'protobuf_sync_bloc.dart';

@immutable
abstract class ProtobufSyncEvent extends Equatable {
  const ProtobufSyncEvent();

  @override
  List<Object?> get props => [];
}

/// Начать протобуф синхронизацию
class StartProtobufSyncEvent extends ProtobufSyncEvent {
  const StartProtobufSyncEvent();
}

/// Отменить протобуф синхронизацию
class CancelProtobufSyncEvent extends ProtobufSyncEvent {
  const CancelProtobufSyncEvent();
}

/// Внутреннее событие для обновления прогресса
class _UpdateProgressEvent extends ProtobufSyncEvent {
  final ProtobufSyncProgress progress;

  const _UpdateProgressEvent(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Внутреннее событие для завершения синхронизации
class _SyncCompletedEvent extends ProtobufSyncEvent {
  final ProtobufSyncResult result;

  const _SyncCompletedEvent(this.result);

  @override
  List<Object?> get props => [result];
}

/// Очистить состояние и вернуться к начальному
class ResetProtobufSyncEvent extends ProtobufSyncEvent {
  const ResetProtobufSyncEvent();
}