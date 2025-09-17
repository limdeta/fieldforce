enum OrderState {
  /// Черновик заказа (корзина) - можно редактировать
  draft('draft'),
  
  /// Заказ отправляется на сервер - промежуточное состояние
  pending('pending'),
  
  /// Заказ успешно принят сервером и обрабатывается
  completed('completed'),
  
  /// Ошибка при отправке заказа - требуется повторная обработка
  failed('failed');

  const OrderState(this.value);
  
  final String value;

  /// Можно ли редактировать заказ в данном состоянии
  bool get canEdit => this == OrderState.draft || this == OrderState.failed;
  
  /// Можно ли отправить заказ на сервер
  bool get canSubmit => this == OrderState.draft;
  
  /// Заказ находится в процессе обработки
  bool get isProcessing => this == OrderState.pending;
  
  /// Заказ завершен и не может быть изменен
  bool get isCompleted => this == OrderState.completed;

  /// Проверяет, возможен ли переход в указанное состояние
  bool canTransitionTo(OrderState newState) {
    switch (this) {
      case OrderState.draft:
        return newState == OrderState.pending; // Из draft можно только в pending
      case OrderState.pending:
        return newState == OrderState.completed || newState == OrderState.failed; // Из pending в completed или failed
      case OrderState.failed:
        return newState == OrderState.pending || newState == OrderState.draft; // Из failed можно попробовать снова или вернуться к редактированию
      case OrderState.completed:
        return false; // Из completed никуда нельзя переходить
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