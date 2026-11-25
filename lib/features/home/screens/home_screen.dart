
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../checkout/screens/order_history_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/settings_screen.dart';
import '../../wishlist/screens/wishlist_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final cartItems = ref.watch(cartProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final totalItems = cartItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF635BFF),
                    Color(0xFF8B83FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'CartNova',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My Wishlist',
            onPressed: () => _navigate(
              context,
              const WishlistScreen(),
            ),
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.redAccent,
            ),
          ),
          IconButton(
            tooltip: 'My Orders',
            onPressed: () => _navigate(
              context,
              const OrderHistoryScreen(),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Badge(
              isLabelVisible: totalItems > 0,
              label: Text('$totalItems'),
              child: IconButton(
                tooltip: 'Shopping Cart',
               onPressed: () => context.push('/cart'),

                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
          PopupMenuButton<ThemeMode>(
            tooltip: 'Change Theme',
            initialValue: themeMode,
            icon: Icon(_themeIcon(themeMode)),
            onSelected: (mode) {
              ref.read(themeProvider.notifier).changeTheme(mode);
            },
            itemBuilder: (context) => [
              _themeMenuItem(
                ThemeMode.light,
                Icons.light_mode_rounded,
                'Light Mode',
              ),
              _themeMenuItem(
                ThemeMode.dark,
                Icons.dark_mode_rounded,
                'Dark Mode',
              ),
              _themeMenuItem(
                ThemeMode.system,
                Icons.brightness_auto_rounded,
                'System Default',
              ),
            ],
          ),
          IconButton(
            tooltip: 'Refresh Products',
            onPressed: () {
              ref.invalidate(productsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),

      drawer: Drawer(
        width: 300,
        child: SafeArea(
          child: Column(
            children: [
              const _DrawerHeader(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  children: [
                    const _DrawerSectionTitle(title: 'ACCOUNT'),

                    _DrawerMenuTile(
                      icon: Icons.person_outline_rounded,
                      title: 'My Profile',
                      subtitle: 'View your profile',
                      onTap: () => _openDrawerPage(
                        context,
                        const ProfileScreen(),
                      ),
                    ),

                    _DrawerMenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'My Orders',
                      subtitle: 'Track your purchases',
                      onTap: () => _openDrawerPage(
                        context,
                        const OrderHistoryScreen(),
                      ),
                    ),

                    _DrawerMenuTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'My Wishlist',
                      subtitle: 'Your favorite products',
                      iconColor: Colors.redAccent,
                      onTap: () => _openDrawerPage(
                        context,
                        const WishlistScreen(),
                      ),
                    ),

                    _DrawerMenuTile(
                      icon: Icons.shopping_cart_outlined,
                      title: 'My Cart',
                      subtitle: 'Review your shopping cart',
                      badge: totalItems > 0 ? '$totalItems' : null,
                     onTap: () {
                      Navigator.pop(context);
                      context.push('/cart');
                    },
                    ),

                    _DrawerMenuTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Your latest updates',
                      onTap: () => _openDrawerPage(
                        context,
                        const NotificationsScreen(),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),

                    const _DrawerSectionTitle(title: 'PREFERENCES'),

                    _DrawerMenuTile(
                      icon: Icons.tune_rounded,
                      title: 'App Settings',
                      subtitle: 'Language, privacy & preferences',
                      onTap: () => _openDrawerPage(
                        context,
                        const SettingsScreen(),
                      ),
                    ),

                    _DrawerMenuTile(
                      icon: Icons.palette_outlined,
                      title: 'Theme Settings',
                      subtitle: _themeLabel(themeMode),
                      onTap: () {
                        Navigator.pop(context);
                        _showThemeSheet(context, ref, themeMode);
                      },
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),

                    const _DrawerSectionTitle(title: 'MORE'),

                    _DrawerMenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      iconColor: Colors.redAccent,
                      titleColor: Colors.redAccent,
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Text(
                      'CARTNOVA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your shopping destination',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: const ProductListScreen(),
    );
  }

  static void _navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void _openDrawerPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    _navigate(context, page);
  }

  static IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  static String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  static PopupMenuItem<ThemeMode> _themeMenuItem(
    ThemeMode mode,
    IconData icon,
    String title,
  ) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  static void _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeMode selectedMode,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Appearance',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  title: 'Light Mode',
                  subtitle: 'Use a bright appearance',
                  mode: ThemeMode.light,
                  selected: selectedMode == ThemeMode.light,
                  onTap: () => _changeTheme(
                    sheetContext,
                    ref,
                    ThemeMode.light,
                  ),
                ),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: 'Easy on your eyes',
                  mode: ThemeMode.dark,
                  selected: selectedMode == ThemeMode.dark,
                  onTap: () => _changeTheme(
                    sheetContext,
                    ref,
                    ThemeMode.dark,
                  ),
                ),
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  title: 'System Default',
                  subtitle: 'Follow device appearance',
                  mode: ThemeMode.system,
                  selected: selectedMode == ThemeMode.system,
                  onTap: () => _changeTheme(
                    sheetContext,
                    ref,
                    ThemeMode.system,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _changeTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) {
    ref.read(themeProvider.notifier).changeTheme(mode);
    Navigator.pop(context);
  }

  static void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.redAccent,
            size: 32,
          ),
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to logout from CartNova?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await ref.read(authRepositoryProvider).logout();

                  // Clear previous user's cart and authentication state.
                  ref.invalidate(cartProvider);
                  ref.invalidate(authStatusProvider);

                  if (!context.mounted) return;

                  context.go('/login');
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                    ),
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF635BFF),
            Color(0xFF827AFF),
            Color(0xFF5148D8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Welcome to CartNova!',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your shopping destination',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  const _DrawerMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 3,
        ),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? colorScheme.primary)
                .withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? colorScheme.primary,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: const TextStyle(fontSize: 11),
              ),
        trailing: badge != null
            ? Badge(
                label: Text(badge!),
                child: const Icon(Icons.chevron_right_rounded),
              )
            : Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
            )
          : null,
    );
  }
}
