import 'package:flutter/material.dart';

import '../models/user_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  bool loading = false;
  String? error;
  List<UserNotification> notifications = [];

  int get unreadCount =>
      notifications.where((notification) => !notification.read).length;

  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (!forceRefresh && notifications.isNotEmpty) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      notifications = await _service.getNotifications();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();

    for (final notification in notifications) {
      notification.read = true;
    }

    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;

    await _service.markAsRead(id);
    notifications[index].read = true;
    notifyListeners();
  }

  void clearAll() {
    notifications.clear();
    notifyListeners();
  }
}
