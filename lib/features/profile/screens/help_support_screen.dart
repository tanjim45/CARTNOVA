
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How can I place an order?',
      'answer':
          'Browse products, add your favorite items to the cart, '
          'and complete the checkout form to place your order.',
    },
    {
      'question': 'How can I track my order?',
      'answer':
          'Go to My Orders from the navigation drawer to view '
          'your order history and order details.',
    },
    {
      'question': 'Can I cancel an order?',
      'answer':
          'Order cancellation will be available once order '
          'management is connected to the backend.',
    },
    {
      'question': 'What payment methods are supported?',
      'answer':
          'Payment gateway integration will be added in a future update.',
    },
    {
      'question': 'How can I update my profile?',
      'answer':
          'Open My Profile from the navigation drawer and edit '
          'your personal information.',
    },
    {
      'question': 'How can I add products to my wishlist?',
      'answer':
          'Tap the heart icon on any product to save it to your wishlist.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(context),

              const SizedBox(height: 30),

              _sectionTitle(
                context,
                'Frequently Asked Questions',
                Icons.quiz_outlined,
              ),

              const SizedBox(height: 12),

              _buildFaqSection(context),

              const SizedBox(height: 28),

              _sectionTitle(
                context,
                'Contact Support',
                Icons.support_agent_rounded,
              ),

              const SizedBox(height: 12),

              _SupportCard(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'Get help through email',
                color: colors.primary,
                onTap: () => _showMessage(
                  context,
                  'Email support will be available soon.',
                ),
              ),

              _SupportCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                color: colors.tertiary,
                onTap: () => _showMessage(
                  context,
                  'Live chat will be available soon.',
                ),
              ),

              _SupportCard(
                icon: Icons.phone_outlined,
                title: 'Call Support',
                subtitle: 'Talk directly with our team',
                color: Colors.green,
                onTap: () => _showMessage(
                  context,
                  'Phone support will be available soon.',
                ),
              ),

              const SizedBox(height: 25),

              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'How can we help you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Find answers to common questions or contact '
            'our support team.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < _faqs.length; i++) ...[
            ExpansionTile(
              key: PageStorageKey<String>(
                _faqs[i]['question']!,
              ),
              leading: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                _faqs[i]['question']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                18,
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _faqs[i]['answer']!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.7,
                  ),
                ),
              ],
            ),
            if (i != _faqs.length - 1)
              Divider(
                height: 1,
                indent: 18,
                endIndent: 18,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
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
          size: 22,
        ),
        const SizedBox(height: 9),
        Text(
          'Thank you for choosing CartNova!',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'CartNova Support • Version 1.0.0',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
