
import '../entities/order.dart';

abstract class OrderRepository {
  Future<void> saveOrder(Order order);

  Future<List<Order>> getOrders();

  Future<Order?> getOrderById(String orderId);

  Future<void> deleteOrder(String orderId);

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });
}
