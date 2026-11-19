
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  int get _passwordStrength {
    final password = _newPasswordController.text;

    if (password.isEmpty) return 0;

    int score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    return score;
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Enter a password';
    }
  }

  Color _strengthColor(ColorScheme colors) {
    switch (_passwordStrength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      default:
        return colors.outlineVariant;
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Change Password API
  Future<void> _updatePassword() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _formKey.currentState!.reset();

      setState(() {
        _hideCurrentPassword = true;
        _hideNewPassword = true;
        _hideConfirmPassword = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 32 : 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildSecurityInfo(theme, colors),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: _buildPasswordForm(theme, colors),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildSecurityInfo(theme, colors),
                          const SizedBox(height: 24),
                          _buildPasswordForm(theme, colors),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecurityInfo(
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Secure Your Account',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Protect your CartNova account with a strong and unique password.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 25),
          _securityTip(
            Icons.check_circle_outline_rounded,
            'At least 8 characters',
          ),
          const SizedBox(height: 13),
          _securityTip(
            Icons.check_circle_outline_rounded,
            'Use uppercase and numbers',
          ),
          const SizedBox(height: 13),
          _securityTip(
            Icons.check_circle_outline_rounded,
            'Add special characters',
          ),
        ],
      ),
    );
  }

  Widget _securityTip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update Password',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Enter your current and new password below.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 25),

            _passwordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              obscureText: _hideCurrentPassword,
              onToggle: () {
                setState(() {
                  _hideCurrentPassword = !_hideCurrentPassword;
                });
              },
            ),
            const SizedBox(height: 20),

            _passwordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: _hideNewPassword,
              onToggle: () {
                setState(() {
                  _hideNewPassword = !_hideNewPassword;
                });
              },
              onChanged: (_) => setState(() {}),
            ),

            if (_newPasswordController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPasswordStrength(colors),
            ],

            const SizedBox(height: 20),

            _passwordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: _hideConfirmPassword,
              onToggle: () {
                setState(() {
                  _hideConfirmPassword = !_hideConfirmPassword;
                });
              },
              confirm: true,
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _isLoading ? null : _updatePassword,
              icon: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_reset_rounded),
              label: Text(
                _isLoading ? 'Updating...' : 'Update Password',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrength(ColorScheme colors) {
    final strength = _passwordStrength;
    final strengthColor = _strengthColor(colors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password strength',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Text(
              _strengthLabel,
              style: TextStyle(
                color: strengthColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    bool confirm = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: obscureText ? 'Show password' : 'Hide password',
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }

        if (controller == _newPasswordController &&
            value.length < 8) {
          return 'Password must be at least 8 characters';
        }

        if (confirm && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }
}
