import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/database.dart';
import 'package:fieldforce/app/jobs/job_queue_repository.dart';
import 'package:fieldforce/app/jobs/job_record.dart';
import 'package:fieldforce/app/jobs/job_status.dart';
import 'package:fieldforce/features/shop/data/mappers/order_job_mapper.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:logging/logging.dart';

class OrderJobRepositoryImpl implements JobQueueRepository<OrderSubmissionJob> {
  static final Logger _logger = Logger('OrderJobRepositoryImpl');

  final AppDatabase _database;
  final OrderJobMapper _mapper;

  OrderJobRepositoryImpl(this._database, {OrderJobMapper? mapper})
      : _mapper = mapper ?? const OrderJobMapper();

  @override
  Future<JobRecord<OrderSubmissionJob>> save(JobRecord<OrderSubmissionJob> record) async {
    final companion = _mapper.toCompanion(record);
    await _database.into(_database.orderJobs).insertOnConflictUpdate(companion);
    return (await findById(record.job.id))!;
  }

  @override
  Future<JobRecord<OrderSubmissionJob>?> findById(String id) async {
    final query = _database.select(_database.orderJobs)
      ..where((row) => row.id.equals(id));
    final entity = await query.getSingleOrNull();
    if (entity == null) {
      return null;
    }
    return _mapper.fromEntity(entity);
  }

  @override
  Future<JobRecord<OrderSubmissionJob>?> dequeueDueJob({DateTime? now}) async {
    final nowTs = now ?? DateTime.now();

    return await _database.transaction(() async {
      final candidates = _database.select(_database.orderJobs)
        ..where((row) => row.status.isIn([
              JobStatus.queued.name,
              JobStatus.retryScheduled.name,
            ]))
        ..where((row) => row.nextRunAt.isNull() | row.nextRunAt.isSmallerOrEqualValue(nowTs))
        ..orderBy([
          (tbl) => OrderingTerm(expression: tbl.nextRunAt, mode: OrderingMode.asc),
          (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc),
        ])
        ..limit(1);

      final entity = await candidates.getSingleOrNull();
      if (entity == null) {
        return null;
      }

      final updatedCompanion = OrderJobsCompanion(
        status: Value(JobStatus.running.name),
        attempts: Value(entity.attempts + 1),
        updatedAt: Value(nowTs),
        nextRunAt: const Value(null),
        failureReason: const Value(null),
      );

      await (_database.update(_database.orderJobs)
            ..where((tbl) => tbl.id.equals(entity.id)))
          .write(updatedCompanion);

      final refreshed = await (_database.select(_database.orderJobs)
            ..where((tbl) => tbl.id.equals(entity.id)))
          .getSingle();

      _logger.fine('Dequeued job ${entity.id} for order ${entity.orderId}');
      return _mapper.fromEntity(refreshed);
    });
  }

  @override
  Future<JobRecord<OrderSubmissionJob>> updateStatus(
    String id,
    JobStatus status, {
    int? attempts,
    DateTime? nextRunAt,
    String? failureReason,
  }) async {
    final now = DateTime.now();
    final updateCompanion = OrderJobsCompanion(
      status: Value(status.name),
      attempts: attempts != null ? Value(attempts) : const Value.absent(),
      nextRunAt: Value(nextRunAt),
      failureReason: Value(failureReason),
      updatedAt: Value(now),
    );

    await (_database.update(_database.orderJobs)
          ..where((tbl) => tbl.id.equals(id)))
        .write(updateCompanion);

    final refreshed = await (_database.select(_database.orderJobs)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

    return _mapper.fromEntity(refreshed);
  }

  @override
  Future<List<JobRecord<OrderSubmissionJob>>> list({JobStatus? status, int limit = 50}) async {
    final query = _database.select(_database.orderJobs)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc)])
      ..limit(limit);

    if (status != null) {
      query.where((tbl) => tbl.status.equals(status.name));
    }

    final entities = await query.get();
    return entities.map((entity) => _mapper.fromEntity(entity)).toList();
  }

  @override
  Future<void> delete(String id) async {
    await (_database.delete(_database.orderJobs)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}
