
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
  ConsumerState<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOption = 'Default';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final wishlistState = ref.watch(wishlistProvider);
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(productsProvider);
        await ref.read(productsProvider.future);
      },
      child: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => ListView(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 55),
                    const SizedBox(height: 16),
                    const Text('Something went wrong!'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(productsProvider);
                      },
                      child: const Text('Try Again'),
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
            final matchesSearch = product.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                product.brand.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );

            final matchesCategory = _selectedCategory == 'All' ||
                product.category == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          switch (_sortOption) {
            case 'Price: Low to High':
              filteredProducts.sort(
                (a, b) => a.price.compareTo(b.price),
              );
              break;
            case 'Price: High to Low':
              filteredProducts.sort(
                (a, b) => b.price.compareTo(a.price),
              );
              break;
            case 'Top Rated':
              filteredProducts.sort(
                (a, b) => b.rating.compareTo(a.rating),
              );
              break;
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(
                    Responsive.horizontalPadding(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover Products',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find something you will love.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),

                      // Search
                      TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products or brands...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Category Filter
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final selected =
                                _selectedCategory == category;

                            return ChoiceChip(
                              label: Text(
                                category == 'All'
                                    ? 'All'
                                    : category.replaceAll('-', ' '),
                              ),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Sorting and Result Count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${filteredProducts.length} Products Found',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DropdownButton<String>(
                            value: _sortOption,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(12),
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
                                setState(() => _sortOption = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Product Grid
              if (filteredProducts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 65,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: product,
                                ),
                              ),
                            );
                          },
                          onWishlistTap: () async {
                            final notifier =
                                ref.read(wishlistProvider.notifier);

                            if (isWishlisted) {
                              await notifier.removeFromWishlist(product.id);
                            } else {
                              await notifier.addToWishlist(product);
                            }
                          },
                          onAddToCart: () {
                            ref.read(cartProvider.notifier).addToCart(product);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to Cart'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.gridColumns(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.58,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }
}
