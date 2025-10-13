import 'package:equatable/equatable.dart';
import 'order_line.dart';
import 'order_state.dart';
import 'payment_kind.dart';
import 'trading_point.dart';
import 'employee.dart';

/// Заказ - основная сущность для управления корзиной и заказами
class Order extends Equatable {
  static const Object _noUpdate = Object();
  final int? id;
  final Employee creator;
  final TradingPoint outlet;
  final List<OrderLine> lines;
  final OrderState state;
  final PaymentKind paymentKind;
  final String? comment;
  final String? name;
  final bool isPickup;
  final DateTime? approvedDeliveryDay;
  final DateTime? approvedAssemblyDay;
  final bool withRealization;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    this.id,
    required this.creator,
    required this.outlet,
    required this.lines,
    required this.state,
    required this.paymentKind,
    this.comment,
    this.name,
    this.isPickup = true,
    this.approvedDeliveryDay,
    this.approvedAssemblyDay,
    this.withRealization = true,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создает новый заказ в состоянии Draft (корзина)
  factory Order.createDraft({
    required Employee creator,
    required TradingPoint outlet,
  }) {
    final now = DateTime.now();
    return Order(
      creator: creator,
      outlet: outlet,
      lines: const [],
      state: OrderState.draft,
      paymentKind: const PaymentKind.cashless(),
      isPickup: true,
      withRealization: true,
      failureReason: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Общая стоимость заказа в копейках
  int get totalCost {
    return lines.fold(0, (sum, line) => sum + line.totalCost);
  }

  /// Общая экономия по заказу
  int get totalSaving {
    return lines.fold(0, (sum, line) => sum + line.saving);
  }

  /// Общая стоимость по базовым ценам
  int get totalBaseCost {
    return lines.fold(0, (sum, line) => sum + line.totalBaseCost);
  }

  /// Проверяет, что заказ можно редактировать
  bool get canEdit => state.canEdit;

  /// Проверяет, что заказ можно отправить
  bool get canSubmit => state.canSubmit && lines.isNotEmpty && paymentKind.isValid();

  /// Находится ли заказ в состоянии ошибки
  bool get hasError => state == OrderState.error;

  /// Подтверждён ли заказ внешней системой
  bool get isConfirmed => state.isConfirmed;

  /// Проверяет, что заказ пустой
  bool get isEmpty => lines.isEmpty;

  /// Количество различных товаров в заказе
  int get itemCount => lines.length;

  /// Общее количество единиц товара
  int get totalQuantity => lines.fold(0, (sum, line) => sum + line.quantity);

  /// Добавляет товар в заказ или обновляет количество если товар уже есть
  Order addProduct({
    required int productId,
    required OrderLine orderLine,
  }) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    final existingIndex = lines.indexWhere((line) => line.productCode == productId);
    List<OrderLine> newLines;

    if (existingIndex != -1) {
      // Обновляем существующую строку
      final existingLine = lines[existingIndex];
      final updatedLine = existingLine.updateQuantity(
        existingLine.quantity + orderLine.quantity,
      );
      newLines = List.from(lines);
      newLines[existingIndex] = updatedLine;
    } else {
      // Добавляем новую строку
      newLines = [...lines, orderLine];
    }

    return copyWith(
      lines: newLines,
      updatedAt: DateTime.now(),
    );
  }

  /// Удаляет товар из заказа
  Order removeProduct(int productId) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    final newLines = lines.where((line) => line.productCode != productId).toList();
    
    return copyWith(
      lines: newLines,
      updatedAt: DateTime.now(),
    );
  }

  /// Обновляет количество товара в заказе
  Order updateProductQuantity(int productId, int newQuantity) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    if (newQuantity <= 0) {
      return removeProduct(productId);
    }

    final lineIndex = lines.indexWhere((line) => line.productCode == productId);
    if (lineIndex == -1) {
      throw ArgumentError('Product not found in order');
    }

    final updatedLine = lines[lineIndex].updateQuantity(newQuantity);
    final newLines = List<OrderLine>.from(lines);
    newLines[lineIndex] = updatedLine;

