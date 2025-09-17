import '../entities/order.dart';
import '../entities/order_line.dart';

abstract class OrderRepository {
  /// Получает текущий черновик заказа для пользователя и торговой точки
  /// Создает новый если не существует
  Future<Order> getCurrentDraftOrder(int employeeId, int outletId);
  
  /// Сохраняет заказ
  Future<Order> saveOrder(Order order);
  
  /// Получает заказ по ID
  Future<Order?> getOrderById(int id);
  
  /// Получает все заказы пользователя
  Future<List<Order>> getOrdersByEmployee(int employeeId);
  
  /// Получает заказы по состоянию
  Future<List<Order>> getOrdersByState(String state);
  
  /// Получает заказы для торговой точки
  Future<List<Order>> getOrdersByOutlet(int outletId);
  
  /// Удаляет заказ
  Future<void> deleteOrder(int id);
  
  /// Очищает все черновики (для тестов)
  Future<void> clearAllDrafts();
  
  /// Добавляет строку товара в заказ
  Future<Order> addOrderLine(OrderLine orderLine);
  
  /// Обновляет количество товара в строке заказа
  Future<Order> updateOrderLineQuantity({
    required int orderLineId,
    required int newQuantity,
  });
  
  /// Удаляет строку товара из заказа
  Future<Order> removeOrderLine(int orderLineId);
  
  /// Очищает корзину (удаляет все строки из текущего draft заказа)
  Future<Order> clearCart({
    required int employeeId,
    required int outletId,
  });
}