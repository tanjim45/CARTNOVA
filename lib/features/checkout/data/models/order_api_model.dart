
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

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      id: (json['id'] as num).toInt(),
      orderNumber: json['order_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge:
          (json['delivery_charge'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
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
        cartItemId: (item['id'] as num?)?.toInt() ?? 0,
        product: Product(
          id: (item['product_id'] as num?)?.toInt() ?? 0,
          title: item['product_title']?.toString() ?? '',
          description: '',
          category: '',
          brand: 'Unknown',
          price: (item['price'] as num?)?.toDouble() ?? 0,
          discountPercentage: 0,
          rating: 0,
          stock: 0,
          thumbnail: thumbnail,
          images: thumbnail.isEmpty ? [] : [thumbnail],
        ),
        quantity: (item['quantity'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return Order(
      id: id.toString(),
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
