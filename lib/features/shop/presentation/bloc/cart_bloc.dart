// lib/features/shop/presentation/bloc/cart_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/usecases/submit_order_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../../../../app/services/app_session_service.dart';
import '../../../../shared/services/image_cache_service.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_current_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_item_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_stock_item_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/remove_from_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/update_cart_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/clear_cart_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

/// BLoC для управления корзиной (текущий draft заказ)
/// TODO Вынести в app всё что касается сессии из app
class CartBloc extends Bloc<CartEvent, CartState> {
  static final Logger _logger = Logger('CartBloc');

  final GetCurrentCartUseCase _getCurrentCartUseCase;
  final UpdateCartItemUseCase _updateCartItemUseCase;
  final UpdateCartStockItemUseCase _updateCartStockItemUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final UpdateCartUseCase _updateCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final SubmitOrderUseCase _submitOrderUseCase;

  CartBloc({
    required GetCurrentCartUseCase getCurrentCartUseCase,
    required UpdateCartItemUseCase updateCartItemUseCase,
    required UpdateCartStockItemUseCase updateCartStockItemUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required UpdateCartUseCase updateCartUseCase,
    required ClearCartUseCase clearCartUseCase,
    required SubmitOrderUseCase submitOrderUseCase,
  })  : _getCurrentCartUseCase = getCurrentCartUseCase,
        _updateCartItemUseCase = updateCartItemUseCase,
        _updateCartStockItemUseCase = updateCartStockItemUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _updateCartUseCase = updateCartUseCase,
        _clearCartUseCase = clearCartUseCase,
        _submitOrderUseCase = submitOrderUseCase,
        super(const CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<AddStockItemToCartEvent>(_onAddStockItemToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartLineEvent>(_onUpdateCartLine);
    on<ClearCartEvent>(_onClearCart);
    on<UpdateCartDetailsEvent>(_onUpdateCartDetails);
    on<SubmitCartEvent>(_onSubmitCart);
    on<SendCartToReviewEvent>(_onSendCartToReview);
  }

  /// Загрузить текущую корзину (аналог getCurrentOrder)
  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    try {
      emit(const CartLoading());
      _logger.info('Загружаем текущую корзину');

      final result = await _getCurrentCartUseCase();
      
      result.fold(
        (failure) {
          _logger.warning('Ошибка загрузки корзины: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (cart) {
          _logger.info('Корзина загружена, ID: ${cart.id}, статус: ${cart.state}');
          
          if (cart.lines.isEmpty) {
            emit(CartEmpty(cart: cart));
          } else {
            final totalAmount = _calculateTotalAmount(cart.lines);
            final totalItems = _calculateTotalItems(cart.lines);
            
            // Предзагрузка миниатюр продуктов в корзине для лучшего UX
            _precacheCartImages(cart.lines);
            
            emit(CartLoaded(
              cart: cart,
              orderLines: cart.lines,
              totalAmount: totalAmount,
              totalItems: totalItems,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка загрузки корзины', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Добавить товар в корзину (аналог putLinesToCurrentOrder)
  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('🛒 [CartBloc] Получено событие AddToCartEvent: productCode=${event.productCode}, quantity=${event.quantity}, warehouseId=${event.warehouseId}');
      _logger.info('🛒 [CartBloc] Текущее состояние: ${state.runtimeType}');

      // Получаем данные из сессии
      _logger.info('🛒 [CartBloc] Получаем текущую сессию...');
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold(
        (failure) {
          _logger.severe('🛒 [CartBloc] ❌ Ошибка получения сессии: ${failure.message}');
          emit(CartError(message: 'Ошибка получения сессии: ${failure.message}'));
          return null;
        },
        (s) {
          _logger.info('🛒 [CartBloc] ✅ Сессия получена: ${s?.appUser.fullName}');
          return s;
        },
      );

      if (session == null) {
        _logger.severe('🛒 [CartBloc] ❌ Сессия равна null');
        emit(CartError(message: 'Нет активной сессии пользователя'));
        return;
      }

      _logger.info('🏪 CurrentOutletId: ${session.currentOutletId}, selectedTradingPointId: ${session.appUser.selectedTradingPointId}');
      
      final outletId = session.currentOutletId;
      if (outletId == null) {
        _logger.severe('❌ КРИТИЧЕСКАЯ ОШИБКА: Торговая точка не выбрана! AppUser.selectedTradingPoint: ${session.appUser.selectedTradingPoint}');
        emit(CartError(message: 'КРИТИЧЕСКАЯ ОШИБКА: Торговая точка не выбрана. Приложение не может работать без выбранной торговой точки. Обратитесь к администратору.'));
        return;
      }
      
      _logger.info('🛒 [CartBloc] Вызываем UpdateCartItemUseCase с параметрами: employeeId=${session.appUser.employee.id}, outletId=$outletId');
      final result = await _updateCartItemUseCase(UpdateCartItemParams(
        productCode: event.productCode,
        quantity: event.quantity,
        warehouseId: event.warehouseId,
        employeeId: session.appUser.employee.id,
        outletId: outletId,
      ));
      
      _logger.info('🛒 [CartBloc] Результат UpdateCartItemUseCase: ${result.isLeft() ? "ОШИБКА" : "УСПЕХ"}');

      result.fold(
        (failure) {
          _logger.severe('🛒 [CartBloc] ❌ Ошибка добавления товара: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (cart) {
          _logger.info('🛒 [CartBloc] ✅ Товар добавлен в корзину успешно!');
          
          if (cart.lines.isEmpty) {
            emit(CartEmpty(cart: cart));
          } else {
            final totalAmount = _calculateTotalAmount(cart.lines);
            final totalItems = _calculateTotalItems(cart.lines);
            
            emit(CartLoaded(
              cart: cart,
              orderLines: cart.lines,
              totalAmount: totalAmount,
              totalItems: totalItems,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка добавления товара', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Добавить конкретный StockItem в корзину
  Future<void> _onAddStockItemToCart(AddStockItemToCartEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('🛒 [CartBloc] Получено событие AddStockItemToCartEvent: stockItemId=${event.stockItemId}, quantity=${event.quantity}');
      _logger.info('🛒 [CartBloc] Текущее состояние: ${state.runtimeType}');

      // Получаем данные из сессии
      _logger.info('🛒 [CartBloc] Получаем текущую сессию...');
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold(
        (failure) {
          _logger.severe('🛒 [CartBloc] ❌ Ошибка получения сессии: ${failure.message}');
          emit(CartError(message: 'Ошибка получения сессии: ${failure.message}'));
          return null;
        },
        (s) {
          _logger.info('🛒 [CartBloc] ✅ Сессия получена: ${s?.appUser.fullName}');
          return s;
        },
      );

      if (session == null) {
        _logger.severe('🛒 [CartBloc] ❌ Сессия равна null');
        emit(CartError(message: 'Нет активной сессии пользователя'));
        return;
      }

      _logger.info('🏪 CurrentOutletId: ${session.currentOutletId}, selectedTradingPointId: ${session.appUser.selectedTradingPointId}');
      
      final outletId = session.currentOutletId;
      if (outletId == null) {
        _logger.severe('❌ КРИТИЧЕСКАЯ ОШИБКА: Торговая точка не выбрана! AppUser.selectedTradingPoint: ${session.appUser.selectedTradingPoint}');
        emit(CartError(message: 'КРИТИЧЕСКАЯ ОШИБКА: Торговая точка не выбрана. Приложение не может работать без выбранной торговой точки. Обратитесь к администратору.'));
        return;
      }
      
      _logger.info('🛒 [CartBloc] Вызываем UpdateCartStockItemUseCase с параметрами: employeeId=${session.appUser.employee.id}, outletId=$outletId');
      final result = await _updateCartStockItemUseCase(UpdateCartStockItemParams(
        employeeId: session.appUser.employee.id,
        outletId: outletId,
        stockItemId: event.stockItemId,
        quantity: event.quantity,
      ));
      
      _logger.info('🛒 [CartBloc] Результат UpdateCartStockItemUseCase: ${result.isLeft() ? "ОШИБКА" : "УСПЕХ"}');

      result.fold(
        (failure) {
          _logger.severe('🛒 [CartBloc] ❌ Ошибка добавления StockItem: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (cart) {
          _logger.info('🛒 [CartBloc] ✅ StockItem добавлен в корзину успешно!');
          
          if (cart.lines.isEmpty) {
            emit(CartEmpty(cart: cart));
          } else {
            final totalAmount = _calculateTotalAmount(cart.lines);
            final totalItems = _calculateTotalItems(cart.lines);
            
            emit(CartLoaded(
              cart: cart,
              orderLines: cart.lines,
              totalAmount: totalAmount,
              totalItems: totalItems,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка добавления StockItem', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Удалить строку из корзины (аналог deleteLineFromCurrentOrder)
  Future<void> _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('Удаляем строку из корзины: ${event.orderLineId}');
      
      // Проверим что такая OrderLine действительно существует в текущем состоянии
      if (state is CartLoaded) {
        final currentOrderLine = (state as CartLoaded).orderLines
            .where((line) => line.id == event.orderLineId)
            .firstOrNull;
        if (currentOrderLine == null) {
          _logger.warning('OrderLine ${event.orderLineId} не найдена в текущем состоянии корзины');
          emit(CartError(message: 'Товар уже удален из корзины'));
          return;
        }
        _logger.info('OrderLine найдена: ${currentOrderLine.productTitle} (кол-во: ${currentOrderLine.quantity})');
      }

      final result = await _removeFromCartUseCase(RemoveFromCartParams(
        orderLineId: event.orderLineId,
      ));

      await result.fold(
        (failure) async {
          _logger.warning('Ошибка удаления строки: ${failure.message}');
          if (!emit.isDone) {
            emit(CartError(message: failure.message));
          }
        },
        (_) async {
          _logger.info('Строка удалена из корзины, получаем обновленную корзину');
          
          // Загружаем обновленную корзину напрямую, без события
          final cartResult = await _getCurrentCartUseCase();
          if (!emit.isDone) {
            cartResult.fold(
              (failure) => emit(CartError(message: failure.message)),
              (cart) {
                if (cart.lines.isEmpty) {
                  emit(CartEmpty(cart: cart));
                } else {
                  final totalAmount = _calculateTotalAmount(cart.lines);
                  final totalItems = _calculateTotalItems(cart.lines);
                  
                  emit(CartLoaded(
                    cart: cart,
                    orderLines: cart.lines,
                    totalAmount: totalAmount,
                    totalItems: totalItems,
                  ));
                }
              },
            );
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка удаления строки', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Изменить количество товара в корзине
  Future<void> _onUpdateCartLine(UpdateCartLineEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('Изменяем количество в строке: ${event.orderLineId}, новое кол-во: ${event.newQuantity}');

      final result = await _updateCartUseCase(UpdateCartParams(
        orderLineId: event.orderLineId,
        newQuantity: event.newQuantity,
      ));

      await result.fold(
        (failure) async {
          _logger.warning('Ошибка изменения количества: ${failure.message}');
          if (!emit.isDone) {
            emit(CartError(message: failure.message));
          }
        },
        (_) async {
          _logger.info('Количество изменено, получаем обновленную корзину');
          
          // Загружаем обновленную корзину напрямую, без события
          final cartResult = await _getCurrentCartUseCase();
          if (!emit.isDone) {
            cartResult.fold(
              (failure) => emit(CartError(message: failure.message)),
              (cart) {
                if (cart.lines.isEmpty) {
                  emit(CartEmpty(cart: cart));
                } else {
                  final totalAmount = _calculateTotalAmount(cart.lines);
                  final totalItems = _calculateTotalItems(cart.lines);
                  
                  emit(CartLoaded(
                    cart: cart,
                    orderLines: cart.lines,
                    totalAmount: totalAmount,
                    totalItems: totalItems,
                  ));
                }
              },
            );
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка изменения количества', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Очистить корзину (аналог clearCart)
  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('Очищаем корзину');

      // Получаем текущую сессию
      final session = AppSessionService.currentSession;
      if (session == null || !session.isAuthenticated) {
        _logger.warning('Нет активной сессии для очистки корзины');
        emit(CartError(message: 'Нет активной сессии'));
        return;
      }

      final employeeId = session.appUser.employee.id;
      final outletId = session.currentOutletId;

      if (outletId == null) {
        _logger.warning('Не выбрана торговая точка для очистки корзины');
        emit(CartError(message: 'Не выбрана торговая точка'));
        return;
      }

      final result = await _clearCartUseCase(ClearCartParams(
        employeeId: employeeId,
        outletId: outletId,
      ));

      result.fold(
        (failure) {
          _logger.warning('Ошибка очистки корзины: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (cart) {
          _logger.info('Корзина очищена');
          emit(CartEmpty(cart: cart));
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка очистки корзины', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Обновить параметры заказа (аналог patchCurrentOrder)
  Future<void> _onUpdateCartDetails(UpdateCartDetailsEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('Обновляем параметры корзины');

      final result = await _updateCartUseCase(UpdateCartParams(
        paymentKind: event.paymentKind,
        isPickup: event.isPickup,
        approvedDeliveryDay: event.approvedDeliveryDay,
        approvedAssemblyDay: event.approvedAssemblyDay,
        comment: event.comment,
        outletId: event.outletId,
      ));

      result.fold(
        (failure) {
          _logger.warning('Ошибка обновления параметров: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (_) async {
          _logger.info('Параметры корзины обновлены, получаем обновленную корзину');
          
          // Загружаем обновленную корзину напрямую, без события
          final cartResult = await _getCurrentCartUseCase();
          cartResult.fold(
            (failure) => emit(CartError(message: failure.message)),
            (cart) {
              if (cart.lines.isEmpty) {
                emit(CartEmpty(cart: cart));
              } else {
                final totalAmount = _calculateTotalAmount(cart.lines);
                final totalItems = _calculateTotalItems(cart.lines);
                
                emit(CartLoaded(
                  cart: cart,
                  orderLines: cart.lines,
                  totalAmount: totalAmount,
                  totalItems: totalItems,
                ));
              }
            },
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка обновления параметров', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Отправить заказ (аналог submitOrder)
  Future<void> _onSubmitCart(SubmitCartEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('Отправляем заказ из корзины');

      final result = await _submitOrderUseCase(SubmitOrderParams(
        withoutRealization: event.withoutRealization,
      ));

      result.fold(
        (failure) {
          _logger.warning('Ошибка отправки заказа: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (orders) {
          _logger.info('Заказ отправлен успешно');
          emit(CartSubmitted(
            submittedOrder: orders.submittedOrder,
            newCart: orders.newCart,
          ));
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка отправки заказа', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Отправить заказ на ручную проверку (аналог orderToReview)
  Future<void> _onSendCartToReview(SendCartToReviewEvent event, Emitter<CartState> emit) async {
    try {
      _logger.info('Отправляем заказ на ручную проверку');

      final result = await _submitOrderUseCase(const SubmitOrderParams(
        toReview: true,
      ));

      result.fold(
        (failure) {
          _logger.warning('Ошибка отправки на проверку: ${failure.message}');
          emit(CartError(message: failure.message));
        },
        (orders) {
          _logger.info('Заказ отправлен на проверку');
          emit(CartSentToReview(
            reviewOrder: orders.submittedOrder,
            newCart: orders.newCart,
          ));
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Неожиданная ошибка отправки на проверку', e, stackTrace);
      emit(CartError(message: 'Неожиданная ошибка: $e'));
    }
  }

  /// Вычислить общую сумму заказа
  double _calculateTotalAmount(List<OrderLine> orderLines) {
    return orderLines.fold<double>(
      0.0,
      (sum, line) => sum + (line.totalCost / 100.0), // конвертируем из копеек в рубли
    );
  }

  /// Вычислить общее количество товаров
  int _calculateTotalItems(List<OrderLine> orderLines) {
    return orderLines.fold<int>(
      0,
      (sum, line) => sum + line.quantity,
    );
  }

  /// Предзагрузка миниатюр продуктов в корзине для улучшения UX
  void _precacheCartImages(List<OrderLine> orderLines) {
    try {
      // Собираем URL изображений из корзины
      final imageUrls = orderLines
          .where((line) => line.product?.defaultImage?.uri != null)
          .map((line) => line.product!.defaultImage!.uri)
          .toSet() // убираем дубликаты
          .toList();

      if (imageUrls.isNotEmpty) {
        _logger.fine('Предзагрузка ${imageUrls.length} изображений для корзины');
        
        // Запускаем предзагрузку в фоне без блокировки UI
        ImageCacheService.precacheImages(imageUrls, thumbnail: true).then((_) {
          _logger.fine('Предзагрузка изображений корзины завершена');
        }).catchError((error) {
          _logger.warning('Ошибка предзагрузки изображений корзины', error);
        });
      }
    } catch (e) {
      _logger.warning('Ошибка при попытке предзагрузить изображения корзины', e);
    }
  }
}