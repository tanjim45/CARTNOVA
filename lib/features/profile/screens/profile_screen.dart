
import 'package:cartnova_app/features/profile/screens/address_screen.dart';
import 'package:cartnova_app/features/profile/screens/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/domain/entities/user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await ref.read(authRepositoryProvider).getUser();

      if (!mounted) return;

      setState(() {
        _user = user;
        _setControllers(user);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _setControllers(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Phone number cannot be empty.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            name: _nameController.text.trim(),
            email: _user!.email,
            phone: _phoneController.text.trim(),
          );

      if (!mounted) return;

      ref.invalidate(authStatusProvider);

      setState(() {
        _user = updatedUser;
        _setControllers(updatedUser);
        _isEditing = false;
        _isSaving = false;
      });

      _showMessage('Profile updated successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _cancelEditing() {
    if (_user == null) return;

    setState(() {
      _setControllers(_user!);
      _isEditing = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, size: 55),
              const SizedBox(height: 12),
              const Text('Unable to load profile.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadProfile();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : _cancelEditing,
              child: const Text('Cancel'),
            ),
          TextButton.icon(
            onPressed: _isSaving
                ? null
                : (_isEditing ? _saveProfile : _toggleEdit),
            icon: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isEditing ? Icons.save_rounded : Icons.edit_rounded,
                  ),
            label: Text(
              _isSaving ? 'Saving...' : (_isEditing ? 'Save' : 'Edit'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView(
                padding: EdgeInsets.all(isWide ? 28 : 18),
                children: [
                  _buildProfileHeader(
                    colors,
                    theme,
                    isDark,
                    isWide,
                  ),
                  const SizedBox(height: 28),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildPersonalInformation(theme, colors),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: _buildAccountSettings(theme, colors),
                        ),
                      ],
                    )
                  else ...[
                    _buildPersonalInformation(theme, colors),
                    const SizedBox(height: 26),
                    _buildAccountSettings(theme, colors),
                  ],
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: colors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your account is protected',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Keep your personal information up to date.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    ColorScheme colors,
    ThemeData theme,
    bool isDark,
    bool isWide,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 30 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: isWide ? 55 : 48,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person_rounded,
                  size: isWide ? 62 : 55,
                  color: Colors.white,
                ),
              ),
              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _emailController.text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'CartNova Member',
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

  Widget _buildPersonalInformation(
    ThemeData theme,
    ColorScheme colors,
  ) {
    return _sectionCard(
      theme: theme,
      colors: colors,
      title: 'Personal Information',
      subtitle: 'Manage your personal details',
      icon: Icons.person_outline_rounded,
      children: [
        _buildField(
          label: 'Full Name',
          controller: _nameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Email Address',
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          forceReadOnly: true,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Phone Number',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildAccountSettings(
    ThemeData theme,
    ColorScheme colors,
  ) {
    return _sectionCard(
      theme: theme,
      colors: colors,
      title: 'Account Settings',
      subtitle: 'Manage your account preferences',
      icon: Icons.settings_outlined,
      children: [
        _buildSettingTile(
          colors: colors,
          icon: Icons.location_on_outlined,
          title: 'Manage Addresses',
          subtitle: 'Manage your delivery addresses',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddressScreen(),
              ),
            );
          },
        ),
        _buildSettingTile(
          colors: colors,
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
        _buildSettingTile(
          colors: colors,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy & Security',
          subtitle: 'Manage your account security',
          onTap: () {
            _showMessage('Privacy settings coming soon!');
          },
        ),
      ],
    );
  }

  Widget _sectionCard({
    required ThemeData theme,
    required ColorScheme colors,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool forceReadOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: forceReadOnly || !_isEditing,
      keyboardType: keyboardType,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required ColorScheme colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colors.primary),
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
