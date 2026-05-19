class OrderModel {
  final int id;
  final String orderCode;
  final String status;
  final double? totalPrice;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.status,
    this.totalPrice,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
  });

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
