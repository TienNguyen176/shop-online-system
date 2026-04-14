class CartItem {
  final int id;
  final String name;
  final double price;
  final String image;
  final double rating;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json["id"] ?? 0) as int,
      name: json["name"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
      image: json["image"] ?? "",
      rating: (json["rating"] ?? 0).toDouble(),
      quantity: json["quantity"] ?? 0,
    );
  }
}