import 'package:cartnova_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../features/products/providers/product_provider.dart';
import '../../../../shared/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final colors = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CartNova',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
          actions: [
    PopupMenuButton<ThemeMode>(
      tooltip: 'Change Theme',
      icon: Icon(
        themeMode == ThemeMode.dark
            ? Icons.dark_mode_rounded
            : themeMode == ThemeMode.light
                ? Icons.light_mode_rounded
                : Icons.brightness_auto_rounded,
      ),
      onSelected: (mode) {
        ref.read(themeProvider.notifier).changeTheme(mode);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(Icons.light_mode_rounded),
              SizedBox(width: 12),
              Text('Light Mode'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(Icons.dark_mode_rounded),
              SizedBox(width: 12),
              Text('Dark Mode'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(Icons.brightness_auto_rounded),
              SizedBox(width: 12),
              Text('System Default'),
            ],
          ),
        ),
      ],
    ),
    IconButton(
      onPressed: () {
        ref.invalidate(productsProvider);
      },
      icon: const Icon(Icons.refresh_rounded),
      tooltip: 'Refresh Products',
    ),
  ],

        ),



      body: RefreshIndicator(
       onRefresh: () async {
          await ref.read(productsProvider.future);
          ref.invalidate(productsProvider);
        },
        child: productsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 55,
                          color: colors.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Something went wrong!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
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
              ),
            ],
          ),
          data: (products) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          Responsive.horizontalPadding(context),
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Products',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find something you will love.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Popular Products',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${products.length} items',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        Responsive.horizontalPadding(context),
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];

                        return ProductCard(
                          title: product.title,
                          category: product.category,
                          imageUrl: product.thumbnail,
                          price: product.price,
                          oldPrice: product.oldPrice,
                          rating: product.rating,
                          onTap: () {},
                          onWishlistTap: () {},
                          onAddToCart: () {},
                        );
                      },
                      childCount: products.length,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          Responsive.gridColumns(context),
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
      ),
    );
  }
}
