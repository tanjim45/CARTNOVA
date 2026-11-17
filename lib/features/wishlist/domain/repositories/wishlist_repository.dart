import 'package:cartnova_app/features/products/domain/entities/product.dart';



abstract class WishlistRepository {
  Future<List<Product>> getWishlist();

  Future<void> addToWishlist(Product product);

  Future<void> removeFromWishlist(int productId);

  Future<bool> isWishlisted(int productId);

  Future<void> clearWishlist();
}