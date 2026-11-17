
import 'package:cartnova_app/features/cart/providers/cart_provider.dart';
import 'package:cartnova_app/features/checkout/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(checkoutProvider, (previous, next) {
  if (previous?.isLoading == true &&
      next.valueOrNull != null) {
    ref.invalidate(orderHistoryProvider);
  }
});
    final cartItems = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    final order = checkoutState.valueOrNull;

    if (order != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Placed')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Order ID: ${order.id}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(checkoutProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subtotal = cartItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    const deliveryCharge = 60.0;
    final total = subtotal + deliveryCharge;

    final isLoading = checkoutState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.trim().length < 11) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Delivery Address',
                                prefixIcon: Icon(Icons.location_on_outlined),
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your address';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...cartItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.title} × ${item.quantity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 28),

                      _SummaryRow(
                        title: 'Subtotal',
                        value: '\$${subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        title: 'Delivery Charge',
                        value: '\$${deliveryCharge.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 28),
                      _SummaryRow(
                        title: 'Total',
                        value: '\$${total.toStringAsFixed(2)}',
                        isBold: true,
                      ),

                      if (checkoutState.hasError) ...[
                        const SizedBox(height: 16),
                        Text(
                          checkoutState.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    ref
                                        .read(checkoutProvider.notifier)
                                        .placeOrder(
                                          customerName:
                                              _nameController.text.trim(),
                                          phone:
                                              _phoneController.text.trim(),
                                          address:
                                              _addressController.text.trim(),
                                        );
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Place Order',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            fontSize: isBold ? 17 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
