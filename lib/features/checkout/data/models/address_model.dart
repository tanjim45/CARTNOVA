import '../../domain/entities/saved_address.dart';

class AddressModel extends SavedAddress {
  const AddressModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.address,
    super.city,
    super.postalCode,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
    };
  }
}