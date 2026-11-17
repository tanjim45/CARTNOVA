
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Order Confirmed!',
      message: 'Your order #CN10245 has been confirmed successfully.',
      time: '10 min ago',
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFF6C4CEB),
      category: 'Orders',
    ),
    _NotificationItem(
      title: 'Special Offer for You!',
      message: 'Enjoy up to 30% discount on selected products.',
      time: '1 hour ago',
      icon: Icons.local_offer_rounded,
      color: const Color(0xFFFF9F43),
      category: 'Offers',
    ),
    _NotificationItem(
      title: 'Order Shipped',
      message: 'Your package is on its way. Get ready to receive it!',
      time: 'Yesterday',
      icon: Icons.local_shipping_rounded,
      color: const Color(0xFF168B9B),
      category: 'Orders',
    ),
    _NotificationItem(
      title: 'Welcome to CartNova!',
      message: 'Discover amazing products and enjoy your shopping.',
      time: '2 days ago',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFE85D91),
      category: 'General',
    ),
  ];

  List<_NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;

    return _notifications
        .where((item) => item.category == _selectedFilter)
        .toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (final item in _notifications) {
        item.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Stay Updated',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_notifications.where((e) => !e.isRead).length} unread',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _filterChip('All'),
                    _filterChip('Orders'),
                    _filterChip('Offers'),
                    _filterChip('General'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _filteredNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 65,
                              color: colors.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No notifications found',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: _filteredNotifications.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _filteredNotifications[index];

                          return _NotificationCard(
                            item: item,
                            onTap: () {
                              setState(() => item.isRead = true);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedFilter = label);
        },
        selectedColor: colors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: item.isRead
          ? colors.surface
          : colors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isRead
                  ? colors.outline.withValues(alpha: 0.15)
                  : colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.message,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.5,
                        color: colors.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final String category;
  bool isRead;

  _NotificationItem({
  required this.title,
  required this.message,
  required this.time,
  required this.icon,
  required this.color,
  required this.category,
}) : isRead = false;
}
