
import 'dart:convert';

import 'package:cartnova_app/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_api_model.dart';

class OrderRemoteDataSource {
  final http.Client client;

  OrderRemoteDataSource({
    required this.client,
  });

  static const String _tokenKey = 'auth_token';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login to manage your orders.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid server response.');
    }

    return decoded;
  }

  // Place order
  Future<OrderApiModel> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'customer_name': customerName,
        'phone': phone,
        'address': address,
        'payment_method': paymentMethod,
      }),
    );

    final body = _decodeResponse(response.body);

    if (response.statusCode == 201 && body['data'] != null) {
      return OrderApiModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    }

    throw Exception(
      body['message'] ?? 'Failed to place order.',
    );
  }

  // Get order history
  Future<List<OrderApiModel>> getOrders() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: await _getHeaders(),
    );

    final body = _decodeResponse(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];

      // Laravel pagination response
      final List<dynamic> orderList =
          data is Map ? data['data'] as List? ?? [] : data as List? ?? [];

      return orderList.map((item) {
        return OrderApiModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    }

    throw Exception(
      body['message'] ?? 'Failed to load orders.',
    );
  }

  // Get single order
  Future<OrderApiModel> getOrderById(String orderId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId'),
      headers: await _getHeaders(),
    );

    final body = _decodeResponse(response.body);

    if (response.statusCode == 200 && body['data'] != null) {
      return OrderApiModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    }

    throw Exception(
      body['message'] ?? 'Order not found.',
    );
  }

  // Cancel order
  Future<OrderApiModel> cancelOrder(String orderId) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/cancel'),
      headers: await _getHeaders(),
    );

    final body = _decodeResponse(response.body);

    if (response.statusCode == 200 && body['data'] != null) {
      return OrderApiModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    }

    throw Exception(
      body['message'] ?? 'Failed to cancel order.',
    );
  }
}
