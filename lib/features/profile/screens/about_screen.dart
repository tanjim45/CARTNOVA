
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('About CartNova'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildBrandHeader(context),

              const SizedBox(height: 28),

              _sectionTitle(context, 'About Us'),
              _buildAboutCard(context),

              const SizedBox(height: 26),

              _sectionTitle(context, 'App Features'),
              _buildFeaturesCard(context),

              const SizedBox(height: 26),

              _sectionTitle(context, 'App Information'),
              _buildInformationCard(context),

              const SizedBox(height: 26),

              _sectionTitle(context, 'Contact & Support'),
              _buildSupportCard(context),

              const SizedBox(height: 32),

              _buildFooter(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 55,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'CartNova',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Your Shopping Destination',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.storefront_rounded,
              color: theme.colorScheme.primary,
              size: 30,
            ),
            const SizedBox(height: 14),
            Text(
              'Shopping made simple.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CartNova is a modern shopping application designed '
              'to make your shopping experience simple, convenient '
              'and enjoyable. Explore products, manage your wishlist, '
              'add items to your cart and keep track of your orders '
              'all in one place.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.8,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _featureTile(
            context,
            Icons.storefront_outlined,
            'Explore Products',
            'Discover products from different categories.',
          ),
          _buildDivider(context),
          _featureTile(
            context,
            Icons.favorite_border_rounded,
            'Wishlist',
            'Save your favorite products.',
          ),
          _buildDivider(context),
          _featureTile(
            context,
            Icons.shopping_cart_outlined,
            'Shopping Cart',
            'Manage your shopping items easily.',
          ),
          _buildDivider(context),
          _featureTile(
            context,
            Icons.receipt_long_outlined,
            'Order History',
            'View your previous orders.',
          ),
          _buildDivider(context),
          _featureTile(
            context,
            Icons.dark_mode_outlined,
            'Theme Support',
            'Enjoy Light and Dark Mode.',
          ),
        ],
      ),
    );
  }

  Widget _featureTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 7,
      ),
      leading: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          icon,
          color: colors.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildInformationCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _infoTile(
            context,
            Icons.apps_rounded,
            'Application',
            'CartNova',
          ),
          _buildDivider(context),
          _infoTile(
            context,
            Icons.info_outline_rounded,
            'Version',
            '1.0.0',
          ),
          _buildDivider(context),
          _infoTile(
            context,
            Icons.phone_android_rounded,
            'Platform',
            'Flutter',
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 5,
      ),
      leading: Icon(
        icon,
        color: colors.primary,
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.support_agent_rounded,
            color: colors.primary,
          ),
        ),
        title: const Text(
          'Customer Support',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.favorite_rounded,
          color: colors.primary,
          size: 25,
        ),
        const SizedBox(height: 10),
        Text(
          'Made with love for CartNova',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '© 2026 CartNova. All rights reserved.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
