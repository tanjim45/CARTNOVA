
import 'package:cartnova_app/features/products/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.brand,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.thumbnail,
    required super.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail']?.toString() ?? '';

    return ProductModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Unknown',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discountPercentage: double.tryParse(
            (json['discount_percentage'] ??
                    json['discountPercentage'])
                ?.toString() ??
                '',
          ) ??
          0,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      thumbnail: thumbnail,
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => image.toString())
              .toList() ??
          (thumbnail.isNotEmpty ? [thumbnail] : []),
    );
  }
}
