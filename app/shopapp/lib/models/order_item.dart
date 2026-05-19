class OrderItem {
  final int productId;
  final int variantId;

  final String productName;
  final String variantName;
  final String image;

  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.image,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "variantId": variantId,
    "productName": productName,
    "variantName": variantName,
    "image": image,
    "quantity": quantity,
    "price": price,
  };
}
