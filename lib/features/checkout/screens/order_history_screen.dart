
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/entities/order.dart';
import '../providers/order_provider.dart';
import '../../orders/screens/order_tracking_screen.dart';

enum OrderFilter {
  all,
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  OrderFilter _selectedFilter = OrderFilter.all;
  bool _newestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Order> _filterOrders(List<Order> orders) {
    final searchText = _searchController.text.trim().toLowerCase();

    final filteredOrders = orders.where((order) {
      final matchesSearch =
          order.id.toLowerCase().contains(searchText);

      final matchesStatus = _selectedFilter == OrderFilter.all ||
          order.status.name == _selectedFilter.name;

      return matchesSearch && matchesStatus;
    }).toList();

    filteredOrders.sort((a, b) {
      return _newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt);
    });

    return filteredOrders;
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(orderHistoryProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Orders',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorOrders(
          onRetry: () => ref.invalidate(orderHistoryProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const _EmptyOrders();
          }

          final filteredOrders = _filterOrders(orders);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderHistoryProvider);
              await ref.read(orderHistoryProvider.future);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 40 : 18,
                    vertical: 24,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OrderHeader(count: orders.length),
                            const SizedBox(height: 24),

                            // Search
                            TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search by Order ID...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                ),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {});
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                            ),
                                          )
                                        : null,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Filter heading
                            Row(
                              children: [
                                const Icon(Icons.filter_list_rounded),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Filter Orders',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${filteredOrders.length} found',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Status filters
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: OrderFilter.values.map((filter) {
                                final selected =
                                    _selectedFilter == filter;

                                return FilterChip(
                                  label: Text(
                                    filter.name == 'all'
                                        ? 'All'
                                        : filter.name.toUpperCase(),
                                  ),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 18),

                            // Date sorting
                            Row(
                              children: [
                                const Icon(
                                  Icons.sort_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Sort by Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                DropdownButton<bool>(
                                  value: _newestFirst,
                                  underline: const SizedBox(),
                                  borderRadius: BorderRadius.circular(14),
                                  items: const [
                                    DropdownMenuItem(
                                      value: true,
                                      child: Text('Newest First'),
                                    ),
                                    DropdownMenuItem(
                                      value: false,
                                      child: Text('Oldest First'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _newestFirst = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            if (filteredOrders.isEmpty)
                              const _NoMatchingOrders()
                            else
                              ...filteredOrders.map(
                                (order) => _OrderCard(order: order),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final int count;

  const _OrderHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Purchases',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep track of all your shopping activity.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '$count ${count == 1 ? 'Order' : 'Orders'} Placed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.receipt_long_rounded,
            size: 65,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _statusColor() {
    switch (order.status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Future<void> _cancelOrder(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 38,
          ),
          title: const Text('Cancel Order?'),
          content: const Text(
            'Are you sure you want to cancel this order? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Order'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(cancelOrderProvider).call(order.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to cancel order: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor();
    final isPending = order.status == OrderStatus.pending;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: colors.primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _OrderInfoLine(
              icon: Icons.tag_rounded,
              text: 'Order ID: ${order.id}',
            ),
            const SizedBox(height: 10),
            _OrderInfoLine(
              icon: Icons.calendar_today_rounded,
              text: DateFormat('dd MMM yyyy, hh:mm a')
                  .format(order.createdAt),
            ),
            const SizedBox(height: 10),
            _OrderInfoLine(
              icon: Icons.payment_rounded,
              text: 'Payment: ${order.paymentMethod}',
            ),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: colors.secondary,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${order.items.length} products',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: colors.surface,
                    builder: (_) => _OrderDetailsSheet(order: order),
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                ),
                label: const Text('View Order Details'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track Order'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelOrder(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
            if (isCancelled) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'This order has been cancelled.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OrderInfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 15, color: colors.secondary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailsSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Order ID: ${order.id}',
              style: TextStyle(
                color: colors.secondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              icon: Icons.person_outline_rounded,
              title: 'Customer Information',
              children: [
                _InfoRow(title: 'Name', value: order.customerName),
                _InfoRow(title: 'Phone', value: order.phone),
                _InfoRow(title: 'Address', value: order.address),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Purchased Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...order.items.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: CachedNetworkImage(
                        imageUrl: item.product.thumbnail,
                        width: 65,
                        height: 65,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => Container(
                          width: 65,
                          height: 65,
                          color: colors.surfaceContainerHighest,
                          child: const Icon(Icons.image_outlined),
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 65,
                          height: 65,
                          color: colors.surfaceContainerHighest,
                          child: const Icon(
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.receipt_outlined,
              title: 'Payment Summary',
              children: [
                _InfoRow(
                  title: 'Payment',
                  value: order.paymentMethod,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  title: 'Subtotal',
                  value: '\$${order.subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  title: 'Delivery',
                  value: '\$${order.deliveryCharge.toStringAsFixed(2)}',
                ),
                const Divider(height: 28),
                _DetailRow(
                  title: 'Total Amount',
                  value: '\$${order.total.toStringAsFixed(2)}',
                  bold: true,
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Details'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _DetailRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: bold ? 19 : 14,
            color: bold ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}

class _ErrorOrders extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorOrders({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 65,
              color: colors.error,
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load orders',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondary),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 65,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Your order history will appear here once you make your first purchase.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.secondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchingOrders extends StatelessWidget {
  const _NoMatchingOrders();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 65,
              color: colors.secondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Matching Orders',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try another Order ID or change the filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
