
class SavedAddress {
  final int id;
  final String fullName;
  final String phone;
  final String address;
  final String? city;
  final String? postalCode;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    this.city,
    this.postalCode,
    this.isDefault = true,
  });
}
