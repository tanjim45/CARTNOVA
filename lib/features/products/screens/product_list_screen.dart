import 'package:cartnova_app/features/products/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/product_card.dart';
import '../providers/product_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../cart/providers/cart_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOption = 'Default';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final wishlistState = ref.watch(wishlistProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () async {
        ref.invalidate(productsProvider);
        await ref.read(productsProvider.future);
      },
      child: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 55,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    const Text('Something went wrong!'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(productsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        data: (products) {
          final categories = [
            'All',
            ...products.map((product) => product.category).toSet().toList()
              ..sort(),
          ];

          var filteredProducts = products.where((product) {
            final query = _searchQuery.toLowerCase();

            final matchesSearch =
                product.title.toLowerCase().contains(query) ||
                product.brand.toLowerCase().contains(query);

            final matchesCategory =
                _selectedCategory == 'All' ||
                product.category == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          switch (_sortOption) {
            case 'Price: Low to High':
              filteredProducts.sort((a, b) => a.price.compareTo(b.price));
              break;
            case 'Price: High to Low':
              filteredProducts.sort((a, b) => b.price.compareTo(a.price));
              break;
            case 'Top Rated':
              filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
              break;
          }

          final featuredProducts = products.take(5).toList();

          final isSearching =
              _searchQuery.isNotEmpty || _selectedCategory != 'All';

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.horizontalPadding(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),

                      // Welcome Section
                      Text(
                        'Discover',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find products you will love.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Premium Promotional Banner
                      if (!isSearching) _buildHeroBanner(context),

                      if (!isSearching) const SizedBox(height: 28),

                      // Search Field
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products or brands...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                )
                              : null,
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Categories
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Shop by Category',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${categories.length} categories',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final selected = _selectedCategory == category;

                            return _CategoryItem(
                              category: category,
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      // Featured Products
                      if (!isSearching && featuredProducts.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Featured Products',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              'Top picks',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 295,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredProducts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final product = featuredProducts[index];

                              final isWishlisted =
                                  wishlistState.valueOrNull?.any(
                                    (item) => item.id == product.id,
                                  ) ??
                                  false;

                              return SizedBox(
                                width: 190,
                                child: ProductCard(
                                  title: product.title,
                                  category: product.category,
                                  imageUrl: product.thumbnail,
                                  price: product.price,
                                  oldPrice: product.oldPrice,
                                  rating: product.rating,
                                  isWishlisted: isWishlisted,
                                  onTap: () {
                                    _openProduct(context, product);
                                  },
                                  onWishlistTap: () async {
                                    await _toggleWishlist(
                                      product,
                                      isWishlisted,
                                    );
                                  },
                                  onAddToCart: () {
                                    _addToCart(product);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // All Products Heading
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isSearching
                                  ? 'Search Results'
                                  : 'Explore All Products',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${filteredProducts.length} items',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Sort
                      Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 19,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text('Sort by', style: theme.textTheme.bodyMedium),
                          const Spacer(),
                          DropdownButton<String>(
                            value: _sortOption,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(14),
                            items: const [
                              DropdownMenuItem(
                                value: 'Default',
                                child: Text('Default'),
                              ),
                              DropdownMenuItem(
                                value: 'Price: Low to High',
                                child: Text('Price: Low to High'),
                              ),
                              DropdownMenuItem(
                                value: 'Price: High to Low',
                                child: Text('Price: High to Low'),
                              ),
                              DropdownMenuItem(
                                value: 'Top Rated',
                                child: Text('Top Rated'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortOption = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Product Grid
              if (filteredProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 65,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                              _sortOption = 'Default';
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.horizontalPadding(context),
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = filteredProducts[index];

                      final isWishlisted =
                          wishlistState.valueOrNull?.any(
                            (item) => item.id == product.id,
                          ) ??
                          false;

                      return ProductCard(
                        title: product.title,
                        category: product.category,
                        imageUrl: product.thumbnail,
                        price: product.price,
                        oldPrice: product.oldPrice,
                        rating: product.rating,
                        isWishlisted: isWishlisted,
                        onTap: () {
                          _openProduct(context, product);
                        },
                        onWishlistTap: () async {
                          await _toggleWishlist(product, isWishlisted);
                        },
                        onAddToCart: () {
                          _addToCart(product);
                        },
                      );
                    }, childCount: filteredProducts.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.gridColumns(context),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      childAspectRatio: Responsive.isMobile(context)
                          ? 0.58
                          : Responsive.isTablet(context)
                          ? 0.68
                          : 0.75,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 35)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.75),
            const Color(0xFF7655C8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: 0,
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 115,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'YOUR NEXT FAVORITE FIND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Discover More.\nShop Smarter.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Explore products picked for your lifestyle.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Explore Collection  →',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
  }

  Future<void> _toggleWishlist(dynamic product, bool isWishlisted) async {
    final notifier = ref.read(wishlistProvider.notifier);

    if (isWishlisted) {
      await notifier.removeFromWishlist(product.id);
    } else {
      await notifier.addToWishlist(product);
    }
  }

  void _addToCart(dynamic product) {
    ref.read(cartProvider.notifier).addToCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to Cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final String category;
  final bool selected;
  final VoidCallback onTap;

  IconData get categoryIcon {
    if (category == 'All') return Icons.grid_view_rounded;

    final value = category.toLowerCase();

    if (value.contains('beauty') || value.contains('skin')) {
      return Icons.spa_outlined;
    }
    if (value.contains('phone') || value.contains('mobile')) {
      return Icons.smartphone_rounded;
    }
    if (value.contains('laptop') || value.contains('computer')) {
      return Icons.laptop_mac_rounded;
    }
    if (value.contains('furniture') || value.contains('home')) {
      return Icons.chair_outlined;
    }
    if (value.contains('watch')) return Icons.watch_outlined;
    if (value.contains('shirt') || value.contains('cloth')) {
      return Icons.checkroom_outlined;
    }
    if (value.contains('shoe')) return Icons.category_rounded;
    if (value.contains('bag')) return Icons.shopping_bag_outlined;

    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: selected
                    ? colors.primary
                    : colors.surfaceContainerHighest.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                categoryIcon,
                color: selected ? Colors.white : colors.onSurfaceVariant,
                size: 25,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              category == 'All' ? 'All' : category.replaceAll('-', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
