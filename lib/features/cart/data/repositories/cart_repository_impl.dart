import 'package:cartnova_app/features/products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final List<CartItem> _cartItems = [];

  @override
  List<CartItem> getCartItems() {
    return List.unmodifiable(_cartItems);
  }

  @override
  void addToCart(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index != -1) {
      final existingItem = _cartItems[index];

      _cartItems[index] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      _cartItems.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
  }

  @override
  void removeFromCart(int productId) {
    _cartItems.removeWhere(
      (item) => item.product.id == productId,
    );
  }

  @override
  void increaseQuantity(int productId) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index != -1) {
      final item = _cartItems[index];

      _cartItems[index] = item.copyWith(
        quantity: item.quantity + 1,
      );
    }
  }

  @override
  void decreaseQuantity(int productId) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index != -1) {
      final item = _cartItems[index];

      if (item.quantity > 1) {
        _cartItems[index] = item.copyWith(
          quantity: item.quantity - 1,
        );
      } else {
        _cartItems.removeAt(index);
      }
    }
  }

  @override
  void clearCart() {
    _cartItems.clear();
  }
}
