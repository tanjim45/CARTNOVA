import 'dart:convert';
import 'package:cartnova_app/features/products/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRemoteDataSource {
  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client _client;

  ProductRemoteDataSource({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<ProductModel>> fetchProducts() async {
    final url = Uri.parse('$_baseUrl/products?limit=30');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        final List<dynamic> productsJson = data['products'];

        return productsJson
            .map(
              (json) => ProductModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to load products: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Product loading failed: $e');
    }
  }
}
