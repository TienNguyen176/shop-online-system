class ReturnRequestModel {
  final int id;
  final int orderId;
  final int userId;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const ReturnRequestModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  /// Tao doi tuong tu du lieu JSON.
  factory ReturnRequestModel.fromJson(Map<String, dynamic> json) {
    return ReturnRequestModel(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      orderId: int.tryParse(json["orderId"]?.toString() ?? "") ?? 0,
      userId: int.tryParse(json["userId"]?.toString() ?? "") ?? 0,
      reason: json["reason"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      createdAt: _dateOf(json["createdAt"] ?? json["created_at"]),
    );
  }
}

/// Chuyen doi gia tri dong thanh doi tuong DateTime neu hop le.
DateTime? _dateOf(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
