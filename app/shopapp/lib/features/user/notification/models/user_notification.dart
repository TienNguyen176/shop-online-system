class UserNotification {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool read;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
  });
}
