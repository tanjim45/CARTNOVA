
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
