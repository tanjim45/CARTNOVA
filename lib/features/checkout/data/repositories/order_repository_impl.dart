
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Order> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    final model = await remoteDataSource.placeOrder(
      customerName: customerName,
      phone: phone,
      address: address,
      paymentMethod: paymentMethod,
    );

    return model.toEntity();
  }

  @override
  Future<List<Order>> getOrders() async {
    final models = await remoteDataSource.getOrders();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final model = await remoteDataSource.getOrderById(orderId);
      return model.toEntity();
    } catch (error) {
      if (error.toString().contains('Order not found')) {
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await remoteDataSource.cancelOrder(orderId);
  }
}
