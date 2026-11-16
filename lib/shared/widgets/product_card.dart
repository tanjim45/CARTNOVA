import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviewCount;
  final bool isWishlisted;

  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistTap,
    this.onAddToCart,
  });

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'en_BD',
      symbol: '৳',
      decimalDigits: 2,
    ).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hasDiscount = oldPrice != null && oldPrice! > price;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              AspectRatio(
                aspectRatio: 1.15,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: colors.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        padding: const EdgeInsets.all(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Icon(
                              Icons.image_not_supported_outlined,
                              size: 38,
                              color: colors.onSurfaceVariant,
                            );
                          },
                        ),
                      ),
                    ),

                    // Discount Badge
                    if (hasDiscount)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${(((oldPrice! - price) / oldPrice!) * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: colors.surface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onWishlistTap,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isWishlisted
                                  ? AppColors.error
                                  : colors.onSurfaceVariant,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product Information
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '($reviewCount)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Price and Cart Button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedPrice,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  NumberFormat.currency(
                                    locale: 'en_BD',
                                    symbol: '৳',
                                    decimalDigits: 0,
                                  ).format(oldPrice),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    decoration:
                                        TextDecoration.lineThrough,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        Material(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(11),
                          child: InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(11),
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
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
      ),
    );
  }
}
