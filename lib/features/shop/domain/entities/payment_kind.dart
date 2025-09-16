/// Способ оплаты заказа
class PaymentKind {
  final String? type;
  final String? details;
  final bool isCashPayment;
  final bool isCardPayment;
  final bool isOnCredit;

  const PaymentKind({
    this.type,
    this.details,
    this.isCashPayment = false,
    this.isCardPayment = false,
    this.isOnCredit = false,
  });

  /// Создает способ оплаты наличными
  const PaymentKind.cash({String? details}) : this(
    type: 'cash',
    details: details,
    isCashPayment: true,
  );

  /// Создает способ оплаты картой
  const PaymentKind.card({String? details}) : this(
    type: 'card', 
    details: details,
    isCardPayment: true,
  );

  /// Создает способ оплаты в кредит
  const PaymentKind.credit({String? details}) : this(
    type: 'credit',
    details: details,
    isOnCredit: true,
  );

  /// Пустой способ оплаты (не выбран)
  const PaymentKind.empty() : this();

  /// Проверяет, что способ оплаты выбран корректно
  bool isValid() {
    return type != null && (isCashPayment || isCardPayment || isOnCredit);
  }

  /// Проверяет, что способ оплаты не задан
  bool get isEmpty => type == null;

  PaymentKind copyWith({
    String? type,
    String? details,
    bool? isCashPayment,
    bool? isCardPayment, 
    bool? isOnCredit,
  }) {
    return PaymentKind(
      type: type ?? this.type,
      details: details ?? this.details,
      isCashPayment: isCashPayment ?? this.isCashPayment,
      isCardPayment: isCardPayment ?? this.isCardPayment,
      isOnCredit: isOnCredit ?? this.isOnCredit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentKind &&
        other.type == type &&
        other.details == details &&
        other.isCashPayment == isCashPayment &&
        other.isCardPayment == isCardPayment &&
        other.isOnCredit == isOnCredit;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        details.hashCode ^
        isCashPayment.hashCode ^
        isCardPayment.hashCode ^
        isOnCredit.hashCode;
  }

  @override
  String toString() {
    if (isEmpty) return 'PaymentKind.empty';
    return 'PaymentKind(type: $type, details: $details)';
  }
}