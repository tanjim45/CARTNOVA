import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  });

  Future<List<Order>> getOrders();

  Future<Order?> getOrderById(String orderId);

  Future<void> cancelOrder(String orderId);
}
