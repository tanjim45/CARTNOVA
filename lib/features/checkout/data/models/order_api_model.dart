
import '../../domain/entities/order.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';

class OrderApiModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String phone;
  final String address;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;

  const OrderApiModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      id: _toInt(json['id']),
      orderNumber: json['order_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      subtotal: _toDouble(json['subtotal']),
      deliveryCharge: _toDouble(json['delivery_charge']),
      total: _toDouble(json['total']),
      paymentMethod:
          json['payment_method']?.toString() ?? 'Cash on Delivery',
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      items: (json['items'] as List? ?? []).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList(),
    );
  }

  Order toEntity() {
    final orderItems = items.map((item) {
      final thumbnail = item['product_thumbnail']?.toString() ?? '';

      return CartItem(
        cartItemId: _toInt(item['id']),
        product: Product(
          id: _toInt(item['product_id']),
          title: item['product_title']?.toString() ?? '',
          description: '',
          category: '',
          brand: 'Unknown',
          price: _toDouble(item['price']),
          discountPercentage: 0,
          rating: 0,
          stock: 0,
          thumbnail: thumbnail,
          images: thumbnail.isEmpty ? [] : [thumbnail],
        ),
        quantity: _toInt(item['quantity']),
      );
    }).toList();

    return Order(
      id: id.toString(),
      orderNumber: orderNumber,
      customerName: customerName,
      phone: phone,
      address: address,
      items: orderItems,
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      total: total,
      paymentMethod: paymentMethod,
      status: OrderStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => OrderStatus.pending,
      ),
      createdAt: createdAt,
    );
  }
}
