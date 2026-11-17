
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About CartNova'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),

              // App Branding
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 105,
                      width: 105,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        size: 58,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'CartNova',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your Shopping Destination',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      avatar: const Icon(
                        Icons.verified_rounded,
                        size: 17,
                      ),
                      label: const Text('Version 1.0.0'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // About
              _sectionTitle(context, 'About Us'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'CartNova is a modern shopping application designed '
                    'to make your shopping experience simple, convenient '
                    'and enjoyable. Explore products, manage your wishlist, '
                    'add items to your cart and keep track of your orders '
                    'all in one place.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Features
              _sectionTitle(context, 'App Features'),
              Card(
                child: Column(
                  children: [
                    _featureTile(
                      context,
                      Icons.storefront_outlined,
                      'Explore Products',
                      'Discover products from different categories.',
                    ),
                    const Divider(height: 1),
                    _featureTile(
                      context,
                      Icons.favorite_border_rounded,
                      'Wishlist',
                      'Save your favorite products.',
                    ),
                    const Divider(height: 1),
                    _featureTile(
                      context,
                      Icons.shopping_cart_outlined,
                      'Shopping Cart',
                      'Manage your shopping items easily.',
                    ),
                    const Divider(height: 1),
                    _featureTile(
                      context,
                      Icons.receipt_long_outlined,
                      'Order History',
                      'View your previous orders.',
                    ),
                    const Divider(height: 1),
                    _featureTile(
                      context,
                      Icons.dark_mode_outlined,
                      'Theme Support',
                      'Enjoy Light and Dark Mode.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Information
              _sectionTitle(context, 'App Information'),
              Card(
                child: Column(
                  children: [
                    _infoTile(
                      context,
                      Icons.apps_outlined,
                      'Application',
                      'CartNova',
                    ),
                    const Divider(height: 1),
                    _infoTile(
                      context,
                      Icons.info_outline,
                      'Version',
                      '1.0.0',
                    ),
                    const Divider(height: 1),
                    _infoTile(
                      context,
                      Icons.phone_android_outlined,
                      'Platform',
                      'Flutter',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Support
              _sectionTitle(context, 'Contact & Support'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: const Text('Customer Support'),
                  subtitle: const Text(
                    'Support contact will be available soon.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Customer support will be available soon.',
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 35),

              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Made with love for CartNova',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '© 2026 CartNova. All rights reserved.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _featureTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
