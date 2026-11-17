
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/entities/order.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(orderHistoryProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 55,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                const Text('Unable to load orders'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(orderHistoryProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const _EmptyOrders();
          }

          final sortedOrders = [...orders]
            ..sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(orderHistoryProvider);
              await ref.read(orderHistoryProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                final order = sortedOrders[index];

                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({
    required this.order,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Order',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              'ID: ${order.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 8),

            Text(
              DateFormat('dd MMM yyyy, hh:mm a')
                  .format(order.createdAt),
              style: theme.textTheme.bodyMedium,
            ),

            const Divider(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} products',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return _OrderDetailsSheet(order: order);
                    },
                  );
                },
                child: const Text('View Order Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailsSheet({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              Text('Customer: ${order.customerName}'),
              const SizedBox(height: 8),
              Text('Phone: ${order.phone}'),
              const SizedBox(height: 8),
              Text('Address: ${order.address}'),

              const Divider(height: 30),

              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.product.title),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                  ),
                ),
              ),

              const Divider(height: 24),

              _DetailRow(
                title: 'Subtotal',
                value: '\$${order.subtotal.toStringAsFixed(2)}',
              ),
              _DetailRow(
                title: 'Delivery',
                value: '\$${order.deliveryCharge.toStringAsFixed(2)}',
              ),
              _DetailRow(
                title: 'Total',
                value: '\$${order.total.toStringAsFixed(2)}',
                bold: true,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: bold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

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
              size: 85,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order history will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
