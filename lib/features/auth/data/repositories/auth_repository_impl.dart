
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  static const String _tokenKey = 'auth_token';

  User _mapUser(Map<String, dynamic> json) {
    final userModel = UserModel.fromJson(json);

    return User(
      id: userModel.id,
      name: userModel.name,
      email: userModel.email,
      phone: userModel.phone,
    );
  }

  Future<User> _saveAuthData(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    return _mapUser(userJson);
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    return _saveAuthData(response);
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    return _saveAuthData(response);
  }

  @override
  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await remoteDataSource.getUser(token);

    return _mapUser(response);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null && token.isNotEmpty) {
      await remoteDataSource.logout(token);
    }

    await prefs.remove(_tokenKey);
  }
}
