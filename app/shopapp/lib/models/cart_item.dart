class CartItem {
  final int id;

  // product info
  final int productId;
  final int variantId;

  final String name;
  final String variantName;

  final double price;
  final String image;
  final double rating;

  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.name,
    required this.variantName,
    required this.price,
    required this.image,
    required this.rating,
    required this.quantity,
  });

  /// Tao doi tuong tu du lieu JSON.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json["id"] ?? 0,

      productId: json["productId"] ?? 0,
      variantId: json["variantId"] ?? 0,

      name: json["name"] ?? "",
      variantName: json["variantName"] ?? "",

      price: (json["price"] ?? 0).toDouble(),
      image: json["image"] ?? "",
      rating: (json["rating"] ?? 0).toDouble(),

      quantity: json["quantity"] ?? 0,
    );
  }
}
