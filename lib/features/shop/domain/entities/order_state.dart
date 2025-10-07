enum OrderState {
  /// Черновик заказа (корзина) - можно редактировать
  draft('draft'),
  
  /// Заказ отправляется на сервер или ожидает отправки (очередь)
  pending('pending'),
  
  /// Заказ подтверждён внешней системой
  confirmed('confirmed'),
  
  /// Требуется ручное вмешательство (ошибка при отправке или обработке)
  error('error');

  const OrderState(this.value);
  
  final String value;

  /// Можно ли редактировать заказ в данном состоянии
  bool get canEdit => this == OrderState.draft || this == OrderState.error;
  
  /// Можно ли отправить заказ на сервер
  bool get canSubmit => this == OrderState.draft;
  
  /// Заказ находится в процессе обработки
  bool get isProcessing => this == OrderState.pending;
  
  /// Заказ подтверждён и не требует дальнейших действий
  bool get isConfirmed => this == OrderState.confirmed;

  /// Проверяет, возможен ли переход в указанное состояние
  bool canTransitionTo(OrderState newState) {
    switch (this) {
      case OrderState.draft:
        return newState == OrderState.pending; // Из draft можно только в pending
      case OrderState.pending:
        return newState == OrderState.confirmed || newState == OrderState.error; // Из pending в confirmed или error
      case OrderState.error:
        return newState == OrderState.pending || newState == OrderState.draft; // Из error можно попробовать снова или вернуться к редактированию
      case OrderState.confirmed:
        return false; // Из confirmed никуда нельзя переходить
    }
  }

  static OrderState fromString(String value) {
    return OrderState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => OrderState.draft,
    );
  }

  @override
  String toString() => value;
}