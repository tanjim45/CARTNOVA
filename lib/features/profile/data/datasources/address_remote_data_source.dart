
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';

class AddressRemoteDataSource {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    final Map<String, dynamic> body =
        response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body['data'];
    }

    if (body['errors'] is Map) {
      final errors = body['errors'] as Map;
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        throw Exception(firstError.first.toString());
      }
    }

    throw Exception(
      body['message'] ?? 'Something went wrong.',
    );
  }

  // Get all addresses
  Future<List<Map<String, dynamic>>> getAddresses() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/addresses'),
      headers: await _headers(),
    );

    final data = _handleResponse(response);

    return List<Map<String, dynamic>>.from(data);
  }

  // Add new address
  Future<Map<String, dynamic>> createAddress(
    Map<String, dynamic> address,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/addresses'),
      headers: await _headers(),
      body: jsonEncode(address),
    );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // Update address
  Future<Map<String, dynamic>> updateAddress(
    int id,
    Map<String, dynamic> address,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/addresses/$id'),
      headers: await _headers(),
      body: jsonEncode(address),
    );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }

  // Delete address
  Future<void> deleteAddress(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/addresses/$id'),
      headers: await _headers(),
    );

    _handleResponse(response);
  }

  // Set default address
  Future<Map<String, dynamic>> setDefaultAddress(
    int id,
  ) async {
    final response = await http.patch(
      Uri.parse(
        '${ApiConstants.baseUrl}/addresses/$id/default',
      ),
      headers: await _headers(),
    );

    return Map<String, dynamic>.from(
      _handleResponse(response),
    );
  }
}
