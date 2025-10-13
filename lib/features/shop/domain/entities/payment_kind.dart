/// Способ оплаты заказа, синхронизированный с бекенд-сущностью PaymentKind
class PaymentKind {
  static const String paymentCashless = 'cashless';
  static const String paymentCash = 'cash';

  static const String methodWholesale = 'wholesale';
  static const String methodRetail = 'retail';

  static const Map<String, String> paymentNaming = {
    paymentCashless: 'Оплата по банковским реквизитам',
    paymentCash: 'Наличные',
  };

  static const Map<String, String> paymentMicroNaming = {
    paymentCashless: 'безнал',
    paymentCash: 'нал',
  };

  static const Map<String, String> methodNaming = {
    methodWholesale: 'Опт',
    methodRetail: 'Розница',
  };

  static const Map<String, String> publicDocumentNaming = {
    methodWholesale: 'Универсальные передаточные документы',
    methodRetail: 'Копия чека',
  };

  final String? payment;
  final String? method;
  final bool payOnReceive;

  const PaymentKind._internal({
    this.payment,
    this.method,
    this.payOnReceive = false,
  });

  /// Пустое значение (способ оплаты не выбран)
  const PaymentKind.empty() : this._internal();

  /// Предустановленный способ оплаты: безналичный расчет
  const PaymentKind.cashless()
      : this._internal(
          payment: paymentCashless,
          method: methodWholesale,
          payOnReceive: false,
        );

  /// Предустановленный способ оплаты: наличный расчет
  const PaymentKind.cash({bool payOnReceive = false})
      : this._internal(
          payment: paymentCash,
          method: methodRetail,
          payOnReceive: payOnReceive,
        );

  /// Универсальный конструктор, приводит значения к поддерживаемому формату
  factory PaymentKind({
    String? payment,
    String? method,
    bool payOnReceive = false,
  }) {
    if (payment == null) {
      return const PaymentKind._internal();
    }

    final normalizedPayment = _normalizePayment(payment);
    final defaultMethod = _defaultMethodForPayment(normalizedPayment);
    final normalizedMethod = _normalizeMethod(method ?? defaultMethod);

    final normalizedPayOnReceive =
        normalizedPayment == paymentCash ? payOnReceive : false;

    return PaymentKind._internal(
      payment: normalizedPayment,
      method: normalizedMethod,
      payOnReceive: normalizedPayOnReceive,
    );
  }

  static String _normalizePayment(String value) {
    switch (value.toLowerCase()) {
      case paymentCashless:
        return paymentCashless;
      case paymentCash:
        return paymentCash;
      default:
        return value.toLowerCase();
    }
  }

  static String _normalizeMethod(String value) {
    switch (value.toLowerCase()) {
      case methodWholesale:
        return methodWholesale;
      case methodRetail:
        return methodRetail;
      default:
        return value.toLowerCase();
    }
  }

  static String _defaultMethodForPayment(String payment) {
    if (payment == paymentCashless) {
      return methodWholesale;
    }
    if (payment == paymentCash) {
      return methodRetail;
    }
    return methodWholesale;
  }

  /// Список предустановленных значений, доступных пользователю
  static const List<PaymentKind> predefinedOptions = <PaymentKind>[
    PaymentKind.cashless(),
    PaymentKind.cash(),
  ];

  /// Возвращает новый экземпляр со скорректированными значениям
  PaymentKind copyWith({
    String? payment,
    String? method,
    bool? payOnReceive,
    bool resetMethod = false,
  }) {
    final String? nextPayment = payment ?? this.payment;
    String? nextMethod = resetMethod ? null : method ?? this.method;

    if (payment != null && payment != this.payment) {
      nextMethod = _defaultMethodForPayment(_normalizePayment(payment));
    } else if (nextMethod == null && nextPayment != null) {
      nextMethod = _defaultMethodForPayment(nextPayment);
    }

    final bool nextPayOnReceive = nextPayment == paymentCash
        ? (payOnReceive ?? this.payOnReceive)
        : false;

    return PaymentKind(
      payment: nextPayment,
      method: nextMethod,
      payOnReceive: nextPayOnReceive,
    );
  }

  /// Проверяет, что пользователь выбрал допустимое сочетание
  bool isValid() => payment != null && method != null;

  /// Проверяет, что значение не заполнено
  bool get isEmpty => !isValid();

  bool get isCash => payment == paymentCash;
  bool get isCashless => payment == paymentCashless;

  String? get paymentCode => payment;
  String? get methodCode => method;

  String get paymentLabel =>
      payment != null ? paymentNaming[payment] ?? payment! : 'Не выбран';

  String get methodLabel =>
      method != null ? methodNaming[method] ?? method! : '—';

  String get documentLabel =>
      method != null ? publicDocumentNaming[method] ?? methodLabel : '—';

  String? get microLabel =>
      payment != null ? paymentMicroNaming[payment] ?? payment : null;

  List<String> get possibleMethodCodes {
    if (isCashless) return const <String>[methodWholesale];
    if (isCash) return const <String>[methodRetail];
    return const <String>[methodWholesale, methodRetail];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentKind &&
        other.payment == payment &&
        other.method == method &&
        other.payOnReceive == payOnReceive;
  }

  @override
  int get hashCode => Object.hash(payment, method, payOnReceive);

  @override
  String toString() {
    if (isEmpty) {
      return 'PaymentKind.empty';
    }
    return 'PaymentKind(payment: $payment, method: $method, payOnReceive: $payOnReceive)';
  }
}