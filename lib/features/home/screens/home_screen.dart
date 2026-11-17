
import 'package:cartnova_app/features/checkout/screens/order_history_screen.dart';
import 'package:cartnova_app/features/wishlist/screens/wishlist_screen.dart';
import 'package:cartnova_app/features/auth/presentation/screens/login_screen.dart';
import 'package:cartnova_app/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_list_screen.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final cartItems = ref.watch(cartProvider);

    final totalItems = cartItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CartNova',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'My Wishlist',
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WishlistScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'My Orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Badge(
              isLabelVisible: totalItems > 0,
              label: Text('$totalItems'),
              child: IconButton(
                tooltip: 'Shopping Cart',
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          PopupMenuButton<ThemeMode>(
            tooltip: 'Change Theme',
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : themeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
            ),
            onSelected: (mode) {
              ref.read(themeProvider.notifier).changeTheme(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode_rounded),
                    SizedBox(width: 12),
                    Text('Light Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded),
                    SizedBox(width: 12),
                    Text('Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto_rounded),
                    SizedBox(width: 12),
                    Text('System Default'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              ref.invalidate(productsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Products',
          ),
        ],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Welcome to CartNova!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your shopping destination',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // My Profile
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('My Profile'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              // My Orders
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('My Orders'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),

              // Wishlist
              ListTile(
                leading: const Icon(Icons.favorite_border_rounded),
                title: const Text('My Wishlist'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WishlistScreen(),
                    ),
                  );
                },
              ),

              // Cart
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: const Text('My Cart'),
                trailing: totalItems > 0
                    ? Badge(label: Text('$totalItems'))
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),

              const Divider(indent: 16, endIndent: 16),

              // Theme Settings
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Theme Settings'),
                subtitle: const Text('Light, Dark & System'),
                onTap: () {
                  Navigator.pop(context);

                  showModalBottomSheet(
                    context: context,
                    builder: (sheetContext) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ListTile(
                              title: Text(
                                'Choose Theme',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.light_mode),
                              title: const Text('Light Mode'),
                              onTap: () {
                                ref.read(themeProvider.notifier)
                                    .changeTheme(ThemeMode.light);
                                Navigator.pop(sheetContext);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.dark_mode),
                              title: const Text('Dark Mode'),
                              onTap: () {
                                ref.read(themeProvider.notifier)
                                    .changeTheme(ThemeMode.dark);
                                Navigator.pop(sheetContext);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.brightness_auto),
                              title: const Text('System Default'),
                              onTap: () {
                                ref.read(themeProvider.notifier)
                                    .changeTheme(ThemeMode.system);
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const Spacer(),
              const Divider(indent: 16, endIndent: 16),

              // Logout
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                          'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      body: const ProductListScreen(),
    );
  }
}
