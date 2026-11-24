import '../../domain/entities/order.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/repositories/order_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final OrderRepository orderRepository;

  CheckoutRepositoryImpl({
    required this.orderRepository,
  });

  @override
  Future<Order> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    return orderRepository.placeOrder(
      customerName: customerName,
      phone: phone,
      address: address,
      paymentMethod: paymentMethod,
    );
  }
}
