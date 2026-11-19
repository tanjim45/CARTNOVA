
class Address {
  final int? id;
  final String title;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  const Address({
    this.id,
    required this.title,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
  });
}
