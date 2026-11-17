import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartnova_app/features/cart/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wishlist_provider.dart';


class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          wishlistState.when(
            data: (products) => products.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear Wishlist',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _showClearConfirmation(context, ref);
                    },
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: wishlistState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load wishlist'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(wishlistProvider.notifier).loadWishlist();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 75,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Wishlist is Empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Save your favorite products here.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.thumbnail,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const SizedBox(
                            width: 90,
                            height: 90,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const SizedBox(
                            width: 90,
                            height: 90,
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addToCart(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart'),
                                      ),
                                    );
                                  },
                                  child: const Text('Add to Cart'),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    ref
                                        .read(wishlistProvider.notifier)
                                        .removeFromWishlist(product.id);
                                  },
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Wishlist?'),
        content: const Text(
          'Are you sure you want to remove all wishlist products?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).clearWishlist();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
