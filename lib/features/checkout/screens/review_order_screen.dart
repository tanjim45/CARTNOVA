
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../providers/order_provider.dart';

class ReviewOrderScreen extends ConsumerStatefulWidget {
  const ReviewOrderScreen({
    super.key,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
  });

  final String customerName;
  final String phone;
  final String address;
  final String paymentMethod;

  @override
  ConsumerState<ReviewOrderScreen> createState() =>
      _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends ConsumerState<ReviewOrderScreen> {
  static const double deliveryCharge = 60.0;

  bool _isConfirming = false;

  Future<void> _confirmOrder() async {
    if (_isConfirming) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      // Only this button sends the order request to Laravel.
      await ref.read(checkoutProvider.notifier).placeOrder(
            customerName: widget.customerName,
            phone: widget.phone,
            address: widget.address,
            paymentMethod: widget.paymentMethod,
          );

      if (!mounted) return;

      // Clear local cart after successful API response.
      ref.read(cartProvider.notifier).clearLocalCart();

      ref.invalidate(orderHistoryProvider);
      ref.read(checkoutProvider.notifier).reset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your order has been placed successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isConfirming = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final colors = Theme.of(context).colorScheme;

    final subtotal = cartItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    final total = subtotal + deliveryCharge;

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Order')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 65,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your cart is empty.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Your Order',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fact_check_outlined,
                        color: colors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Almost Done!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Please review all details before confirming.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                _ReviewCard(
                  title: 'Delivery Information',
                  icon: Icons.local_shipping_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: 'Full Name',
                        value: widget.customerName,
                      ),
                      _DetailRow(
                        label: 'Phone Number',
                        value: widget.phone,
                      ),
                      _DetailRow(
                        label: 'Delivery Address',
                        value: widget.address,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _ReviewCard(
                  title: 'Payment Method',
                  icon: Icons.payment_rounded,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: colors.primary,
                        size: 25,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.paymentMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _ReviewCard(
                  title: 'Products (${cartItems.length})',
                  icon: Icons.shopping_bag_outlined,
                  child: Column(
                    children: cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.thumbnail,
                                  fit: BoxFit.contain,
                                  placeholder: (_, _) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, _, _) => const Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: TextStyle(
                                      color: colors.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 18),

                _ReviewCard(
                  title: 'Payment Summary',
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: [
                      _PriceRow(
                        label: 'Subtotal',
                        value: '\$${subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 14),
                      _PriceRow(
                        label: 'Delivery Charge',
                        value: '\$${deliveryCharge.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colors.outlineVariant),
                      const SizedBox(height: 12),
                      _PriceRow(
                        label: 'Grand Total',
                        value: '\$${total.toStringAsFixed(2)}',
                        bold: true,
                        valueColor: colors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: _isConfirming ? null : _confirmOrder,
                    icon: _isConfirming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _isConfirming
                          ? 'Placing Your Order...'
                          : 'Confirm Order',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isConfirming
                        ? null
                        : () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Checkout'),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary, size: 23),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.secondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? colors.onSurface : colors.secondary,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.onSurface,
            fontSize: bold ? 19 : 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
