import 'package:cartnova_app/features/products/data/models/product_model.dart';
import 'package:cartnova_app/features/products/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource localDataSource;

  WishlistRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getWishlist() async {
    return localDataSource.getWishlist();
  }

  @override
  Future<void> addToWishlist(Product product) async {
    final productModel = ProductModel.fromJson({
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

    await localDataSource.addToWishlist(productModel);
  }

  @override
  Future<void> removeFromWishlist(int productId) async {
    await localDataSource.removeFromWishlist(productId);
  }

  @override
  Future<bool> isWishlisted(int productId) async {
    return localDataSource.isWishlisted(productId);
  }

  @override
  Future<void> clearWishlist() async {
    await localDataSource.clearWishlist();
  }
}
