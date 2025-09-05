enum TrackStatus {
  active,
  paused,
  completed,
  cancelled;

  // TODO А может ли у трека вообще быть статус или это тупое хранилище?
  String get displayName {
    switch (this) {
      case TrackStatus.active:
        return 'Активен';
      case TrackStatus.paused:
        return 'Приостановлен';
      case TrackStatus.completed:
        return 'Завершен';
      case TrackStatus.cancelled:
        return 'Отменен';
    }
  }

  bool get isActive => this == TrackStatus.active;
  bool get isCompleted => this == TrackStatus.completed || this == TrackStatus.cancelled;
}
