import '../../../../core/api/api_client.dart';
import '../models/user_notification.dart';

class NotificationService {
  /// Lay du lieu cho getNotifications.
  Future<List<UserNotification>> getNotifications() async {
    final res = await ApiClient.dio.get("/api/notifications");

    final data = res.data;
    final List raw = data is List ? data : data["data"] ?? [];

    return raw
        .map((e) => UserNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Cap nhat trang thai danh dau cho thong bao.
  Future<void> markAsRead(int id) async {
    await ApiClient.dio.put("/api/notifications/$id/read");
  }

  /// Cap nhat trang thai danh dau cho thong bao.
  Future<void> markAllAsRead() async {
    await ApiClient.dio.put("/api/notifications/read-all");
  }
}
