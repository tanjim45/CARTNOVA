import 'package:cartnova_app/features/products/domain/entities/product.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> getCartItems();

  void addToCart(Product product);

  void removeFromCart(int productId);

  void increaseQuantity(int productId);

  void decreaseQuantity(int productId);

  void clearCart();
}
