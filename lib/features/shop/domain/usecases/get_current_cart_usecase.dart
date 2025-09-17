// lib/features/shop/domain/usecases/get_current_cart_usecase.dart

import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/repositories/order_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

import '../../../../app/services/app_session_service.dart';

/// Use case для получения текущей корзины (draft заказ пользователя)
/// Использует AppSession для получения информации о текущем пользователе и корзине
class GetCurrentCartUseCase {
  static final Logger _logger = Logger('GetCurrentCartUseCase');
  final OrderRepository _orderRepository;

  const GetCurrentCartUseCase(this._orderRepository);

  Future<Either<Failure, Order>> call() async {
    try {
      _logger.info('🛒 Начинаем получение текущей корзины');
      
      // Получаем текущую сессию
      final sessionResult = await AppSessionService.getCurrentAppSession();
      _logger.info('📱 Результат получения сессии получен');
      
      return sessionResult.fold(
        (failure) {
          _logger.warning('❌ Ошибка получения сессии: ${failure.message}');
          return Left(failure);
        },
        (session) async {
          if (session == null || !session.isAuthenticated) {
            _logger.warning('❌ Пользователь не авторизован');
            return Left(AuthFailure('Пользователь не авторизован'));
          }
          
          _logger.info('✅ Сессия получена, пользователь: ${session.appUser.employee.id}');
          
          // Получаем ID сотрудника из app user
          final employeeId = session.appUser.employee.id;
          
          // Получаем outletId из выбранной торговой точки пользователя
          final outletId = session.currentOutletId;
          if (outletId == null) {
            _logger.severe('❌ КРИТИЧЕСКАЯ ОШИБКА: У пользователя не выбрана торговая точка. selectedTradingPoint: ${session.appUser.selectedTradingPoint}');
            return Left(ValidationFailure('КРИТИЧЕСКАЯ ОШИБКА: Не выбрана торговая точка. Приложение не может работать без выбранной торговой точки. Обратитесь к администратору.'));
          }
          
          _logger.info('📍 Используем торговую точку: $outletId (${session.appUser.selectedTradingPoint?.name ?? "неизвестная"})');
          
          _logger.info('🔍 Получаем draft заказ для employeeId=$employeeId, outletId=$outletId');
          
          // Создаем или получаем draft заказ
          final draftOrder = await _orderRepository.getCurrentDraftOrder(
            employeeId,
            outletId,
          );
          
          _logger.info('✅ Draft заказ получен: id=${draftOrder.id}, статус=${draftOrder.state}, строк=${draftOrder.lines.length}');
          
          return Right(draftOrder);
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('💥 Неожиданная ошибка получения корзины', e, stackTrace);
      
      // Различные типы ошибок для лучшей диагностики
      String errorMessage;
      if (e.toString().contains('No element')) {
        errorMessage = 'Не найдены данные пользователя или торговой точки. Проверьте фикстуры Employee и TradingPoint.';
      } else if (e.toString().contains('StateError')) {
        errorMessage = 'Проблема с состоянием базы данных: $e';
      } else {
        errorMessage = 'Ошибка получения корзины: $e';
      }
      
      return Left(NetworkFailure(errorMessage));
    }
  }
}