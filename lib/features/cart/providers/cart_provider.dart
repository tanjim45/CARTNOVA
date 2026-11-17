import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/entities/cart_item.dart';
import '../domain/repositories/cart_repository.dart';
import '../../products/domain/entities/product.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repository;

  CartNotifier(this._repository)
      : super(_repository.getCartItems());

  void addToCart(Product product, {int quantity = 1}) {
  for (int i = 0; i < quantity; i++) {
    _repository.addToCart(product);
  }

  _updateState();
}

  void removeFromCart(int productId) {
    _repository.removeFromCart(productId);
    _updateState();
  }

  void increaseQuantity(int productId) {
    _repository.increaseQuantity(productId);
    _updateState();
  }

  void decreaseQuantity(int productId) {
    _repository.decreaseQuantity(productId);
    _updateState();
  }

  void clearCart() {
    _repository.clearCart();
    _updateState();
  }

  void _updateState() {
    state = _repository.getCartItems();
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
