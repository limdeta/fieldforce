// lib/features/shop/domain/usecases/update_cart_usecase.dart

import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';


/// Параметры для обновления корзины
class UpdateCartParams {
  final int? orderLineId;
  final int? newQuantity;
  final PaymentKind? paymentKind;
  final bool? isPickup;
  final DateTime? approvedDeliveryDay;
  final DateTime? approvedAssemblyDay;
  final String? comment;
  final int? outletId;

  const UpdateCartParams({
    this.orderLineId,
    this.newQuantity,
    this.paymentKind,
    this.isPickup,
    this.approvedDeliveryDay,
    this.approvedAssemblyDay,
    this.comment,
    this.outletId,
  });
}

/// Use case для обновления корзины (изменение количества товаров, параметров заказа)
class UpdateCartUseCase {
  static final Logger _logger = Logger('UpdateCartUseCase');
  
  final OrderRepository _orderRepository;
  final StockItemRepository _stockItemRepository;

  const UpdateCartUseCase(
    this._orderRepository,
    this._stockItemRepository,
  );

  Future<Either<Failure, Order>> call(UpdateCartParams params) async {
    try {
      _logger.info('Обновление корзины с параметрами: orderLineId=${params.orderLineId}, newQuantity=${params.newQuantity}');

      // Обработка обновления количества в строке заказа
      if (params.orderLineId != null && params.newQuantity != null) {
        return await updateQuantity(
          orderLineId: params.orderLineId!,
          newQuantity: params.newQuantity!,
        );
      }

      // TODO: Реализовать обновление других параметров заказа
      // (paymentKind, isPickup, deliveryDay, etc.)
      
      return const Left(ValidationFailure('Не указаны обязательные параметры для обновления корзины'));
    } catch (e, stackTrace) {
      _logger.severe('Ошибка обновления корзины', e, stackTrace);
      return Left(NetworkFailure('Ошибка обновления корзины: $e'));
    }
  }

  /// Добавляет товар в корзину или обновляет количество
  Future<Either<Failure, Order>> addToCart({
    required int stockItemId,
    required int quantity,
  }) async {
    try {
      _logger.info('Добавление в корзину: stockItemId=$stockItemId, quantity=$quantity');

      // Получаем текущую сессию
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold(
        (failure) => throw Exception('Нет активной сессии: $failure'),
        (session) => session,
      );

      if (session == null) {
        return const Left(NotFoundFailure('Активная сессия не найдена'));
      }

      if (!session.appUser.hasSelectedTradingPoint) {
        return const Left(ValidationFailure('Выберите торговую точку'));
      }

      final employeeId = session.appUser.employee.id;
      final outletId = session.appUser.selectedTradingPointId!;

      final currentCart = await _orderRepository.getCurrentDraftOrder(
        employeeId,
        outletId,
      );

      // Получаем информацию о товаре
      final stockItemResult = await _stockItemRepository.getById(stockItemId);
      final stockItem = stockItemResult.fold(
        (failure) => throw Exception('Товар не найден: $failure'),
        (item) => item,
      );

      // Проверяем, есть ли уже этот товар в корзине
      OrderLine? existingLine;
      try {
        existingLine = currentCart.lines.firstWhere(
          (line) => line.stockItem.id == stockItemId,
        );
      } catch (e) {
        existingLine = null;
      }

      if (existingLine != null) {
        return await updateQuantity(
          orderLineId: existingLine.id!,
          newQuantity: quantity,
        );
      } else {
        final orderLine = OrderLine.create(
          orderId: currentCart.id!,
          stockItem: stockItem,
          quantity: quantity,
        );

        final result = await _orderRepository.addOrderLine(orderLine);
        return Right(result);
      }
    } catch (e, stackTrace) {
      _logger.severe('Ошибка добавления в корзину', e, stackTrace);
      return Left(DatabaseFailure('Ошибка добавления в корзину: $e'));
    }
  }

  Future<Either<Failure, Order>> updateQuantity({
    required int orderLineId,
    required int newQuantity,
  }) async {
    try {
      _logger.info('Обновление количества: orderLineId=$orderLineId, newQuantity=$newQuantity');

      if (newQuantity <= 0) {
        _logger.info('Количество <= 0, удаляем товар из корзины');
        return await removeFromCart(orderLineId: orderLineId);
      }

      _logger.info('Вызываем репозиторий для обновления количества');
      final result = await _orderRepository.updateOrderLineQuantity(
        orderLineId: orderLineId,
        newQuantity: newQuantity,
      );
      _logger.info('Количество успешно обновлено');
      return Right(result);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка обновления количества', e, stackTrace);
      return Left(DatabaseFailure('Ошибка обновления количества: $e'));
    }
  }

  Future<Either<Failure, Order>> removeFromCart({
    required int orderLineId,
  }) async {
    try {
      _logger.info('Удаление из корзины: orderLineId=$orderLineId');

      final result = await _orderRepository.removeOrderLine(orderLineId);
      return Right(result);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка удаления из корзины', e, stackTrace);
      return Left(DatabaseFailure('Ошибка удаления из корзины: $e'));
    }
  }

  Future<Either<Failure, Order>> clearCart() async {
    try {
      _logger.info('Очистка корзины');

      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold(
        (failure) => throw Exception('Нет активной сессии: $failure'),
        (session) => session,
      );

      if (session == null) {
        return const Left(NotFoundFailure('Активная сессия не найдена'));
      }

      if (!session.appUser.hasSelectedTradingPoint) {
        return const Left(ValidationFailure('Выберите торговую точку'));
      }

      final employeeId = session.appUser.employee.id;
      final outletId = session.appUser.selectedTradingPointId!;

      final result = await _orderRepository.clearCart(
        employeeId: employeeId,
        outletId: outletId,
      );
      return Right(result);
    } catch (e, stackTrace) {
      _logger.severe('Ошибка очистки корзины', e, stackTrace);
      return Left(DatabaseFailure('Ошибка очистки корзины: $e'));
    }
  }
}