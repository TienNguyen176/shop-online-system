class OrderItem {
  final int productId;
  final int variantId;

  final String productName;
  final String variantName;

  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "variantId": variantId,
    "productName": productName,
    "variantName": variantName,
    "quantity": quantity,
    "price": price,
  };
}
