
import 'package:hive/hive.dart';

import '../../domain/entities/order.dart';

class OrderModel extends HiveObject {
  final String id;
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

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    this.paymentMethod = 'Cash on Delivery',
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      customerName: order.customerName,
      phone: order.phone,
      address: order.address,
      subtotal: order.subtotal,
      deliveryCharge: order.deliveryCharge,
      total: order.total,
      paymentMethod: order.paymentMethod,
      status: order.status.name,
      createdAt: order.createdAt,
      items: order.items.map((item) {
        return {
          'productId': item.product.id,
          'title': item.product.title,
          'price': item.product.price,
          'quantity': item.quantity,
          'thumbnail': item.product.thumbnail,
          'totalPrice': item.totalPrice,
        };
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'items': items,
    };
  }

  factory OrderModel.fromMap(Map<dynamic, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerName: map['customerName'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryCharge: (map['deliveryCharge'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paymentMethod:
          map['paymentMethod'] as String? ?? 'Cash on Delivery',
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      items: (map['items'] as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList(),
    );
  }
}
