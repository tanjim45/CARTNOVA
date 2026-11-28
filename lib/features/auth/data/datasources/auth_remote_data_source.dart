
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }

    throw Exception(
      data['message'] ?? 'Something went wrong. Please try again.',
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse(ApiConstants.login),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await client.post(
      Uri.parse(ApiConstants.register),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _handleResponse(response);
  }

  // Forgot Password API
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/forgot-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    return _handleResponse(response);
  }

  // Reset Password API
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await client.get(
      Uri.parse(ApiConstants.user),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  // Update Profile API
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String email,
    required String phone,
  }) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
      }),
    );

    return _handleResponse(response);
  }

  // Change Password API
  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/user/change-password'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> logout(String token) async {
    final response = await client.post(
      Uri.parse(ApiConstants.logout),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }
}
