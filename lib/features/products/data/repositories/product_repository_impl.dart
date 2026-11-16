
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({
    ProductRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? ProductRemoteDataSource();

  @override
  Future<List<Product>> getProducts() async {
    return _remoteDataSource.fetchProducts();
  }
}
