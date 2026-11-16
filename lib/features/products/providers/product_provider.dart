
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/product.dart';
import '../domain/repositories/product_repository.dart';
import '../data/repositories/product_repository_impl.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProducts();
});
