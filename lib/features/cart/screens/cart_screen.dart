
import 'package:cartnova_app/features/checkout/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: colors.outline,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Looks like you haven\'t added anything yet.',
                    style: TextStyle(color: colors.secondary),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                final cartList = ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item.product;

                    return Card(
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
                                fit: BoxFit.contain,
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        visualDensity:
                                            VisualDensity.compact,
                                        onPressed: () {
                                          cartNotifier.decreaseQuantity(
                                            product.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity:
                                            VisualDensity.compact,
                                        onPressed: () {
                                          cartNotifier.increaseQuantity(
                                            product.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: 'Remove',
                                        onPressed: () {
                                          cartNotifier.removeFromCart(
                                            product.id,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colors.error,
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

                final summary = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SummaryRow(
                          title: 'Total Items',
                          value: '${cartNotifier.totalItems}',
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          title: 'Subtotal',
                          value:
                              '\$${cartNotifier.subtotal.toStringAsFixed(2)}',
                        ),
                        const Divider(height: 28),
                        _SummaryRow(
                          title: 'Total',
                          value:
                              '\$${cartNotifier.subtotal.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                            child: const Text('Proceed to Checkout'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: cartNotifier.clearCart,
                            child: Text(
                              'Clear Cart',
                              style: TextStyle(color: colors.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cartList),
                      SizedBox(
                        width: 350,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: summary,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(child: cartList),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: summary,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 19 : 15,
          ),
        ),
      ],
    );
  }
}
