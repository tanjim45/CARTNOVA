import '../entities/saved_address.dart';

abstract class SavedAddressRepository {
  Future<List<SavedAddress>> getAddresses();

  Future<SavedAddress> saveAddress({
    required String fullName,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
  });

  Future<SavedAddress> updateAddress({
    required int id,
    required String fullName,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
  });

  Future<void> deleteAddress(int id);
}