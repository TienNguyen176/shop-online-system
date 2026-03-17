class ProductVariant {
  final int id;
  final String? sku;
  final double price;
  final int stockQuantity;
  final DateTime? createdAt;
<<<<<<< HEAD
=======

>>>>>>> 4d9c391 (apply new gitignore rules)
  final Map<String, String> attributes;

  ProductVariant({
    required this.id,
    this.sku,
    required this.price,
    required this.stockQuantity,
    this.createdAt,
    required this.attributes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
<<<<<<< HEAD
      id: _safeInt(json["variantId"]),
      sku: json["sku"]?.toString(),
      price: _safeDouble(json["price"]),
      stockQuantity: _safeInt(json["stock"]),
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"].toString())
          : null,
      attributes: json["attributes"] != null
          ? Map<String, String>.from(json["attributes"])
          : {},
    );
  }

  // ✅ variantId trỏ đúng vào id — không còn null
  int get variantId => id;

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
=======
      id: json["variantId"] ?? 0,
      sku: json["sku"],
      price: (json["price"] ?? 0).toDouble(),
      stockQuantity: json["stock_quantity"] ?? 0,
      createdAt:
          json["created_at"] != null
              ? DateTime.parse(json["created_at"])
              : null,
      attributes: Map<String, String>.from(json['attributes']),
    );
  }
}
>>>>>>> 4d9c391 (apply new gitignore rules)
