
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password UI validation successful! Backend integration is pending.',
        ),
      ),
    );

    _formKey.currentState!.reset();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 42,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Secure Your Account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a strong password to keep your CartNova account safe.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

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
                      ),

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
                        onPressed: _updatePassword,
                        icon: const Icon(Icons.lock_outline_rounded),
                        label: const Text('Update Password'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    bool confirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
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

        if (!confirm && controller == _newPasswordController) {
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
        }

        if (confirm && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }
}
