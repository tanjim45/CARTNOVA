
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/cart_remote_data_source.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/entities/cart_item.dart';
import '../domain/repositories/cart_repository.dart';
import '../../products/domain/entities/product.dart';

final cartRemoteDataSourceProvider =
    Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSource();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    remoteDataSource: ref.watch(cartRemoteDataSourceProvider),
  );
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repository;

  bool isLoading = false;
  String? errorMessage;

  int _requestVersion = 0;

  CartNotifier(this._repository) : super([]) {
    loadCart();
  }

  Future<void> loadCart() async {
    final requestVersion = ++_requestVersion;

    isLoading = true;
    errorMessage = null;

    try {
      final items = await _repository.getCartItems();

      if (requestVersion == _requestVersion) {
        state = items;
      }
    } catch (e) {
      if (requestVersion == _requestVersion) {
        errorMessage = e.toString();
      }
    } finally {
      if (requestVersion == _requestVersion) {
        isLoading = false;
      }
    }
  }

  Future<void> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    errorMessage = null;

    try {
      state = await _repository.addToCart(
        product.id,
        quantity: quantity,
      );
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> removeFromCart(int productId) async {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
    );

    errorMessage = null;

    try {
      state = await _repository.removeFromCart(item.cartItemId);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> increaseQuantity(int productId) async {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
    );

    errorMessage = null;

    try {
      state = await _repository.updateQuantity(
        item.cartItemId,
        item.quantity + 1,
      );
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> decreaseQuantity(int productId) async {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
    );

    errorMessage = null;

    try {
      if (item.quantity > 1) {
        state = await _repository.updateQuantity(
          item.cartItemId,
          item.quantity - 1,
        );
      } else {
        state = await _repository.removeFromCart(item.cartItemId);
      }
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> clearCart() async {
    ++_requestVersion;
    isLoading = false;
    errorMessage = null;

    state = [];

    try {
      state = await _repository.clearCart();
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  void clearLocalCart() {
    ++_requestVersion;
    isLoading = false;
    errorMessage = null;
    state = [];
  }

  List<CartItem> get currentItems {
    return List.unmodifiable(state);
  }

  double get subtotal {
    return state.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  int get totalItems {
    return state.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final repository = ref.watch(cartRepositoryProvider);

  return CartNotifier(repository);
});
