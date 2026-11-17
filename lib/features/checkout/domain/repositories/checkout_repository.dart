import '../entities/order.dart';

abstract class CheckoutRepository {
  Future<Order> placeOrder({
    required String customerName,
    required String phone,
    required String address,
  });
}
