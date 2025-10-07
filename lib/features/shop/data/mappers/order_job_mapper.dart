import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/jobs/job_record.dart';
import 'package:fieldforce/app/jobs/job_status.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';

class OrderJobMapper {
  const OrderJobMapper();

  JobRecord<OrderSubmissionJob> fromEntity(OrderJobEntity entity) {
    final job = OrderSubmissionJob(
      id: entity.id,
      orderId: entity.orderId,
      payload: _decodePayload(entity.payloadJson),
      createdAt: entity.createdAt,
    );

    final status = JobStatus.values.firstWhere(
      (state) => state.name == entity.status,
      orElse: () => JobStatus.queued,
    );

    return JobRecord<OrderSubmissionJob>(
      job: job,
      status: status,
      attempts: entity.attempts,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nextRunAt: entity.nextRunAt,
      failureReason: entity.failureReason,
    );
  }

  OrderJobsCompanion toCompanion(JobRecord<OrderSubmissionJob> record) {
    return OrderJobsCompanion(
      id: Value(record.job.id),
      orderId: Value(record.job.orderId),
      jobType: Value(record.job.type),
      payloadJson: Value(jsonEncode(record.job.payload)),
      status: Value(record.status.name),
      attempts: Value(record.attempts),
      nextRunAt: record.nextRunAt != null
          ? Value(record.nextRunAt)
          : const Value.absent(),
      failureReason: record.failureReason != null
          ? Value(record.failureReason)
          : const Value.absent(),
      createdAt: Value(record.createdAt),
      updatedAt: Value(record.updatedAt),
    );
  }

  Map<String, dynamic> _decodePayload(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }
}
