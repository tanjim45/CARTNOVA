
import 'package:uuid/uuid.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../../cart/domain/repositories/cart_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CartRepository cartRepository;

  CheckoutRepositoryImpl({
    required this.cartRepository,
  });

  static const double _deliveryCharge = 60.0;

  @override
  Future<Order> placeOrder({
    required String customerName,
    required String phone,
    required String address,
  }) async {
    final items = cartRepository.getCartItems();

    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final subtotal = items.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    final total = subtotal + _deliveryCharge;

    final order = Order(
      id: const Uuid().v4(),
      customerName: customerName,
      phone: phone,
      address: address,
      items: items,
      subtotal: subtotal,
      deliveryCharge: _deliveryCharge,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    cartRepository.clearCart();

    return order;
  }
}
