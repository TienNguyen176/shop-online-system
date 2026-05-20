class AdminProduct {
  final int id;
  final String name;
  final String? image;
  final int? categoryId;
  final String? categoryName;
  final String? brand;
  final String? description;
  final double? rating;

  const AdminProduct({
    required this.id,
    required this.name,
    this.image,
    this.categoryId,
    this.categoryName,
    this.brand,
    this.description,
    required this.rating,
  });

  /// Tao doi tuong tu du lieu JSON.
  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      brand: json['brand'],
      description: json['description'],
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
