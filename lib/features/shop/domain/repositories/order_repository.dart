import '../entities/order.dart';

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
}