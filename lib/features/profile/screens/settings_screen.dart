
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(theme, colors),
              const SizedBox(height: 28),

              _sectionTitle('Preferences', colors),
              _settingsCard(
                colors,
                [
                  _switchTile(
                    colors: colors,
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    subtitle: 'Receive app notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                        if (!value) {
                          _orderUpdatesEnabled = false;
                        }
                      });
                    },
                  ),
                  _buildDivider(colors),
                  _switchTile(
                    colors: colors,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Order Updates',
                    subtitle: 'Get updates about your orders',
                    value: _orderUpdatesEnabled,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _orderUpdatesEnabled = value;
                            });
                          }
                        : null,
                  ),
                  _buildDivider(colors),
                  _navigationTile(
                    colors: colors,
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: _selectedLanguage,
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _sectionTitle('Appearance', colors),
              _settingsCard(
                colors,
                [
                  _switchTile(
                    colors: colors,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Change app appearance',
                    value: isDark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).changeTheme(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _sectionTitle('Security & Privacy', colors),
              _settingsCard(
                colors,
                [
                  _navigationTile(
                    colors: colors,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn how your data is handled',
                    onTap: () => _showMessage('Privacy Policy'),
                  ),
                  _buildDivider(colors),
                  _navigationTile(
                    colors: colors,
                    icon: Icons.security_outlined,
                    title: 'Security',
                    subtitle: 'Account protection and security',
                    onTap: () => _showMessage('Security'),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _sectionTitle('Support', colors),
              _settingsCard(
                colors,
                [
                  _navigationTile(
                    colors: colors,
                    icon: Icons.support_agent_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQs and customer support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _sectionTitle('About', colors),
              _settingsCard(
                colors,
                [
                  _navigationTile(
                    colors: colors,
                    icon: Icons.info_outline_rounded,
                    title: 'About CartNova',
                    subtitle: 'Learn more about our app',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(colors),
                  _navigationTile(
                    colors: colors,
                    icon: Icons.verified_outlined,
                    title: 'App Version',
                    subtitle: 'Version 1.0.0',
                    showArrow: false,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_bag_rounded,
                      size: 30,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Made with ♥ for CartNova',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Your Shopping Companion',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customize your CartNova experience.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 3),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
      ),
    );
  }

  Widget _settingsCard(
    ColorScheme colors,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required ColorScheme colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      secondary: _leadingIcon(colors, icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _navigationTile({
    required ColorScheme colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: _leadingIcon(colors, icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: showArrow
          ? const Icon(Icons.chevron_right_rounded)
          : null,
      onTap: onTap,
    );
  }

  Widget _leadingIcon(ColorScheme colors, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: colors.primary,
        size: 22,
      ),
    );
  }

  Widget _buildDivider(ColorScheme colors) {
    return Divider(
      height: 1,
      indent: 65,
      endIndent: 16,
      color: colors.outlineVariant.withValues(alpha: 0.5),
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
