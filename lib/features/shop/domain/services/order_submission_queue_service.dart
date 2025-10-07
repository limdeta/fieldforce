import 'dart:async';
import 'dart:math' as math;

import 'package:fieldforce/app/jobs/job_queue_repository.dart';
import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/app/jobs/job_record.dart';
import 'package:fieldforce/app/jobs/job_status.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_service.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

class OrderSubmissionQueueService implements JobQueueService<OrderSubmissionJob> {
  OrderSubmissionQueueService({
    required JobQueueRepository<OrderSubmissionJob> repository,
    required OrderRepository orderRepository,
    required OrderSubmissionService submissionService,
    Duration Function(int attempts)? retryDelayBuilder,
    int maxAttempts = 3,
  })  : _repository = repository,
        _orderRepository = orderRepository,
        _submissionService = submissionService,
        _retryDelayBuilder = retryDelayBuilder ?? _defaultRetryDelay,
        _maxAttempts = math.max(1, maxAttempts);

  static final Logger _logger = Logger('OrderSubmissionQueueService');

  final JobQueueRepository<OrderSubmissionJob> _repository;
  final OrderRepository _orderRepository;
  final OrderSubmissionService _submissionService;
  final Duration Function(int attempts) _retryDelayBuilder;
  final int _maxAttempts;

  bool _isProcessing = false;

  static Duration _defaultRetryDelay(int attempts) {
    final clamped = math.max(1, math.min(attempts, 6));
    return Duration(minutes: 5 * clamped);
  }

  @override
  Future<JobRecord<OrderSubmissionJob>> enqueue(OrderSubmissionJob job, {DateTime? runAt}) async {
    final now = DateTime.now();
    final record = JobRecord<OrderSubmissionJob>(
      job: job,
      status: JobStatus.queued,
      attempts: 0,
      createdAt: now,
      updatedAt: now,
      nextRunAt: runAt,
    );

    final saved = await _repository.save(record);
    unawaited(triggerProcessing());
    return saved;
  }

  @override
  Future<void> triggerProcessing() async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;
    try {
      while (true) {
        final record = await _repository.dequeueDueJob(now: DateTime.now());
        if (record == null) {
          break;
        }

        await _process(record);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _process(JobRecord<OrderSubmissionJob> record) async {
    final job = record.job;

    final order = await _orderRepository.getOrderById(job.orderId);
    if (order == null) {
      _logger.warning('Order ${job.orderId} not found. Marking job ${job.id} as failed');
      await _repository.updateStatus(
        job.id,
        JobStatus.failed,
        attempts: record.attempts,
        failureReason: 'Order not found',
      );
      await _repository.delete(job.id);
      return;
    }

    final submissionResult = await _submissionService.submit(order);

    await submissionResult.fold(
      (failure) async {
        await _handleFailure(record, order, failure);
      },
      (updatedOrder) async {
        await _handleUpdatedOrder(record, updatedOrder);
      },
    );
  }

  Future<void> _handleFailure(
    JobRecord<OrderSubmissionJob> record,
    Order order,
    Failure failure,
  ) async {
    final attempts = record.attempts;
    final reachedLimit = attempts >= _maxAttempts;

    if (reachedLimit) {
      _logger.severe(
        'Job ${record.job.id} reached max attempts ($_maxAttempts). Marking order ${order.id} as error.',
        failure,
      );
      final errorOrder = order.markAsError(reason: failure.message);
      await _orderRepository.saveOrder(errorOrder);

      await _repository.updateStatus(
        record.job.id,
        JobStatus.failed,
        attempts: attempts,
        failureReason: failure.message,
      );
      return;
    }

    _logger.warning(
      'Job ${record.job.id} failed on attempt $attempts/${_maxAttempts}: ${failure.message}. Scheduling retry.',
      failure,
    );

    final nextRunAt = DateTime.now().add(_retryDelayBuilder(attempts));
    await _repository.updateStatus(
      record.job.id,
      JobStatus.retryScheduled,
      attempts: attempts,
      nextRunAt: nextRunAt,
      failureReason: failure.message,
    );
  }

  Future<void> _handleUpdatedOrder(
    JobRecord<OrderSubmissionJob> record,
    Order updatedOrder,
  ) async {
    await _orderRepository.saveOrder(updatedOrder);

    switch (updatedOrder.state) {
      case OrderState.confirmed:
        _logger.info('Order ${updatedOrder.id} confirmed. Completing job ${record.job.id}');
        await _repository.updateStatus(
          record.job.id,
          JobStatus.succeeded,
          attempts: record.attempts,
        );
        await _repository.delete(record.job.id);
        break;
      case OrderState.pending:
        _logger.info('Order ${updatedOrder.id} still pending. Scheduling retry for job ${record.job.id}');
        final nextRunAt = DateTime.now().add(_retryDelayBuilder(record.attempts));
        await _repository.updateStatus(
          record.job.id,
          JobStatus.retryScheduled,
          attempts: record.attempts,
          nextRunAt: nextRunAt,
        );
        break;
      case OrderState.error:
        _logger.warning('Order ${updatedOrder.id} in error state. Marking job ${record.job.id} failed');
        await _repository.updateStatus(
          record.job.id,
          JobStatus.failed,
          attempts: record.attempts,
          failureReason: updatedOrder.failureReason,
        );
        break;
      default:
        _logger.warning('Unexpected order state ${updatedOrder.state} for order ${updatedOrder.id}. Marking job failed');
        await _repository.updateStatus(
          record.job.id,
          JobStatus.failed,
          attempts: record.attempts,
          failureReason: 'Unexpected order state ${updatedOrder.state}',
        );
        break;
    }
  }
}
