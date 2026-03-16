class ProductVariant {
  final int id;
  final int productId;
  final String? sku;
  final double price;
  final int stockQuantity;
  final DateTime? createdAt;

  ProductVariant({
    required this.id,
    required this.productId,
    this.sku,
    required this.price,
    required this.stockQuantity,
    this.createdAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json["id"],
      productId: json["product_id"],
      sku: json["sku"],
      price: (json["price"] ?? 0).toDouble(),
      stockQuantity: json["stock_quantity"] ?? 0,
      createdAt:
          json["created_at"] != null
              ? DateTime.parse(json["created_at"])
              : null,
    );
  }
}
