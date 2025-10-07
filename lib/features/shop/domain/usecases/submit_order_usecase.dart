// lib/features/shop/domain/usecases/submit_order_usecase.dart

import 'dart:math' as math;

import 'package:fieldforce/app/jobs/job_queue_service.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

import '../../../../app/services/app_session_service.dart';

class SubmitOrderParams {
  final bool withoutRealization;
  final bool toReview;

  const SubmitOrderParams({
    this.withoutRealization = false,
    this.toReview = false,
  });
}

class SubmitOrderResult {
  final Order submittedOrder;
  final Order newCart;

  const SubmitOrderResult({
    required this.submittedOrder,
    required this.newCart,
  });
}

/// Use case для отправки заказа
class SubmitOrderUseCase {
  static final Logger _logger = Logger('SubmitOrderUseCase');

  final OrderRepository _orderRepository;
  final JobQueueService<OrderSubmissionJob> _queueService;

  const SubmitOrderUseCase({
    required OrderRepository orderRepository,
    required JobQueueService<OrderSubmissionJob> queueService,
  })  : _orderRepository = orderRepository,
        _queueService = queueService;

  Future<Either<Failure, SubmitOrderResult>> call(SubmitOrderParams params) async {
    try {
      _logger.info('Submitting current cart (withoutRealization=${params.withoutRealization}, toReview=${params.toReview})');

      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold((failure) {
        _logger.severe('Failed to get current session: ${failure.message}');
        return null;
      }, (value) => value);

      if (session == null || !session.isAuthenticated) {
        return const Left(AuthFailure('Пользователь не авторизован'));
      }

      final outletId = session.currentOutletId;
      if (outletId == null) {
        return const Left(ValidationFailure('Не выбрана торговая точка'));
      }

      final employeeId = session.appUser.employee.id;
      var order = await _orderRepository.getCurrentDraftOrder(employeeId, outletId);

      if (!order.canSubmit) {
        return const Left(ValidationFailure('Для отправки заказа заполните корзину и способ оплаты'));
      }

      order = order.copyWith(withRealization: !params.withoutRealization);

      final pendingOrder = order.submit();
      final savedOrder = await _orderRepository.saveOrder(pendingOrder);

      final job = OrderSubmissionJob.create(
        id: _generateJobId(savedOrder.id!),
        orderId: savedOrder.id!,
        payload: savedOrder.toApiPayload(),
      );

      await _queueService.enqueue(job);

      final newCart = await _orderRepository.getCurrentDraftOrder(employeeId, outletId);

      return Right(SubmitOrderResult(
        submittedOrder: savedOrder,
        newCart: newCart,
      ));
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error while submitting order', e, stackTrace);
      return Left(NetworkFailure('Ошибка отправки заказа: $e'));
    }
  }

  String _generateJobId(int orderId) {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final random = math.Random().nextInt(0xFFFFFF);
    return 'order-$orderId-${suffix.toRadixString(16)}-${random.toRadixString(16)}';
  }
}