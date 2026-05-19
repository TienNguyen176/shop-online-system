/// Model biểu diễn một sản phẩm nằm trong đơn hàng hoặc request thanh toán.
class OrderItem {
  /// ID sản phẩm gốc.
  final int productId;

  /// ID biến thể sản phẩm được chọn.
  final int variantId;

  /// Tên sản phẩm hiển thị.
  final String productName;

  /// Tên biến thể, ví dụ màu sắc/kích thước.
  final String variantName;

  /// Đường dẫn ảnh đại diện của sản phẩm.
  final String image;

  /// Số lượng sản phẩm trong đơn.
  final int quantity;

  /// Đơn giá tại thời điểm đặt hàng.
  final double price;

  /// Khởi tạo một item trong đơn hàng.
  OrderItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.image,
    required this.quantity,
    required this.price,
  });

  /// Tạo item từ JSON backend trả về.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: int.tryParse(json["productId"]?.toString() ?? "") ?? 0,
      variantId: int.tryParse(json["variantId"]?.toString() ?? "") ?? 0,
      productName: json["productName"]?.toString() ?? "",
      variantName: json["variantName"]?.toString() ?? "",
      image: json["image"]?.toString() ?? "",
      quantity: int.tryParse(json["quantity"]?.toString() ?? "") ?? 0,
      price: double.tryParse(json["price"]?.toString() ?? "") ?? 0.0,
    );
  }

  /// Chuyển item thành JSON để gửi lên backend khi checkout.
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