    return copyWith(
      lines: newLines,
      updatedAt: DateTime.now(),
    );
  }

  /// Очищает все товары из заказа
  Order clear() {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    return copyWith(
      lines: const [],
      updatedAt: DateTime.now(),
    );
  }

  /// Обновляет состояние заказа
  Order updateState(OrderState newState, {String? failureReason}) {
    if (!state.canTransitionTo(newState)) {
      throw StateError('Cannot transition from $state to $newState');
    }
    
    return copyWith(
      state: newState,
      failureReason: newState == OrderState.error ? failureReason : null,
      updatedAt: DateTime.now(),
    );
  }

  /// Переводит заказ в состояние отправки
  Order submit() {
    if (!canSubmit) {
      throw StateError('Cannot submit order. State: $state, isEmpty: $isEmpty, paymentValid: ${paymentKind.isValid()}');
    }

    return updateState(OrderState.pending);
  }

  /// Помечает заказ как подтверждённый
  Order confirm() {
    if (state != OrderState.pending) {
      throw StateError('Can only confirm pending orders');
    }

    return updateState(OrderState.confirmed);
  }

  /// Переводит заказ в состояние ошибки (требуется ручная проверка)
  Order markAsError({String? reason}) {
    if (state != OrderState.pending) {
      throw StateError('Can only mark pending orders as error');
    }

    return updateState(OrderState.error, failureReason: reason);
  }

  /// Возвращает заказ в черновик
  Order returnToDraft() {
    if (!state.canEdit && state != OrderState.error) {
      throw StateError('Cannot return to draft from state: $state');
    }

    return updateState(OrderState.draft);
  }

  /// Обновляет способ оплаты
  Order updatePaymentKind(PaymentKind newPaymentKind) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    return copyWith(
      paymentKind: newPaymentKind,
      updatedAt: DateTime.now(),
    );
  }

  /// Обновляет комментарий к заказу
  Order updateComment(String? newComment) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    return copyWith(
      comment: newComment,
      updatedAt: DateTime.now(),
    );
  }

  /// Обновляет имя заказа
  Order updateName(String? newName) {
    if (newName != null && newName.length > 20) {
      throw ArgumentError('Order name cannot be longer than 20 characters');
    }

    return copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
  }

  /// Устанавливает тип доставки
  Order setPickup(bool pickup) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    return copyWith(
      isPickup: pickup,
      updatedAt: DateTime.now(),
    );
  }

  /// Устанавливает день доставки
  Order setDeliveryDay(DateTime deliveryDay) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    return copyWith(
      approvedDeliveryDay: deliveryDay,
      updatedAt: DateTime.now(),
    );
  }

  /// Устанавливает день сборки для самовывоза
  Order setAssemblyDay(DateTime assemblyDay) {
    if (!canEdit) {
      throw StateError('Cannot edit order in state: $state');
    }

    return copyWith(
      approvedAssemblyDay: assemblyDay,
      updatedAt: DateTime.now(),
    );
  }

  /// Получает дату отчетности (доставка или сборка)
  DateTime? get reportingDate {
    return isPickup ? approvedAssemblyDay : approvedDeliveryDay;
  }

  /// Представление заказа в формате JSON для отправки во внешнее API
  Map<String, dynamic> toApiPayload() {
    return {
      'id': id,
      'state': state.value,
      'creator': {
        'id': creator.id,
        'fullName': creator.fullName,
        'role': creator.role.name,
      },
      'outlet': {
        'id': outlet.id,
        'externalId': outlet.externalId,
        'name': outlet.name,
        'inn': outlet.inn,
      },
      'comment': comment,
      'name': name,
      'isPickup': isPickup,
      'approvedDeliveryDay': approvedDeliveryDay?.toIso8601String(),
      'approvedAssemblyDay': approvedAssemblyDay?.toIso8601String(),
      'withRealization': withRealization,
      'paymentKind': {
        'payment': paymentKind.paymentCode,
        'method': paymentKind.methodCode,
        'payOnReceive': paymentKind.payOnReceive,
        'documentName': paymentKind.documentLabel,
        // Поля для обратной совместимости со старым контрактом
        'type': paymentKind.paymentCode,
        'details': paymentKind.methodCode,
        'isCashPayment': paymentKind.isCash,
        'isCardPayment': false,
        'isOnCredit': paymentKind.payOnReceive,
        'microNaming': paymentKind.microLabel,
      },
      'totals': {
        'cost': totalCost,
        'baseCost': totalBaseCost,
        'saving': totalSaving,
        'quantity': totalQuantity,
        'itemCount': itemCount,
      },
      'lines': lines.map((line) => line.toApiPayload()).toList(),
      'failureReason': failureReason,
      'timestamps': {
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }

  Order copyWith({
    int? id,
    Employee? creator,
    TradingPoint? outlet,
    List<OrderLine>? lines,
    OrderState? state,
    PaymentKind? paymentKind,
    String? comment,
    String? name,
    bool? isPickup,
    DateTime? approvedDeliveryDay,
    DateTime? approvedAssemblyDay,
    bool? withRealization,
    Object? failureReason = _noUpdate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      outlet: outlet ?? this.outlet,
      lines: lines ?? this.lines,
      state: state ?? this.state,
      paymentKind: paymentKind ?? this.paymentKind,
      comment: comment ?? this.comment,
      name: name ?? this.name,
      isPickup: isPickup ?? this.isPickup,
      approvedDeliveryDay: approvedDeliveryDay ?? this.approvedDeliveryDay,
      approvedAssemblyDay: approvedAssemblyDay ?? this.approvedAssemblyDay,
      withRealization: withRealization ?? this.withRealization,
      failureReason: identical(failureReason, _noUpdate) ? this.failureReason : failureReason as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creator,
        outlet,
        lines,
        state,
        paymentKind,
        comment,
        name,
        isPickup,
        approvedDeliveryDay,
        approvedAssemblyDay,
        withRealization,
        failureReason,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Order(id: $id, state: $state, itemCount: $itemCount, totalCost: $totalCost, failureReason: $failureReason)';
  }
}