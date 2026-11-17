
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartnova_app/features/cart/providers/cart_provider.dart';
import 'package:cartnova_app/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/product.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends ConsumerState<ProductDetailsScreen> {
  int quantity = 1;
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final wishlistState = ref.watch(wishlistProvider);

    final isWishlisted = wishlistState.valueOrNull?.any(
          (item) => item.id == product.id,
        ) ??
        false;

    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];

    final isInStock = product.stock > 0;
    final isWide = MediaQuery.sizeOf(context).width >= 850;

    final imageSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isWide ? 0.95 : 1.05,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: CachedNetworkImage(
                    imageUrl: images[selectedImageIndex],
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (_, _, _) => Icon(
                      Icons.image_not_supported_outlined,
                      size: 65,
                      color: colors.secondary,
                    ),
                  ),
                ),
              ),
              if (product.discountPercentage > 0)
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${selectedImageIndex + 1} / ${images.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 18),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final selected = selectedImageIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedImageIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 82,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: selected
                            ? colors.primary
                            : colors.outlineVariant,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const Icon(
                          Icons.image_not_supported_outlined,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );

    final detailsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  product.category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (product.brand.isNotEmpty)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 17,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 22,
            ),
            const SizedBox(width: 5),
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Product Rating',
              style: TextStyle(
                color: colors.secondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Price section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OUR PRICE',
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 7,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (product.discountPercentage > 0) ...[
                    Text(
                      '\$${product.oldPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colors.secondary,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Save ${product.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        // Description
        Text(
          'Product Description',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.8,
            color: colors.secondary,
          ),
        ),
        const SizedBox(height: 24),

        // Stock status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isInStock
                ? Colors.green.withValues(alpha: 0.09)
                : colors.errorContainer,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isInStock
                  ? Colors.green.withValues(alpha: 0.2)
                  : colors.error.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isInStock
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: isInStock ? Colors.green : colors.error,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isInStock
                      ? 'In Stock • ${product.stock} items available'
                      : 'Currently Out of Stock',
                  style: TextStyle(
                    color: isInStock ? Colors.green : colors.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        // Quantity selector
        Text(
          'Select Quantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 55,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: quantity < product.stock
                    ? () => setState(() => quantity++)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // Add to cart
        SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton.icon(
            onPressed: isInStock ? _addToCart : null,
            icon: const Icon(Icons.shopping_bag_rounded),
            label: const Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 19,
              color: colors.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Fast & Reliable Delivery',
              style: TextStyle(
                color: colors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isWishlisted ? 'Remove Wishlist' : 'Add Wishlist',
            onPressed: _toggleWishlist,
            icon: Icon(
              isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isWishlisted ? Colors.red : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: imageSection),
                      const SizedBox(width: 44),
                      Expanded(child: detailsSection),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageSection,
                      const SizedBox(height: 30),
                      detailsSection,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleWishlist() async {
    final product = widget.product;
    final notifier = ref.read(wishlistProvider.notifier);
    final current = ref.read(wishlistProvider).valueOrNull;

    final isWishlisted =
        current?.any((item) => item.id == product.id) ?? false;

    if (isWishlisted) {
      await notifier.removeFromWishlist(product.id);
    } else {
      await notifier.addToWishlist(product);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWishlisted ? 'Removed from Wishlist' : 'Added to Wishlist',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart() {
    ref.read(cartProvider.notifier).addToCart(
          widget.product,
          quantity: quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added to cart successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
