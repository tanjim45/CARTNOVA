
import 'dart:convert';

import 'package:cartnova_app/core/constants/api_constants.dart';
import 'package:cartnova_app/features/products/data/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRemoteDataSource {
  final http.Client _client;

  ProductRemoteDataSource({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final List<ProductModel> allProducts = [];

      int currentPage = 1;
      int lastPage = 1;

      do {
        final url = Uri.parse(
          '${ApiConstants.baseUrl}/products?page=$currentPage',
        );

        final response = await _client
            .get(url)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw Exception(
            'Failed to load products: ${response.statusCode}',
          );
        }

        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] != true) {
          throw Exception(
            responseData['message'] ?? 'Product loading failed',
          );
        }

        final Map<String, dynamic> paginationData =
            responseData['data'] as Map<String, dynamic>;

        final List<dynamic> productsJson =
            paginationData['data'] as List<dynamic>;

        allProducts.addAll(
          productsJson.map(
            (json) => ProductModel.fromJson(
              json as Map<String, dynamic>,
            ),
          ),
        );

        lastPage = (paginationData['last_page'] as num).toInt();
        currentPage++;
      } while (currentPage <= lastPage);

      return allProducts;
    } catch (e) {
      throw Exception('Product loading failed: $e');
    }
  }
}
