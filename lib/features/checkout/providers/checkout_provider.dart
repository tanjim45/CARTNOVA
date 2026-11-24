
import 'package:cartnova_app/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:cartnova_app/features/checkout/domain/entities/order.dart';
import 'package:cartnova_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_provider.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);

  return CheckoutRepositoryImpl(
    orderRepository: orderRepository,
  );
});

class CheckoutNotifier extends StateNotifier<AsyncValue<Order?>> {
  final CheckoutRepository _repository;

  CheckoutNotifier(this._repository) : super(const AsyncData(null));

  Future<void> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    state = const AsyncLoading();

    try {
      final order = await _repository.placeOrder(
        customerName: customerName,
        phone: phone,
        address: address,
        paymentMethod: paymentMethod,
      );

      state = AsyncData(order);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, AsyncValue<Order?>>((ref) {
  final repository = ref.watch(checkoutRepositoryProvider);

  return CheckoutNotifier(repository);
});
