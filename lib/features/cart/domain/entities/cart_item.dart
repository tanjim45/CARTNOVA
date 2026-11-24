
import 'package:cartnova_app/features/products/domain/entities/product.dart';

class CartItem {
  final int cartItemId;
  final Product product;
  final int quantity;

  const CartItem({
    required this.cartItemId,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    int? cartItemId,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
