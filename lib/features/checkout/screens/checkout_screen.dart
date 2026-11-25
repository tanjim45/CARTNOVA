import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartnova_app/features/cart/providers/cart_provider.dart';
import 'package:cartnova_app/features/checkout/providers/address_provider.dart';
import 'package:cartnova_app/features/checkout/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  static const double deliveryCharge = 60.0;

  String _selectedPaymentMethod = 'Cash on Delivery';

  int? _savedAddressId;
  bool _isSavingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final addresses = await ref.read(savedAddressesProvider.future);

      if (!mounted) return;

      if (addresses.isNotEmpty) {
        final savedAddress = addresses.first;

        _nameController.text = savedAddress.fullName;
        _phoneController.text = savedAddress.phone;
        _addressController.text = savedAddress.address;

        setState(() {
          _savedAddressId = savedAddress.id;
        });
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load saved address: $error')),
      );
    }
  }

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
      if (previous?.isLoading == true && next.valueOrNull != null) {
        ref.invalidate(orderHistoryProvider);
      }
    });

    final cartItems = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 60,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Your Cart is Empty',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'Add some products before checkout.',
                style: TextStyle(color: colors.secondary),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      );
    }

    final subtotal = cartItems.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    final total = subtotal + deliveryCharge;
    final isLoading = checkoutState.isLoading || _isSavingAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          final formSection = _buildDeliveryForm(colors);
          final paymentSection = _buildPaymentMethods(colors);

          final summarySection = _buildOrderSummary(
            cartItems: cartItems,
            subtotal: subtotal,
            total: total,
            colors: colors,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 30 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Almost There!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Complete your details and confirm your order.',
                      style: TextStyle(color: colors.secondary, fontSize: 14),
                    ),
                    const SizedBox(height: 26),
                    _CheckoutProgress(colors: colors),
                    const SizedBox(height: 30),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                formSection,
                                const SizedBox(height: 22),
                                paymentSection,
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(flex: 5, child: summarySection),
                        ],
                      )
                    else
                      Column(
                        children: [
                          formSection,
                          const SizedBox(height: 22),
                          paymentSection,
                          const SizedBox(height: 22),
                          summarySection,
                        ],
                      ),
                    if (checkoutState.hasError) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: colors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                checkoutState.error.toString(),
                                style: TextStyle(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 59,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _placeOrder,
                        icon: isLoading
                            ? const SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.lock_outline_rounded),
                        label: Text(
                          isLoading
                              ? 'Placing Your Order...'
                              : 'Confirm & Place Order',
                          style: const TextStyle(
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
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: colors.secondary,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'Your order information is securely saved.',
                              style: TextStyle(
                                color: colors.secondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryForm(ColorScheme colors) {
    return _SectionCard(
      title: 'Delivery Information',
      subtitle: 'Where should we deliver your order?',
      icon: Icons.local_shipping_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _CheckoutTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline_rounded,
              capitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 19),
            _CheckoutTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '01XXXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length < 11) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 19),
            _CheckoutTextField(
              controller: _addressController,
              label: 'Delivery Address',
              hint: 'House, Road, Area, City...',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              capitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please provide an accurate address for smooth delivery.',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(ColorScheme colors) {
    final methods = [
      {
        'name': 'Cash on Delivery',
        'subtitle': 'Pay when your order arrives',
        'icon': Icons.money_rounded,
      },
      {
        'name': 'Credit / Debit Card',
        'subtitle': 'Visa, Mastercard and more',
        'icon': Icons.credit_card_rounded,
      },
      {
        'name': 'bKash / Nagad',
        'subtitle': 'Mobile banking payment',
        'icon': Icons.account_balance_wallet_rounded,
      },
    ];

    return _SectionCard(
      title: 'Payment Method',
      subtitle: 'Choose how you want to pay',
      icon: Icons.payment_rounded,
      child: Column(
        children: methods.map((method) {
          final selected = _selectedPaymentMethod == method['name'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method['name'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer.withValues(alpha: 0.5)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selected ? colors.primary : colors.outlineVariant,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      color: colors.primary,
                      size: 25,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? colors.primary : colors.outline,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderSummary({
    required List<dynamic> cartItems,
    required double subtotal,
    required double total,
    required ColorScheme colors,
  }) {
    return _SectionCard(
      title: 'Order Summary',
      subtitle: '${cartItems.length} different products',
      icon: Icons.receipt_long_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cartItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: CachedNetworkImage(
                        imageUrl: item.product.thumbnail,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
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
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Qty: ${item.quantity}',
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
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 16),
          _SummaryRow(
            title: 'Subtotal',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            title: 'Delivery Charge',
            value: '\$${deliveryCharge.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 18),
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(17),
            ),
            child: _SummaryRow(
              title: 'Grand Total',
              value: '\$${total.toStringAsFixed(2)}',
              isBold: true,
              valueColor: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSavingAddress) return;

    setState(() {
      _isSavingAddress = true;
    });

    final fullName = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    try {
      final addressRepository = ref.read(savedAddressRepositoryProvider);

      if (_savedAddressId == null) {
        final savedAddress = await addressRepository.saveAddress(
          fullName: fullName,
          phone: phone,
          address: address,
        );

        _savedAddressId = savedAddress.id;
      } else {
        await addressRepository.updateAddress(
          id: _savedAddressId!,
          fullName: fullName,
          phone: phone,
          address: address,
        );
      }

      ref.invalidate(savedAddressesProvider);

      if (!mounted) return;

      setState(() {
        _isSavingAddress = false;
      });

      context.push(
        '/review-order',
        extra: {
          'customerName': fullName,
          'phone': phone,
          'address': address,
          'paymentMethod': _selectedPaymentMethod,
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSavingAddress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save address: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CheckoutProgress extends StatelessWidget {
  final ColorScheme colors;

  const _CheckoutProgress({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProgressStep(
          number: '1',
          label: 'Cart',
          completed: true,
          colors: colors,
        ),
        Expanded(child: Container(height: 2, color: colors.primary)),
        _ProgressStep(
          number: '2',
          label: 'Checkout',
          active: true,
          colors: colors,
        ),
        Expanded(child: Container(height: 2, color: colors.outlineVariant)),
        _ProgressStep(number: '3', label: 'Complete', colors: colors),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String number;
  final String label;
  final bool completed;
  final bool active;
  final ColorScheme colors;

  const _ProgressStep({
    required this.number,
    required this.label,
    required this.colors,
    this.completed = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = completed || active;

    return Column(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: highlighted
                ? colors.primary
                : colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check_rounded, color: colors.onPrimary, size: 20)
                : Text(
                    number,
                    style: TextStyle(
                      color: active
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: highlighted ? colors.primary : colors.secondary,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CheckoutTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextCapitalization capitalization;
  final String? Function(String?) validator;

  const _CheckoutTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: capitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 38 : 0),
          child: Icon(icon),
        ),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.secondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isBold ? colors.onSurface : colors.secondary,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: isBold ? 19 : 14,
          ),
        ),
      ],
    );
  }
}
