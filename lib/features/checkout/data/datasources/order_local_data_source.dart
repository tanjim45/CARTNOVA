
import 'package:hive/hive.dart';

import '../../../../core/database/hive_database.dart';
import '../models/order_model.dart';

class OrderLocalDataSource {
  static const String _boxName = 'orders';

  Future<Box> get _box async {
    return HiveDatabase.openBox(_boxName);
  }

  // Save order
  Future<void> saveOrder(OrderModel order) async {
    final box = await _box;

    await box.put(order.id, order.toMap());
  }

  // Get all orders
  Future<List<OrderModel>> getOrders() async {
    final box = await _box;

    return box.values.map((value) {
      return OrderModel.fromMap(value as Map);
    }).toList();
  }

  // Get single order
  Future<OrderModel?> getOrderById(String orderId) async {
    final box = await _box;

    final data = box.get(orderId);

    if (data == null) {
      return null;
    }

    return OrderModel.fromMap(data as Map);
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    final box = await _box;

    await box.delete(orderId);
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final box = await _box;

    final data = box.get(orderId);

    if (data == null) return;

    final orderMap = Map<String, dynamic>.from(data as Map);

    orderMap['status'] = status;

    await box.put(orderId, orderMap);
  }
}
