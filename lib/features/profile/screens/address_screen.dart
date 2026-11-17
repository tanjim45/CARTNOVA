
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

  void _showAddressDialog({int? index}) {
    final existing = index != null ? _addresses[index] : null;

    final nameController = TextEditingController(
      text: existing?['name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: existing?['phone'] ?? '',
    );
    final addressController = TextEditingController(
      text: existing?['address'] ?? '',
    );
    final titleController = TextEditingController(
      text: existing?['title'] ?? '',
    );

    bool isDefault = existing?['isDefault'] ?? _addresses.isEmpty;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(index == null ? 'Add Address' : 'Edit Address'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Address Type (Home / Office)',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        nameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty ||
                        addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                        ),
                      );
                      return;
                    }

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

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address saved successfully!'),
                      ),
                    );

                    nameController.dispose();
                    phoneController.dispose();
                    addressController.dispose();
                    titleController.dispose();
                  },
                  child: const Text('Save Address'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must keep at least one address'),
        ),
      );
      return;
    }

    setState(() {
      final wasDefault = _addresses[index]['isDefault'] == true;
      _addresses.removeAt(index);

      if (wasDefault) {
        _addresses.first['isDefault'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Addresses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressDialog(),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Address'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: _addresses.isEmpty
              ? const Center(
                  child: Text('No addresses found. Add your first address.'),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Your Delivery Addresses',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(_addresses.length, (index) {
                      final address = _addresses[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      address['title'],
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (address['isDefault'] == true)
                                    Chip(
                                      label: const Text('Default'),
                                      avatar: const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                address['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(address['phone']),
                              const SizedBox(height: 5),
                              Text(address['address']),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () =>
                                        _showAddressDialog(index: index),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _deleteAddress(index),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  if (address['isDefault'] != true)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          for (final item in _addresses) {
                                            item['isDefault'] = false;
                                          }
                                          address['isDefault'] = true;
                                        });
                                      },
                                      child: const Text('Set Default'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 90),
                  ],
                ),
        ),
      ),
    );
  }
}
