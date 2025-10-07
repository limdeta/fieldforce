import 'package:equatable/equatable.dart';

import 'job.dart';
import 'job_status.dart';

class JobRecord<J extends Job> extends Equatable {
  final J job;
  final JobStatus status;
  final int attempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextRunAt;
  final String? failureReason;

  const JobRecord({
    required this.job,
    required this.status,
    required this.attempts,
    required this.createdAt,
    required this.updatedAt,
    this.nextRunAt,
    this.failureReason,
  });

  JobRecord<J> copyWith({
    JobStatus? status,
    int? attempts,
    DateTime? updatedAt,
    DateTime? nextRunAt,
    String? failureReason,
  }) {
    return JobRecord<J>(
      job: job,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  List<Object?> get props => [
        job,
        status,
        attempts,
        createdAt,
        updatedAt,
        nextRunAt,
        failureReason,
      ];
}
