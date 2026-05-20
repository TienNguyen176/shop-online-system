class UserNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  bool read;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = "",
    required this.createdAt,
    this.read = false,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      title: json["title"]?.toString() ?? "",
      message: json["message"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? "") ??
          DateTime.now(),
      read: json["isRead"] == true ||
          json["is_read"] == true ||
          json["read"] == true ||
          json["isRead"]?.toString() == "1",
    );
  }
}
