import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/saved_address_repository.dart';
import '../datasources/address_remote_data_source.dart';

class AddressRepositoryImpl implements SavedAddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SavedAddress>> getAddresses() async {
    return await remoteDataSource.getAddresses();
  }

  @override
  Future<SavedAddress> saveAddress({
    required String fullName,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
  }) async {
    return await remoteDataSource.saveAddress(
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
    );
  }

  @override
  Future<SavedAddress> updateAddress({
    required int id,
    required String fullName,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
  }) async {
    return await remoteDataSource.updateAddress(
      id: id,
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
    );
  }

  @override
  Future<void> deleteAddress(int id) async {
    await remoteDataSource.deleteAddress(id);
  }
}