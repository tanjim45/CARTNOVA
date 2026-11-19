
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/address.dart';
import '../providers/address_provider.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showAddressDialog({Address? address}) async {
    final isEditing = address != null;

    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(
      text: address?.title ?? 'Home',
    );
    final nameController = TextEditingController(
      text: address?.fullName ?? '',
    );
    final phoneController = TextEditingController(
      text: address?.phone ?? '',
    );
    final addressController = TextEditingController(
      text: address?.addressLine ?? '',
    );
    final cityController = TextEditingController(
      text: address?.city ?? '',
    );
    final stateController = TextEditingController(
      text: address?.state ?? '',
    );
    final postalCodeController = TextEditingController(
      text: address?.postalCode ?? '',
    );
    final countryController = TextEditingController(
      text: address?.country ?? 'Bangladesh',
    );

    bool isDefault = address?.isDefault ?? false;
    bool isSaving = false;

    void disposeControllers() {
      titleController.dispose();
      nameController.dispose();
      phoneController.dispose();
      addressController.dispose();
      cityController.dispose();
      stateController.dispose();
      postalCodeController.dispose();
      countryController.dispose();
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = Theme.of(context).colorScheme;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing
                        ? Icons.edit_location_alt_rounded
                        : Icons.add_location_alt_rounded,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Address' : 'Add Address',
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
                            hintText: 'House, Road, Area...',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter full address'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter city'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: stateController,
                          decoration: const InputDecoration(
                            labelText: 'State / Division',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: postalCodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Postal Code',
                            prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            prefixIcon: Icon(Icons.public_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter country'
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
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            isSaving = true;
                          });

                          final newAddress = Address(
                            id: address?.id,
                            title: titleController.text.trim(),
                            fullName: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            addressLine: addressController.text.trim(),
                            city: cityController.text.trim(),
                            state: stateController.text.trim(),
                            postalCode: postalCodeController.text.trim(),
                            country: countryController.text.trim(),
                            isDefault: isDefault,
                          );

                          try {
                            final repository =
                                ref.read(addressRepositoryProvider);

                            if (isEditing) {
                              await repository.updateAddress(newAddress);
                            } else {
                              await repository.createAddress(newAddress);
                            }

                            ref.invalidate(addressesProvider);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            _showMessage(
                              isEditing
                                  ? 'Address updated successfully!'
                                  : 'Address added successfully!',
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            _showMessage(
                              e.toString().replaceFirst('Exception: ', ''),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(isSaving ? 'Saving...' : 'Save Address'),
                ),
              ],
            );
          },
        );
      },
    );

    disposeControllers();
  }

  Future<void> _deleteAddress(Address address, int total) async {
    if (total == 1) {
      _showMessage('You must keep at least one address.');
      return;
    }

    final confirmed = await showDialog<bool>(
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || address.id == null) return;

    try {
      await ref.read(addressRepositoryProvider).deleteAddress(address.id!);
      ref.invalidate(addressesProvider);
      _showMessage('Address deleted successfully!');
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _setDefaultAddress(Address address) async {
    if (address.id == null) return;

    try {
      await ref
          .read(addressRepositoryProvider)
          .setDefaultAddress(address.id!);

      ref.invalidate(addressesProvider);
      _showMessage('Default address updated!');
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final addressesAsync = ref.watch(addressesProvider);

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
          child: addressesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => _buildErrorState(
              colors,
              theme,
              error.toString(),
            ),
            data: (addresses) {
              if (addresses.isEmpty) {
                return _buildEmptyState(colors, theme);
              }

              return ListView(
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
                                '${addresses.length} saved address${addresses.length == 1 ? '' : 'es'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
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
                  ...List.generate(addresses.length, (index) {
                    final address = addresses[index];

                    return _buildAddressCard(
                      address: address,
                      total: addresses.length,
                      colors: colors,
                      theme: theme,
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required Address address,
    required int total,
    required ColorScheme colors,
    required ThemeData theme,
  }) {
    final isDefault = address.isDefault;

    final fullAddress = [
      address.addressLine,
      address.city,
      if (address.state.isNotEmpty) address.state,
      if (address.postalCode.isNotEmpty) address.postalCode,
      address.country,
    ].join(', ');

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
                  _getAddressIcon(address.title),
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
                      address.title,
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
                onPressed: () => _showAddressDialog(address: address),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete address',
                onPressed: () => _deleteAddress(address, total),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            address.fullName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _addressInfoRow(
            Icons.phone_outlined,
            address.phone,
            colors,
          ),
          const SizedBox(height: 9),
          _addressInfoRow(
            Icons.location_on_outlined,
            fullAddress,
            colors,
          ),
          if (!isDefault) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _setDefaultAddress(address),
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

  Widget _buildErrorState(
    ColorScheme colors,
    ThemeData theme,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 65,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load addresses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => ref.invalidate(addressesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
