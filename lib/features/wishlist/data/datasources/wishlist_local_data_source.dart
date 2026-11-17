import 'package:cartnova_app/features/products/data/models/product_model.dart';
import 'package:hive/hive.dart';
import '../../../../core/database/hive_database.dart';


class WishlistLocalDataSource {
  static const String _boxName = 'wishlist';

  Future<Box> get _box async {
    return HiveDatabase.openBox(_boxName);
  }

  Future<List<ProductModel>> getWishlist() async {
    final box = await _box;

    return box.values.map((value) {
      return ProductModel.fromJson(
        Map<String, dynamic>.from(value as Map),
      );
    }).toList();
  }

  Future<void> addToWishlist(ProductModel product) async {
    final box = await _box;

    await box.put(product.id, {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'category': product.category,
      'brand': product.brand,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'rating': product.rating,
      'stock': product.stock,
      'thumbnail': product.thumbnail,
      'images': product.images,
    });
  }

  Future<void> removeFromWishlist(int productId) async {
    final box = await _box;
    await box.delete(productId);
  }

  Future<bool> isWishlisted(int productId) async {
    final box = await _box;
    return box.containsKey(productId);
  }

  Future<void> clearWishlist() async {
    final box = await _box;
    await box.clear();
  }
}
