class AdminReturnRequestModel {
  final int id;
  final int orderId;
  final int userId;
  final String reason;
  final String status;
  final DateTime? createdAt;
  final String orderCode;
  final String orderStatus;
  final double totalPrice;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final DateTime? deliveredAt;

  const AdminReturnRequestModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.orderCode,
    required this.orderStatus,
    required this.totalPrice,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.deliveredAt,
  });

  /// Tao doi tuong tu du lieu JSON.
  factory AdminReturnRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminReturnRequestModel(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      orderId: int.tryParse(json["orderId"]?.toString() ?? "") ?? 0,
      userId: int.tryParse(json["userId"]?.toString() ?? "") ?? 0,
      reason: json["reason"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      createdAt: _dateOf(json["createdAt"]),
      orderCode: json["orderCode"]?.toString() ?? "",
      orderStatus: json["orderStatus"]?.toString() ?? "",
      totalPrice: double.tryParse(json["totalPrice"]?.toString() ?? "") ?? 0,
      shippingName: json["shippingName"]?.toString() ?? "",
      shippingPhone: json["shippingPhone"]?.toString() ?? "",
      shippingAddress: json["shippingAddress"]?.toString() ?? "",
      deliveredAt: _dateOf(json["deliveredAt"]),
    );
  }
}

/// Chuyen doi gia tri dong thanh doi tuong DateTime neu hop le.
DateTime? _dateOf(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
