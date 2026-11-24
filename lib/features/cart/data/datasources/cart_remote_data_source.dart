
import 'dart:convert';
import 'package:cartnova_app/core/constants/api_constants.dart';
import 'package:cartnova_app/features/cart/domain/entities/cart_item.dart';
import 'package:cartnova_app/features/products/data/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartRemoteDataSource {
  final http.Client _client;

  CartRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  static const String _tokenKey = 'auth_token';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _sendRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(url);

    late http.Response response;

    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await _client.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await _client.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method.');
    }

    final responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        responseData['message']?.toString() ??
            'Cart request failed: ${response.statusCode}',
      );
    }

    if (responseData['success'] != true) {
      throw Exception(
        responseData['message']?.toString() ?? 'Cart request failed.',
      );
    }

    return responseData;
  }

  List<CartItem> _parseCartItems(Map<String, dynamic> response) {
    final data = response['data'] as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.map((json) {
      final item = json as Map<String, dynamic>;
      final productJson = item['product'] as Map<String, dynamic>;

      return CartItem(
        cartItemId: (item['id'] as num).toInt(),
        product: ProductModel.fromJson(productJson),
        quantity: (item['quantity'] as num).toInt(),
      );
    }).toList();
  }

  Future<List<CartItem>> getCartItems() async {
    final response = await _sendRequest(
      'GET',
      '${ApiConstants.baseUrl}/cart',
    );

    return _parseCartItems(response);
  }

  Future<List<CartItem>> addToCart(
    int productId, {
    int quantity = 1,
  }) async {
    final response = await _sendRequest(
      'POST',
      '${ApiConstants.baseUrl}/cart/add',
      body: {
        'product_id': productId,
        'quantity': quantity,
      },
    );

    return _parseCartItems(response);
  }

  Future<List<CartItem>> updateQuantity(
    int cartItemId,
    int quantity,
  ) async {
    final response = await _sendRequest(
      'PUT',
      '${ApiConstants.baseUrl}/cart/items/$cartItemId',
      body: {'quantity': quantity},
    );

    return _parseCartItems(response);
  }

  Future<List<CartItem>> removeFromCart(int cartItemId) async {
    final response = await _sendRequest(
      'DELETE',
      '${ApiConstants.baseUrl}/cart/items/$cartItemId',
    );

    return _parseCartItems(response);
  }

  Future<List<CartItem>> clearCart() async {
    final response = await _sendRequest(
      'DELETE',
      '${ApiConstants.baseUrl}/cart/clear',
    );

    return _parseCartItems(response);
  }
}
