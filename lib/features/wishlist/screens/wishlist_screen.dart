
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          wishlistState.when(
            data: (products) => products.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear Wishlist',
                    onPressed: () => _showClearConfirmation(context, ref),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _ErrorWishlist(
          onRetry: () {
            ref.read(wishlistProvider.notifier).loadWishlist();
          },
        ),
        data: (products) {
          if (products.isEmpty) {
            return const _EmptyWishlist();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;

              return ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 16,
                  vertical: 22,
                ),
                children: [
                  _WishlistHeader(
                    count: products.length,
                    colors: colors,
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: isWide
                          ? _buildGrid(products, constraints.maxWidth)
                          : Column(
                              children: products.map((product) {
                                return _WishlistProductCard(
                                  product: product,
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<dynamic> products, double availableWidth) {
    final cardWidth = (availableWidth - 64).clamp(0.0, 1050.0);
    final columns = cardWidth >= 900 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 330,
      ),
      itemBuilder: (context, index) {
        return _WishlistGridCard(product: products[index]);
      },
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          size: 35,
        ),
        title: const Text('Clear Wishlist?'),
        content: const Text(
          'Are you sure you want to remove all wishlist products?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).clearWishlist();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _WishlistHeader extends StatelessWidget {
  final int count;
  final ColorScheme colors;

  const _WishlistHeader({
    required this.count,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: colors.onPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Favorites',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$count products saved for later',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistProductCard extends ConsumerWidget {
  final dynamic product;

  const _WishlistProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _ProductImage(
              imageUrl: product.thumbnail,
              width: 110,
              height: 125,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _ProductInformation(
                product: product,
                onAddToCart: () => _addToCart(context, ref),
                onRemove: () => _removeFromWishlist(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).addToCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFromWishlist(BuildContext context, WidgetRef ref) {
    ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from wishlist'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _WishlistGridCard extends ConsumerWidget {
  final dynamic product;

  const _WishlistGridCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _ProductImage(
                      imageUrl: product.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filledTonal(
                      tooltip: 'Remove from Wishlist',
                      onPressed: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .removeFromWishlist(product.id);
                      },
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.category.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade700,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(product);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 16,
                ),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  final dynamic product;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  const _ProductInformation({
    required this.product,
    required this.onAddToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.amber.shade700,
              size: 17,
            ),
            const SizedBox(width: 4),
            Text(
              product.rating.toStringAsFixed(1),
              style: TextStyle(
                color: colors.secondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: colors.primary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            FilledButton.tonalIcon(
              onPressed: onAddToCart,
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 16,
              ),
              label: const Text('Add to Cart'),
            ),
            IconButton.filledTonal(
              tooltip: 'Remove from Wishlist',
              onPressed: onRemove,
              icon: const Icon(
                Icons.favorite_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _ProductImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (_, _) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (_, _, _) => Icon(
            Icons.image_not_supported_outlined,
            color: colors.outline,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _ErrorWishlist extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorWishlist({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load wishlist',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 65,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Your Wishlist is Empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Save your favorite products here and find them easily later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.secondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
