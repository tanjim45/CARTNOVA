
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
      decimalDigits: 0,
    ).format(price);
  }

  String formatOldPrice() {
    return NumberFormat.currency(
      locale: 'en_BD',
      symbol: '৳',
      decimalDigits: 0,
    ).format(oldPrice);
  }

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        padding: const EdgeInsets.all(13),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) {
                            return Center(
                              child: Container(
                                width: 35,
                                height: 35,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.primary,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 38,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Image unavailable',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
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
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '$discountPercentage% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist Button
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Material(
                        color: colors.surface,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          onTap: onWishlistTap,
                          customBorder: const CircleBorder(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(9),
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
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        category.replaceAll('-', ' ').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          fontSize: 9,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Product Name
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 7),

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 17,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '($reviewCount reviews)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price and Cart Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formattedPrice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                if (hasDiscount)
                                  Text(
                                    formatOldPrice(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: colors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 5),

                          Material(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(11),
                            child: InkWell(
                              onTap: onAddToCart,
                              borderRadius: BorderRadius.circular(11),
                              child: const SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
