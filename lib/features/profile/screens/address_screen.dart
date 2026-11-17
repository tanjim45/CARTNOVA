
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'title': 'Home',
      'name': 'CartNova User',
      'phone': '+880 1XXXXXXXXX',
      'address': 'Your home address, Dhaka, Bangladesh',
      'isDefault': true,
    },
  ];

  IconData _getAddressIcon(String title) {
    switch (title.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  void _showAddressDialog({int? index}) {
    final existing = index != null ? _addresses[index] : null;

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(
      text: existing?['title'] ?? '',
    );
    final nameController = TextEditingController(
      text: existing?['name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: existing?['phone'] ?? '',
    );
    final addressController = TextEditingController(
      text: existing?['address'] ?? '',
    );

    bool isDefault = existing?['isDefault'] ?? _addresses.isEmpty;

    void disposeControllers() {
      titleController.dispose();
      nameController.dispose();
      phoneController.dispose();
      addressController.dispose();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = Theme.of(context).colorScheme;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    index == null
                        ? Icons.add_location_alt_rounded
                        : Icons.edit_location_alt_rounded,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      index == null ? 'Add Address' : 'Edit Address',
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Address Type',
                            hintText: 'Home / Office / Other',
                            prefixIcon: Icon(Icons.label_outline_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter address type'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter your name'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter phone number';
                            }
                            if (value.trim().length < 7) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: addressController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Full Address',
                            hintText: 'House, Road, Area, City...',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter full address'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Set as default address'),
                          value: isDefault,
                          onChanged: (value) {
                            setDialogState(() {
                              isDefault = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    disposeControllers();
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final newAddress = {
                      'title': titleController.text.trim(),
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                      'isDefault': isDefault,
                    };

                    setState(() {
                      if (isDefault) {
                        for (final address in _addresses) {
                          address['isDefault'] = false;
                        }
                      }

                      if (index == null) {
                        _addresses.add(newAddress);
                      } else {
                        _addresses[index] = newAddress;
                      }

                      if (!_addresses.any(
                        (address) => address['isDefault'] == true,
                      )) {
                        _addresses.first['isDefault'] = true;
                      }
                    });

                    Navigator.pop(dialogContext);
                    disposeControllers();

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          index == null
                              ? 'Address added successfully!'
                              : 'Address updated successfully!',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save Address'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAddress(int index) {
    if (_addresses.length == 1) {
      _showMessage('You must keep at least one address.');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.red,
            size: 32,
          ),
          title: const Text('Delete Address?'),
          content: const Text(
            'Are you sure you want to delete this delivery address?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  final wasDefault =
                      _addresses[index]['isDefault'] == true;

                  _addresses.removeAt(index);

                  if (wasDefault) {
                    _addresses.first['isDefault'] = true;
                  }
                });

                Navigator.pop(dialogContext);
                _showMessage('Address deleted successfully!');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultAddress(int index) {
    setState(() {
      for (final address in _addresses) {
        address['isDefault'] = false;
      }
      _addresses[index]['isDefault'] = true;
    });

    _showMessage('Default address updated!');
  }

  void _showMessage(String message) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Addresses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressDialog(),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Address'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: _addresses.isEmpty
              ? _buildEmptyState(colors, theme)
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary,
                            colors.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Delivery Addresses',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${_addresses.length} saved address${_addresses.length == 1 ? '' : 'es'}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Saved Addresses',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(_addresses.length, (index) {
                      final address = _addresses[index];
                      final isDefault = address['isDefault'] == true;

                      return _buildAddressCard(
                        address: address,
                        index: index,
                        isDefault: isDefault,
                        colors: colors,
                        theme: theme,
                      );
                    }),
                    const SizedBox(height: 100),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required Map<String, dynamic> address,
    required int index,
    required bool isDefault,
    required ColorScheme colors,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault
              ? colors.primary.withValues(alpha: 0.65)
              : colors.outlineVariant.withValues(alpha: 0.6),
          width: isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getAddressIcon(address['title'].toString()),
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address['title'].toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isDefault)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'DEFAULT ADDRESS',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit address',
                onPressed: () => _showAddressDialog(index: index),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete address',
                onPressed: () => _deleteAddress(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            address['name'].toString(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _addressInfoRow(
            Icons.phone_outlined,
            address['phone'].toString(),
            colors,
          ),
          const SizedBox(height: 9),
          _addressInfoRow(
            Icons.location_on_outlined,
            address['address'].toString(),
            colors,
          ),
          if (!isDefault) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _setDefaultAddress(index),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Set as Default'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressInfoRow(
    IconData icon,
    String text,
    ColorScheme colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 75,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 18),
            Text(
              'No Addresses Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your delivery address to make checkout easier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showAddressDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Address'),
            ),
          ],
        ),
      ),
    );
  }
}
