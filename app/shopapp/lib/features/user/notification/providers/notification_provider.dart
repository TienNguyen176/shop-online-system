import 'package:flutter/material.dart';

import '../data/notification_mock_data.dart';
import '../models/user_notification.dart';

/// =======================================================
/// PROVIDER QUẢN LÝ THÔNG BÁO
/// =======================================================
///
/// Chức năng:
/// - Load danh sách thông báo
/// - Đếm số thông báo chưa đọc
/// - Đánh dấu đã đọc
/// - Đánh dấu tất cả đã đọc
/// - Xóa toàn bộ thông báo
///
class NotificationProvider extends ChangeNotifier {

  /// =====================================================
  /// STATE
  /// =====================================================

  /// Trạng thái loading dữ liệu
  bool loading = false;

  /// Danh sách thông báo
  List<UserNotification> notifications = [];

  /// =====================================================
  /// GETTER
  /// =====================================================

  /// Đếm số lượng thông báo chưa đọc
  int get unreadCount =>
      notifications
          .where((notification) => !notification.read)
          .length;

  /// =====================================================
  /// LOAD DANH SÁCH THÔNG BÁO
  /// =====================================================
  Future<void> loadNotifications() async {

    /// Bật loading
    loading = true;
    notifyListeners();

    /// Giả lập delay gọi API
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    /// Copy dữ liệu mock
    notifications = List<UserNotification>.from(
      mockNotifications,
    );

    /// Tắt loading
    loading = false;

    /// Cập nhật UI
    notifyListeners();
  }

  /// =====================================================
  /// ĐÁNH DẤU TẤT CẢ ĐÃ ĐỌC
  /// =====================================================
  void markAllAsRead() {

    /// Duyệt toàn bộ thông báo
    for (final notification in notifications) {

      /// Set trạng thái đã đọc
      notification.read = true;
    }

    /// Refresh UI
    notifyListeners();
  }

  /// =====================================================
  /// ĐÁNH DẤU 1 THÔNG BÁO ĐÃ ĐỌC
  /// =====================================================
  ///
  /// [id] = ID thông báo
  ///
  void markAsRead(int id) {

    /// Tìm vị trí thông báo theo ID
    final index = notifications.indexWhere(
      (item) => item.id == id,
    );

    /// Nếu tìm thấy
    if (index != -1) {

      /// Set trạng thái đã đọc
      notifications[index].read = true;

      /// Refresh UI
      notifyListeners();
    }
  }

  /// =====================================================
  /// XÓA TOÀN BỘ THÔNG BÁO
  /// =====================================================
  void clearAll() {

    /// Clear list
    notifications.clear();

    /// Refresh UI
    notifyListeners();
  }
}