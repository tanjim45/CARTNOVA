
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, dynamic>> _faqs = [
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
    final isDark = theme.brightness == Brightness.dark;

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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      size: 58,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find answers to common questions '
                      'or contact our support team.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ..._faqs.map((faq) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isDark
                      ? theme.colorScheme.surfaceContainer
                      : theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    collapsedShape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    leading: Icon(
                      Icons.help_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      faq['question'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 16,
                    ),
                    children: [
                      Text(
                        faq['answer'] as String,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.75),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _SupportCard(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'Get help through email',
                onTap: () => _showMessage(
                  context,
                  'Email support will be available soon.',
                ),
              ),

              _SupportCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => _showMessage(
                  context,
                  'Live chat will be available soon.',
                ),
              ),

              _SupportCard(
                icon: Icons.phone_outlined,
                title: 'Call Support',
                subtitle: 'Talk directly with our team',
                onTap: () => _showMessage(
                  context,
                  'Phone support will be available soon.',
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'CartNova Support • Version 1.0.0',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
