
import 'package:cartnova_app/features/checkout/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const double deliveryCharge = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    final subtotal = cartNotifier.subtotal;
    final total = subtotal + deliveryCharge;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: cartItems.isEmpty
          ? _EmptyCart(colors: colors)
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                final cartList = ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final product = item.product;

                    return Card(
                      elevation: 0,
                      color: colors.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 100,
                                height: 110,
                                color: colors.surfaceContainerHighest,
                                child: CachedNetworkImage(
                                  imageUrl: product.thumbnail,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, _, _) => const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.category.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _QuantityButton(
                                        icon: Icons.remove,
                                        onTap: () {
                                          cartNotifier.decreaseQuantity(
                                            product.id,
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      _QuantityButton(
                                        icon: Icons.add,
                                        onTap: () {
                                          cartNotifier.increaseQuantity(
                                            product.id,
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: 'Remove item',
                                        onPressed: () {
                                          cartNotifier.removeFromCart(
                                            product.id,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
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

                final summary = _OrderSummary(
                  itemCount: cartNotifier.totalItems,
                  subtotal: subtotal,
                  deliveryCharge: deliveryCharge,
                  total: total,
                  onCheckout: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    );
                  },
                  onClearCart: cartNotifier.clearCart,
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cartList),
                      SizedBox(
                        width: 360,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
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

class _EmptyCart extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyCart({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 90,
              color: colors.outline,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(icon, size: 17),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int itemCount;
  final double subtotal;
  final double deliveryCharge;
  final double total;
  final VoidCallback onCheckout;
  final VoidCallback onClearCart;

  const _OrderSummary({
    required this.itemCount,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
    required this.onCheckout,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
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
              value: '$itemCount',
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              title: 'Subtotal',
              value: '\$${subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              title: 'Delivery Charge',
              value: '\$${deliveryCharge.toStringAsFixed(2)}',
            ),
            const Divider(height: 30),
            _SummaryRow(
              title: 'Total',
              value: '\$${total.toStringAsFixed(2)}',
              isBold: true,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onClearCart,
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
