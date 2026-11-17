
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_provider.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _orderUpdatesEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle('Preferences'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      subtitle: const Text('Receive app notifications'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.shopping_bag_outlined),
                      title: const Text('Order Updates'),
                      subtitle: const Text('Get updates about your orders'),
                      value: _orderUpdatesEnabled,
                      onChanged: (value) {
                        setState(() {
                          _orderUpdatesEnabled = value;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: Text(_selectedLanguage),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showLanguageDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance
              _sectionTitle('Appearance'),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Change app appearance'),
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).changeTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Security & Privacy
              _sectionTitle('Security & Privacy'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showMessage('Privacy Policy'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Security'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showMessage('Security'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Help & Support
              _sectionTitle('Support'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: const Text('Help & Support'),
                  subtitle: const Text('FAQs and customer support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // About
              _sectionTitle('About'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About CartNova'),
                      subtitle: const Text('Learn more about our app'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.verified_outlined),
                      title: Text('App Version'),
                      subtitle: Text('1.0.0'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Made with ❤️ for CartNova',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: RadioGroup<String>(
            groupValue: _selectedLanguage,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedLanguage = value;
              });

              Navigator.pop(dialogContext);
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('English'),
                  value: 'English',
                ),
                RadioListTile<String>(
                  title: Text('বাংলা'),
                  value: 'বাংলা',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title feature will be added later.'),
      ),
    );
  }
}
