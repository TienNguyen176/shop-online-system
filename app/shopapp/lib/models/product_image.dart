class ProductImage {
  final int id;
  final int productId;
  final String imageUrl;
  final bool isMain;

  ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isMain,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json["id"],
      productId: json["product_id"],
      imageUrl: json["image_url"] ?? "",
      isMain: json["is_main"] == 1 || json["is_main"] == true,
    );
  }
}
