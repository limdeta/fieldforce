import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Домашний сервис, отвечающий за отправку заказов во внешнее API.
///
/// Он переводит заказ в состояние `pending`, инициирует сетевой вызов и
/// возвращает обновлённый экземпляр заказа согласно результату операции.
class OrderSubmissionService {
  static final Logger _logger = Logger('OrderSubmissionService');

  final OrderApiService _apiService;

  const OrderSubmissionService({required OrderApiService apiService})
      : _apiService = apiService;

  /// Пытается отправить заказ во внешнюю систему.
  ///
  /// Возвращает `Right(Order)` с обновлённым состоянием заказа или `Left(Failure)`.
  /// - При успехе заказ переводится в `confirmed`.
  /// - При сетевых и прочих инфраструктурных ошибках возвращается `Left`, заказ
  ///   остаётся в состоянии `pending`, а повторные попытки организует очередь.
  /// - При бизнес-ошибке (ответ API) также возвращается `Left`: после нескольких
  ///   неудачных повторов очередь переведёт заказ в `error` и зафиксирует причину.
  ///
  /// Валидационные ошибки (например, пустая корзина) также возвращаются через `Left`.
  Future<Either<Failure, Order>> submit(Order order) async {
    Order pendingOrder;
    if (order.state == OrderState.draft) {
      if (!order.canSubmit) {
        return const Left(ValidationFailure('Заказ нельзя отправить: заполните корзину и способ оплаты'));
      }
      pendingOrder = order.submit();
    } else if (order.state == OrderState.pending) {
      pendingOrder = order;
    } else {
      return Left(ValidationFailure('Заказ в состоянии ${order.state} нельзя отправить'));
    }

    final payload = pendingOrder.toApiPayload();

    final result = await _apiService.submitOrder(payload);

    return result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          _logger.warning('OrderSubmissionService: сеть недоступна, повторим позже (${failure.message})', failure);
        } else {
          _logger.severe('OrderSubmissionService: ошибка отправки заказа: ${failure.message}', failure);
        }
        return Left(failure);
      },
      (_) {
        final confirmedOrder = pendingOrder.confirm();
        _logger.info('OrderSubmissionService: заказ успешно подтверждён');
        return Right(confirmedOrder);
      },
    );
  }
}
