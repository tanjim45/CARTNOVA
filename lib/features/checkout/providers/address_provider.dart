import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/datasources/address_remote_data_source.dart';
import '../data/repositories/address_repository_impl.dart';
import '../domain/entities/saved_address.dart';
import '../domain/repositories/saved_address_repository.dart';

final addressRemoteDataSourceProvider =
    Provider<AddressRemoteDataSource>((ref) {
  return AddressRemoteDataSource(
    client: http.Client(),
  );
});

final savedAddressRepositoryProvider =
    Provider<SavedAddressRepository>((ref) {
  final remoteDataSource = ref.watch(
    addressRemoteDataSourceProvider,
  );

  return AddressRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

final savedAddressesProvider =
    FutureProvider<List<SavedAddress>>((ref) async {
  final repository = ref.watch(
    savedAddressRepositoryProvider,
  );

  return repository.getAddresses();
});