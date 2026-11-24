
import 'package:cartnova_app/features/cart/domain/entities/cart_item.dart';
import 'package:cartnova_app/features/checkout/data/datasources/order_local_data_source.dart';
import 'package:cartnova_app/features/checkout/data/models/order_model.dart';
import 'package:cartnova_app/features/checkout/domain/entities/order.dart';
import 'package:cartnova_app/features/checkout/domain/repositories/order_repository.dart';
import 'package:cartnova_app/features/products/domain/entities/product.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> saveOrder(Order order) async {
    final orderModel = OrderModel.fromEntity(order);
    await localDataSource.saveOrder(orderModel);
  }

  @override
  Future<List<Order>> getOrders() async {
    final orderModels = await localDataSource.getOrders();
    return orderModels.map(_toEntity).toList();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final orderModel = await localDataSource.getOrderById(orderId);

    if (orderModel == null) return null;

    return _toEntity(orderModel);
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await localDataSource.deleteOrder(orderId);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    await localDataSource.updateOrderStatus(
      orderId: orderId,
      status: status.name,
    );
  }

  Order _toEntity(OrderModel model) {
    final orderItems = model.items.map((item) {
      final thumbnail = item['thumbnail'] as String;

      return CartItem(
        cartItemId: 0,
        product: Product(
          id: (item['productId'] as num).toInt(),
          title: item['title'] as String,
          description: '',
          category: '',
          brand: 'Unknown',
          price: (item['price'] as num).toDouble(),
          discountPercentage: 0,
          rating: 0,
          stock: 0,
          thumbnail: thumbnail,
          images: [thumbnail],
        ),
        quantity: (item['quantity'] as num).toInt(),
      );
    }).toList();

    return Order(
      id: model.id,
      customerName: model.customerName,
      phone: model.phone,
      address: model.address,
      items: orderItems,
      subtotal: model.subtotal,
      deliveryCharge: model.deliveryCharge,
      total: model.total,
      paymentMethod: model.paymentMethod,
      status: OrderStatus.values.firstWhere(
        (value) => value.name == model.status,
        orElse: () => OrderStatus.pending,
      ),
      createdAt: model.createdAt,
    );
  }
}
