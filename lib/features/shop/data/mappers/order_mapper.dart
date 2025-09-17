import 'package:drift/drift.dart';
import '../../../../app/database/database.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/entities/order_state.dart';
import '../../domain/entities/payment_kind.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/trading_point.dart';

class OrderMapper {
  /// Преобразует Order entity в OrdersCompanion для базы данных
  static OrdersCompanion toDatabase(Order order) {
    if (order.outlet.id == null || order.outlet.id! <= 0) {
      throw ArgumentError('КРИТИЧЕСКАЯ ОШИБКА: Order.outlet.id не может быть null или <= 0. Заказ: ${order.id}, торговая точка: ${order.outlet.name}');
    }
    
    return OrdersCompanion.insert(
      id: order.id != null ? Value(order.id!) : const Value.absent(),
      creatorId: order.creator.id,
      outletId: order.outlet.id!,
      state: order.state.value,
      paymentType: Value(order.paymentKind.type),
      paymentDetails: Value(order.paymentKind.details),
      paymentIsCash: Value(order.paymentKind.isCashPayment),
      paymentIsCard: Value(order.paymentKind.isCardPayment),
      paymentIsCredit: Value(order.paymentKind.isOnCredit),
      comment: Value(order.comment),
      name: Value(order.name),
      isPickup: Value(order.isPickup),
      approvedDeliveryDay: Value(order.approvedDeliveryDay),
      approvedAssemblyDay: Value(order.approvedAssemblyDay),
      withRealization: Value(order.withRealization),
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }

  /// Преобразует OrderEntity из базы данных в доменную Order entity
  static Order fromDatabaseEntities(
    OrderEntity orderEntity,
    Employee creator,
    TradingPoint outlet,
    List<OrderLine> orderLines,
  ) {
    final paymentKind = PaymentKind(
      type: orderEntity.paymentType,
      details: orderEntity.paymentDetails,
      isCashPayment: orderEntity.paymentIsCash,
      isCardPayment: orderEntity.paymentIsCard,
      isOnCredit: orderEntity.paymentIsCredit,
    );

    return Order(
      id: orderEntity.id,
      creator: creator,
      outlet: outlet,
      lines: orderLines, // уже преобразованные OrderLine
      state: OrderState.fromString(orderEntity.state),
      paymentKind: paymentKind,
      comment: orderEntity.comment,
      name: orderEntity.name,
      isPickup: orderEntity.isPickup,
      approvedDeliveryDay: orderEntity.approvedDeliveryDay,
      approvedAssemblyDay: orderEntity.approvedAssemblyDay,
      withRealization: orderEntity.withRealization,
      createdAt: orderEntity.createdAt,
      updatedAt: orderEntity.updatedAt,
    );
  }
}

class OrderLineMapper {
  /// Преобразует OrderLine entity в OrderLinesCompanion для базы данных
  static OrderLinesCompanion toDatabase(OrderLine orderLine, int orderId) {
    return OrderLinesCompanion.insert(
      id: orderLine.id != null ? Value(orderLine.id!) : const Value.absent(),
      orderId: orderId,
      stockItemId: orderLine.stockItem.id,
      quantity: orderLine.quantity,
      pricePerUnit: orderLine.pricePerUnit,
      createdAt: orderLine.createdAt,
      updatedAt: orderLine.updatedAt,
    );
  }
}