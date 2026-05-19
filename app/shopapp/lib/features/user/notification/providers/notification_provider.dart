import 'package:flutter/material.dart';

import '../data/notification_mock_data.dart';
import '../models/user_notification.dart';

/// Provider quản lý thông báo người dùng: tải dữ liệu, đếm chưa đọc và cập nhật trạng thái đọc.
class NotificationProvider extends ChangeNotifier {
  /// Trạng thái loading khi tải danh sách thông báo.
  bool loading = false;

  /// Danh sách thông báo đang hiển thị.
  List<UserNotification> notifications = [];

  /// Đếm số lượng thông báo chưa đọc để hiển thị badge.
  int get unreadCount =>
      notifications.where((notification) => !notification.read).length;

  /// Tải danh sách thông báo từ mock data, sau này có thể đổi sang API thật.
  Future<void> loadNotifications() async {
    /// Bật loading để UI hiển thị trạng thái chờ.
    loading = true;
    notifyListeners();

    /// Giả lập độ trễ gọi API.
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    /// Copy dữ liệu mock để tránh sửa trực tiếp danh sách gốc.
    notifications = List<UserNotification>.from(
      mockNotifications,
    );

    /// Tắt loading sau khi đã có dữ liệu.
    loading = false;

    /// Báo cho UI render lại.
    notifyListeners();
  }

  /// Đánh dấu tất cả thông báo là đã đọc.
  void markAllAsRead() {
    /// Duyệt toàn bộ thông báo và cập nhật trạng thái.
    for (final notification in notifications) {
      notification.read = true;
    }

    /// Cập nhật UI sau khi thay đổi dữ liệu.
    notifyListeners();
  }

  /// Đánh dấu một thông báo là đã đọc theo id.
  void markAsRead(int id) {
    /// Tìm vị trí thông báo trong danh sách hiện tại.
    final index = notifications.indexWhere(
      (item) => item.id == id,
    );

    /// Nếu tìm thấy thì cập nhật trạng thái đọc và refresh UI.
    if (index != -1) {
      notifications[index].read = true;
      notifyListeners();
    }
  }

  /// Xóa toàn bộ thông báo khỏi danh sách đang hiển thị.
  void clearAll() {
    notifications.clear();
    notifyListeners();
  }
}
