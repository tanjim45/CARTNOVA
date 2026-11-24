
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CartItem>> getCartItems() {
    return remoteDataSource.getCartItems();
  }

  @override
  Future<List<CartItem>> addToCart(
    int productId, {
    int quantity = 1,
  }) {
    return remoteDataSource.addToCart(
      productId,
      quantity: quantity,
    );
  }

  @override
  Future<List<CartItem>> removeFromCart(int cartItemId) {
    return remoteDataSource.removeFromCart(cartItemId);
  }

  @override
  Future<List<CartItem>> updateQuantity(
    int cartItemId,
    int quantity,
  ) {
    return remoteDataSource.updateQuantity(
      cartItemId,
      quantity,
    );
  }

  @override
  Future<List<CartItem>> clearCart() {
    return remoteDataSource.clearCart();
  }
}
