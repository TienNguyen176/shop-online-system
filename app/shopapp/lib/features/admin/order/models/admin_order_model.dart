class AdminOrderModel {
  final int id;
  final String orderCode;
  final int userId;
  final String status;
  final double subtotalPrice;
  final double shippingFee;
  final double totalPrice;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const AdminOrderModel({
    required this.id,
    required this.orderCode,
    required this.userId,
    required this.status,
    required this.subtotalPrice,
    required this.shippingFee,
    required this.totalPrice,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveredAt,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      orderCode: json["orderCode"]?.toString() ?? "",
      userId: int.tryParse(json["userId"]?.toString() ?? "") ?? 0,
      status: json["status"]?.toString() ?? "",
      subtotalPrice: _doubleOf(json["subtotalPrice"]),
      shippingFee: _doubleOf(json["shippingFee"]),
      totalPrice: _doubleOf(json["totalPrice"]),
      shippingName: json["shippingName"]?.toString() ?? "",
      shippingPhone: json["shippingPhone"]?.toString() ?? "",
      shippingAddress: json["shippingAddress"]?.toString() ?? "",
      createdAt: _dateOf(json["createdAt"]),
      updatedAt: _dateOf(json["updatedAt"]),
      deliveredAt: _dateOf(json["deliveredAt"]),
    );
  }

  static double _doubleOf(dynamic value) {
    return double.tryParse(value?.toString() ?? "") ?? 0;
  }

  static DateTime? _dateOf(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
