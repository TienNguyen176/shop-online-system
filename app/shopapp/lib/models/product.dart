import 'product_image.dart';
import 'product_variant.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final int? categoryId;
  final String? brand;

  final double ratingAvg;
  final int ratingCount;

  final DateTime? createdAt;

  // optional fields (API home)
  final double? price;
  final String? image;

  // relations (API detail)
  final List<ProductImage>? images;
  final List<ProductVariant>? variants;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.brand,
    required this.ratingAvg,
    required this.ratingCount,
    this.createdAt,
    this.price,
    this.image,
    this.images,
    this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"] ?? "",
      description: json["description"],
      categoryId: json["category_id"],
      brand: json["brand"],

      // hỗ trợ cả rating_avg và rating
      ratingAvg: ((json["rating_avg"] ?? json["rating"]) ?? 0).toDouble(),

      ratingCount: json["rating_count"] ?? 0,

      createdAt:
          json["created_at"] != null
              ? DateTime.parse(json["created_at"])
              : null,

      // API home
      price: json["price"] != null ? (json["price"] as num).toDouble() : null,
      image: json["image"],

      // API detail
      images:
          json["images"] != null
              ? (json["images"] as List)
                  .map((e) => ProductImage.fromJson(e))
                  .toList()
              : null,

      variants:
          json["variants"] != null
              ? (json["variants"] as List)
                  .map((e) => ProductVariant.fromJson(e))
                  .toList()
              : null,
    );
  }

  // Lấy ảnh chính
  String? get mainImage {
    if (images != null && images!.isNotEmpty) {
      try {
        return images!.firstWhere((e) => e.isMain).imageUrl;
      } catch (_) {
        return images!.first.imageUrl;
      }
    }

    // fallback API home
    return image;
  }

  // Lấy giá thấp nhất
  double get minPrice {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    }

    // fallback API home
    return price ?? 0;
  }
}
