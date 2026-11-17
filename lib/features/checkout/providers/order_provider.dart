
import 'package:cartnova_app/features/products/data/repositories/order_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/order.dart';
import '../domain/repositories/order_repository.dart';
import '../data/datasources/order_local_data_source.dart';

final orderLocalDataSourceProvider =
    Provider<OrderLocalDataSource>((ref) {
  return OrderLocalDataSource();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dataSource = ref.watch(orderLocalDataSourceProvider);

  return OrderRepositoryImpl(
    localDataSource: dataSource,
  );
});

final orderHistoryProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);

  return repository.getOrders();
});

final orderDetailsProvider =
    FutureProvider.family<Order?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);

  return repository.getOrderById(orderId);
});

final cancelOrderProvider =
    Provider<CancelOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);

  return CancelOrder(
    repository: repository,
    ref: ref,
  );
});

class CancelOrder {
  final OrderRepository repository;
  final Ref ref;

  CancelOrder({
    required this.repository,
    required this.ref,
  });

  Future<void> call(String orderId) async {
    final order = await repository.getOrderById(orderId);

    if (order == null) {
      throw Exception('Order not found.');
    }

    if (order.status != OrderStatus.pending) {
      throw Exception('Only pending orders can be cancelled.');
    }

    await repository.updateOrderStatus(
      orderId: orderId,
      status: OrderStatus.cancelled,
    );

    ref.invalidate(orderHistoryProvider);
    ref.invalidate(orderDetailsProvider(orderId));
  }
}
