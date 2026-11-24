
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/datasources/order_remote_data_source.dart';
import '../data/repositories/order_repository_impl.dart';
import '../domain/entities/order.dart';
import '../domain/repositories/order_repository.dart';

final orderRemoteDataSourceProvider =
    Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(
    client: http.Client(),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);

  return OrderRepositoryImpl(
    remoteDataSource: remoteDataSource,
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

final cancelOrderProvider = Provider<CancelOrder>((ref) {
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

    await repository.cancelOrder(orderId);

    ref.invalidate(orderHistoryProvider);
    ref.invalidate(orderDetailsProvider(orderId));
  }
}
