import '../../../../core/api/api_client.dart';
import '../models/user_notification.dart';

class NotificationService {
  Future<List<UserNotification>> getNotifications() async {
    final res = await ApiClient.dio.get("/api/notifications");

    final data = res.data;
    final List raw = data is List ? data : data["data"] ?? [];

    return raw
        .map((e) => UserNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> markAsRead(int id) async {
    await ApiClient.dio.put("/api/notifications/$id/read");
  }

  Future<void> markAllAsRead() async {
    await ApiClient.dio.put("/api/notifications/read-all");
  }
}
