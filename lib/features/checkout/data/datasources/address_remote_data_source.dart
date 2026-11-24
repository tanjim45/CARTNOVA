import 'dart:convert';

import 'package:cartnova_app/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';

class AddressRemoteDataSource {
  final http.Client client;

  AddressRemoteDataSource({required this.client});

  static const String _tokenKey = 'auth_token';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login to manage your address.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<AddressModel>> getAddresses() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/user/addresses'),
      headers: await _getHeaders(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = body['data'];

      return data
          .map((item) => AddressModel.fromJson(item))
          .toList();
    }

    throw Exception(
      body['message'] ?? 'Failed to load saved addresses.',
    );
  }

  Future<AddressModel> saveAddress({
    required String fullName,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/user/addresses'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'postal_code': postalCode,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return AddressModel.fromJson(body['data']);
    }

    throw Exception(
      body['message'] ?? 'Failed to save address.',
    );
  }

  Future<AddressModel> updateAddress({
    required int id,
    required String fullName,
    required String phone,
    required String address,
    String? city,
    String? postalCode,
  }) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/user/addresses/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'postal_code': postalCode,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AddressModel.fromJson(body['data']);
    }

    throw Exception(
      body['message'] ?? 'Failed to update address.',
    );
  }

  Future<void> deleteAddress(int id) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/user/addresses/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return;
    }

    final body = jsonDecode(response.body);

    throw Exception(
      body['message'] ?? 'Failed to delete address.',
    );
  }
}