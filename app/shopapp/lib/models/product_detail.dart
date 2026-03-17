import 'product_variant.dart';
import 'attribute_model.dart';

class ProductDetail {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final double minPrice;
  final double rating;
  final List<AttributeModel> attributes;
  final List<ProductVariant> variants;
  final Map<String, String> imagesByColor;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.minPrice,
    required this.rating,
    required this.attributes,
    required this.variants,
    required this.imagesByColor,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images']),
      minPrice: (json['minPrice'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      attributes: (json['attributes'] as List)
          .map((e) => AttributeModel.fromJson(e))
          .toList(),
      variants: (json['variants'] as List)
          .map((e) => ProductVariant.fromJson(e))
          .toList(),
      imagesByColor: Map<String, String>.from(json['imagesByColor']),
    );
  }
}