
import 'package:cartnova_app/features/profile/domain/entities/repositories/address_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/address_remote_data_source.dart';
import '../data/repositories/address_repository_impl.dart';
import '../domain/entities/address.dart';


final addressRemoteDataSourceProvider =
    Provider<AddressRemoteDataSource>((ref) {
  return AddressRemoteDataSource();
});

final addressRepositoryProvider =
    Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(
    remoteDataSource: ref.watch(
      addressRemoteDataSourceProvider,
    ),
  );
});

final addressesProvider = FutureProvider<List<Address>>((ref) {
  return ref.watch(addressRepositoryProvider).getAddresses();
});
