
import 'package:cartnova_app/features/products/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/wishlist_local_data_source.dart';
import '../data/repositories/wishlist_repository_impl.dart';
import '../domain/repositories/wishlist_repository.dart';

final wishlistLocalDataSourceProvider =
    Provider<WishlistLocalDataSource>((ref) {
  return WishlistLocalDataSource();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final dataSource = ref.watch(wishlistLocalDataSourceProvider);

  return WishlistRepositoryImpl(
    localDataSource: dataSource,
  );
});

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<Product>>>(
  (ref) {
    final repository = ref.watch(wishlistRepositoryProvider);

    return WishlistNotifier(repository);
  },
);

class WishlistNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final WishlistRepository _repository;

  WishlistNotifier(this._repository) : super(const AsyncLoading()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      final products = await _repository.getWishlist();
      state = AsyncData(products);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addToWishlist(Product product) async {
    try {
      await _repository.addToWishlist(product);
      await loadWishlist();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      await _repository.removeFromWishlist(productId);
      await loadWishlist();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<bool> isWishlisted(int productId) async {
    return _repository.isWishlisted(productId);
  }

  Future<void> clearWishlist() async {
    try {
      await _repository.clearWishlist();
      state = const AsyncData([]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
