
import 'package:cartnova_app/features/profile/domain/entities/repositories/address_repository.dart';
import '../../domain/entities/address.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({
    required this.remoteDataSource,
  });

  Address _toEntity(AddressModel model) {
    return Address(
      id: model.id,
      title: model.title,
      fullName: model.fullName,
      phone: model.phone,
      addressLine: model.addressLine,
      city: model.city,
      state: model.state,
      postalCode: model.postalCode,
      country: model.country,
      isDefault: model.isDefault,
    );
  }

  AddressModel _toModel(Address address) {
    return AddressModel(
      id: address.id,
      title: address.title,
      fullName: address.fullName,
      phone: address.phone,
      addressLine: address.addressLine,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
    );
  }

  @override
  Future<List<Address>> getAddresses() async {
    final result = await remoteDataSource.getAddresses();

    return result
        .map((json) => _toEntity(AddressModel.fromJson(json)))
        .toList();
  }

  @override
  Future<Address> createAddress(Address address) async {
    final result = await remoteDataSource.createAddress(
      _toModel(address).toJson(),
    );

    return _toEntity(AddressModel.fromJson(result));
  }

  @override
  Future<Address> updateAddress(Address address) async {
    if (address.id == null) {
      throw Exception('Address ID is required.');
    }

    final result = await remoteDataSource.updateAddress(
      address.id!,
      _toModel(address).toJson(),
    );

    return _toEntity(AddressModel.fromJson(result));
  }

  @override
  Future<void> deleteAddress(int id) {
    return remoteDataSource.deleteAddress(id);
  }

  @override
  Future<Address> setDefaultAddress(int id) async {
    final result = await remoteDataSource.setDefaultAddress(id);

    return _toEntity(AddressModel.fromJson(result));
  }
}
