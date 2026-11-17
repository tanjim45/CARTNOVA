
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../checkout/domain/entities/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  int get currentStep {
    switch (order.status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  final List<TrackingStep> steps = const [
    TrackingStep(
      title: 'Order Placed',
      description: 'Your order has been received.',
      icon: Icons.receipt_long_rounded,
    ),
    TrackingStep(
      title: 'Order Confirmed',
      description: 'Your order has been confirmed.',
      icon: Icons.verified_rounded,
    ),
    TrackingStep(
      title: 'Order Shipped',
      description: 'Your package is on its way.',
      icon: Icons.local_shipping_rounded,
    ),
    TrackingStep(
      title: 'Out for Delivery',
      description: 'Your package is on the way to you.',
      icon: Icons.delivery_dining_rounded,
    ),
    TrackingStep(
      title: 'Delivered',
      description: 'Your package has been delivered.',
      icon: Icons.home_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCancelled = order.status == OrderStatus.cancelled;

    String statusMessage;

    switch (order.status) {
      case OrderStatus.pending:
        statusMessage = 'Your order is waiting for confirmation.';
        break;
      case OrderStatus.confirmed:
        statusMessage = 'Your order has been confirmed!';
        break;
      case OrderStatus.shipped:
        statusMessage = 'Your package is on its way!';
        break;
      case OrderStatus.delivered:
        statusMessage = 'Your package has been delivered!';
        break;
      case OrderStatus.cancelled:
        statusMessage = 'This order has been cancelled.';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Order',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCancelled
                        ? [
                            colors.error,
                            colors.error.withValues(alpha: 0.7),
                          ]
                        : const [
                            Color(0xFF6C4CEB),
                            Color(0xFF9178F4),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.status.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(
                          isCancelled
                              ? Icons.cancel_rounded
                              : Icons.local_shipping_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            statusMessage,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Information',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Order ID',
                      value: '#${order.id}',
                    ),
                    _InfoRow(
                      label: 'Order Date',
                      value: DateFormat('dd MMM yyyy, hh:mm a')
                          .format(order.createdAt),
                    ),
                    _InfoRow(
                      label: 'Tracking ID',
                      value: 'Not assigned yet',
                    ),
                    _InfoRow(
                      label: 'Courier',
                      value: 'Not assigned yet',
                    ),
                    _InfoRow(
                      label: 'Total Amount',
                      value: '\$${order.total.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Tracking Details',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              if (isCancelled)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colors.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This order was cancelled. Delivery tracking is no longer available.',
                          style: TextStyle(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(steps.length, (index) {
                  final step = steps[index];
                  final completed = index <= currentStep;
                  final isLast = index == steps.length - 1;

                  String dateLabel;

                  if (index == 0) {
                    dateLabel = DateFormat('dd MMM yyyy, hh:mm a')
                        .format(order.createdAt);
                  } else if (completed) {
                    dateLabel = 'Completed';
                  } else {
                    dateLabel = 'Waiting for update';
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 48,
                        child: Column(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: completed
                                    ? colors.primary
                                    : colors.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                completed
                                    ? Icons.check_rounded
                                    : step.icon,
                                color: completed
                                    ? Colors.white
                                    : colors.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                size: 20,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 65,
                                color: index < currentStep
                                    ? colors.primary
                                    : colors.outline.withValues(
                                        alpha: 0.25,
                                      ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: completed
                                      ? colors.onSurface
                                      : colors.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                step.description,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: colors.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                dateLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: completed
                                      ? colors.primary
                                      : colors.onSurface.withValues(
                                          alpha: 0.4,
                                        ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackingStep {
  final String title;
  final String description;
  final IconData icon;

  const TrackingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
