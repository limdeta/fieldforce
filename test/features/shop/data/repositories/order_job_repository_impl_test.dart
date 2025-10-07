import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/jobs/job_record.dart';
import 'package:fieldforce/app/jobs/job_status.dart';
import 'package:fieldforce/features/shop/data/repositories/order_job_repository_impl.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderJobRepositoryImpl', () {
    late AppDatabase database;
    late OrderJobRepositoryImpl repository;

    setUp(() {
      database = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      repository = OrderJobRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and retrieves job records', () async {
      final orderId = await _prepareOrder(database);
      final job = OrderSubmissionJob.create(
        id: 'job-1',
        orderId: orderId,
        payload: {'orderId': orderId},
      );

      final record = JobRecord<OrderSubmissionJob>(
        job: job,
        status: JobStatus.queued,
        attempts: 0,
        createdAt: job.createdAt,
        updatedAt: job.createdAt,
      );

      await repository.save(record);

      final stored = await repository.findById(job.id);
      expect(stored, isNotNull);
      expect(stored!.job.orderId, orderId);
      expect(stored.status, JobStatus.queued);
      expect(stored.attempts, 0);
    });

    test('dequeues due jobs and marks them running', () async {
      final orderId = await _prepareOrder(database);
      final job = OrderSubmissionJob.create(
        id: 'job-2',
        orderId: orderId,
        payload: {'orderId': orderId},
      );
      final record = JobRecord<OrderSubmissionJob>(
        job: job,
        status: JobStatus.queued,
        attempts: 0,
        createdAt: job.createdAt,
        updatedAt: job.createdAt,
      );
      await repository.save(record);

      final dequeued = await repository.dequeueDueJob(now: job.createdAt.add(const Duration(seconds: 1)));
      expect(dequeued, isNotNull);
      expect(dequeued!.status, JobStatus.running);
      expect(dequeued.attempts, 1);
    });

    test('reschedules job on updateStatus', () async {
      final orderId = await _prepareOrder(database);
      final job = OrderSubmissionJob.create(
        id: 'job-3',
        orderId: orderId,
        payload: {'orderId': orderId},
      );
      final initial = JobRecord<OrderSubmissionJob>(
        job: job,
        status: JobStatus.queued,
        attempts: 0,
        createdAt: job.createdAt,
        updatedAt: job.createdAt,
      );
      await repository.save(initial);

      final scheduledFor = job.createdAt.add(const Duration(minutes: 5));
      final updated = await repository.updateStatus(
        job.id,
        JobStatus.retryScheduled,
        attempts: 2,
        nextRunAt: scheduledFor,
        failureReason: 'network timeout',
      );

      expect(updated.status, JobStatus.retryScheduled);
      expect(updated.attempts, 2);
      expect(updated.nextRunAt, isNotNull);
      expect(
        updated.nextRunAt!.difference(scheduledFor).inMilliseconds.abs(),
        lessThan(1000),
      );
      expect(updated.failureReason, 'network timeout');

      final notDue = await repository.dequeueDueJob(now: job.createdAt.add(const Duration(minutes: 1)));
      expect(notDue, isNull);

      final due = await repository.dequeueDueJob(now: scheduledFor.add(const Duration(seconds: 1)));
      expect(due, isNotNull);
      expect(due!.status, JobStatus.running);
      expect(due.attempts, 3);
    });
  });
}

Future<int> _prepareOrder(AppDatabase database) async {
  final employeeId = await database.into(database.employees).insert(
        EmployeesCompanion.insert(
          lastName: 'Иванов',
          firstName: 'Иван',
          role: 'sales',
        ),
      );

  final tradingPointId = await database.into(database.tradingPointEntities).insert(
        TradingPointEntitiesCompanion.insert(
          externalId: 'TP-$employeeId',
          name: 'Тестовая ТТ',
        ),
      );

  final now = DateTime.now();
  final orderId = await database.into(database.orders).insert(
        OrdersCompanion.insert(
          creatorId: employeeId,
          outletId: tradingPointId,
          state: 'draft',
          paymentType: const Value('cash'),
          paymentDetails: const Value(''),
          paymentIsCash: const Value(true),
          paymentIsCard: const Value(false),
          paymentIsCredit: const Value(false),
          comment: const Value(null),
          name: const Value(''),
          isPickup: const Value(true),
          approvedDeliveryDay: const Value(null),
          approvedAssemblyDay: const Value(null),
          withRealization: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

  return orderId;
}
