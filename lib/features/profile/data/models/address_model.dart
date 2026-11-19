
class AddressModel {
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

  const AddressModel({
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

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      title: json['address_type'] ?? 'Other',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      addressLine: json['address_line'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? 'Bangladesh',
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_type': title,
      'full_name': fullName,
      'phone': phone,
      'address_line': addressLine,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
    };
  }
}
