import '../../../cart/domain/entities/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}
