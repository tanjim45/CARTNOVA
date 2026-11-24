import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();

  Future<List<CartItem>> addToCart(
    int productId, {
    int quantity = 1,
  });

  Future<List<CartItem>> removeFromCart(int cartItemId);

  Future<List<CartItem>> updateQuantity(
    int cartItemId,
    int quantity,
  );

  Future<List<CartItem>> clearCart();
}
