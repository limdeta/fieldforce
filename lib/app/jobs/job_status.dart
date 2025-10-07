enum JobStatus {
  queued,
  running,
  retryScheduled,
  succeeded,
  failed,
  cancelled,
}

extension JobStatusX on JobStatus {
  bool get isTerminal => switch (this) {
        JobStatus.succeeded || JobStatus.failed || JobStatus.cancelled => true,
        _ => false,
      };

  bool get canRetry => switch (this) {
        JobStatus.queued || JobStatus.retryScheduled => true,
        _ => false,
      };
}
