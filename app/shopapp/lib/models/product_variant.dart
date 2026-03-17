class ProductVariant {
  final int id;
  final String? sku;
  final double price;
  final int stockQuantity;
  final DateTime? createdAt;

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
