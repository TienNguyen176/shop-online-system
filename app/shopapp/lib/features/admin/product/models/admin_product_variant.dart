class AdminProductVariant {
  final int id;
  final String? sku;
  final double price;
  final int stockQuantity;
  final Map<String, String> attributes;

  const AdminProductVariant({
    required this.id,
    this.sku,
    required this.price,
    required this.stockQuantity,
    required this.attributes,
  });

  factory AdminProductVariant.fromJson(Map<String, dynamic> json) {
    return AdminProductVariant(
      id: json['id'],
      sku: json['sku']?.toString(),
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
    );
  }
}
