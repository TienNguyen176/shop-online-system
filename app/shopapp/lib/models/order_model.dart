/// Model rút gọn của đơn hàng dùng cho danh sách trạng thái đơn.
class OrderModel {
  /// ID đơn hàng.
  final int id;

  /// Mã đơn hàng hiển thị.
  final String orderCode;

  /// Trạng thái đơn hàng, ví dụ PENDING, PAID, DELIVERED, CANCEL.
  final String status;

  /// Tổng tiền đơn hàng.
  final double? totalPrice;

  /// Tên người nhận.
  final String shippingName;

  /// Số điện thoại người nhận.
  final String shippingPhone;

  /// Địa chỉ giao hàng.
  final String shippingAddress;

  /// Khởi tạo dữ liệu đơn hàng rút gọn.
  OrderModel({
    required this.id,
    required this.orderCode,
    required this.status,
    this.totalPrice,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
  });

  /// Tạo model đơn hàng từ JSON backend trả về.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["id"],
      orderCode: json["orderCode"] ?? "",
      status: json["status"] ?? "",
      totalPrice: (json["totalPrice"] as num?)?.toDouble() ?? 0.0,
      shippingName: json["shippingName"] ?? "",
      shippingPhone: json["shippingPhone"] ?? "",
      shippingAddress: json["shippingAddress"] ?? "",
    );
  }
}
