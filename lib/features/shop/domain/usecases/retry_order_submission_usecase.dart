import 'dart:math' as math;

import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

class RetryOrderSubmissionParams {
  final int orderId;

  const RetryOrderSubmissionParams({required this.orderId});
}

class RetryOrderSubmissionUseCase {
  static final Logger _logger = Logger('RetryOrderSubmissionUseCase');

  final OrderRepository _orderRepository;
  final JobQueueService<OrderSubmissionJob> _queueService;

  const RetryOrderSubmissionUseCase({
    required OrderRepository orderRepository,
    required JobQueueService<OrderSubmissionJob> queueService,
  })  : _orderRepository = orderRepository,
        _queueService = queueService;

  Future<Either<Failure, Order>> call(RetryOrderSubmissionParams params) async {
    try {
      final order = await _orderRepository.getOrderById(params.orderId);
      if (order == null) {
        return const Left(NotFoundFailure('Заказ не найден'));
      }

      if (order.state != OrderState.error && order.state != OrderState.pending) {
        return const Left(
          ValidationFailure('Повторная отправка доступна только для заказов в ошибке или ожидании'),
        );
      }

      final pendingOrder = order.state == OrderState.pending
          ? order.copyWith(failureReason: null, updatedAt: DateTime.now())
          : order.updateState(OrderState.pending);

      final savedOrder = await _orderRepository.saveOrder(pendingOrder);

      final job = OrderSubmissionJob.create(
        id: _generateJobId(savedOrder.id!),
        orderId: savedOrder.id!,
        payload: savedOrder.toApiPayload(),
      );

      await _queueService.enqueue(job);

      return Right(savedOrder);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка при повторной отправке заказа ${params.orderId}', e, stackTrace);
      return Left(GeneralFailure('Не удалось повторно отправить заказ: $e'));
    }
  }

  String _generateJobId(int orderId) {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final random = math.Random().nextInt(0xFFFFFF);
    return 'order-$orderId-retry-${suffix.toRadixString(16)}-${random.toRadixString(16)}';
  }
}
