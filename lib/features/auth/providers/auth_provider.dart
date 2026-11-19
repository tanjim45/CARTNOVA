
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

// Auto Login / Current User Provider
final authStatusProvider = FutureProvider<User?>((ref) async {
  try {
    final user = await ref.read(authRepositoryProvider).getUser();
    return user;
  } catch (e) {
    return null;
  }
});

// Update Profile Provider
final updateProfileProvider = FutureProvider.family<
    User,
    Map<String, String>>((ref, profileData) async {
  return ref.read(authRepositoryProvider).updateProfile(
        name: profileData['name']!,
        email: profileData['email']!,
        phone: profileData['phone']!,
      );
});
