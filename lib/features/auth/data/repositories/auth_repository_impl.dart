
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

  Map<String, dynamic> _extractUserJson(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];

    if (data is Map) {
      final user = data['user'];

      if (user is Map) {
        return Map<String, dynamic>.from(user);
      }

      return Map<String, dynamic>.from(data);
    }

    final user = response['user'];

    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }

    return response;
  }

  Future<User> _saveAuthData(
    Map<String, dynamic> response,
  ) async {
    final data = response['data'];

    if (data is! Map) {
      throw Exception('Invalid authentication response.');
    }

    final token = data['token'];
    final user = data['user'];

    if (token is! String || user is! Map) {
      throw Exception('Authentication token or user data missing.');
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);

    return _mapUser(Map<String, dynamic>.from(user));
  }

  // Login
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

  // Register
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

  // Forgot Password
  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await remoteDataSource.forgotPassword(
      email: email,
    );
  }

  // Reset Password
  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  // Get Logged-in User
  @override
  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await remoteDataSource.getUser(token);
    final userJson = _extractUserJson(response);

    return _mapUser(userJson);
  }

  // Update Profile
  @override
  Future<User> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final response = await remoteDataSource.updateProfile(
      token: token,
      name: name,
      email: email,
      phone: phone,
    );

    final userJson = _extractUserJson(response);

    return _mapUser(userJson);
  }

  // Change Password
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    await remoteDataSource.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
      passwordConfirmation: passwordConfirmation,
    );
  }

  // Logout
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
