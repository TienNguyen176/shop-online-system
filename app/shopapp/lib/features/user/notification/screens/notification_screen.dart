import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

/// =======================================================
/// SCREEN HIỂN THỊ DANH SÁCH THÔNG BÁO
/// =======================================================
/// Màn hình thông báo của người dùng.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  /// Kiểm tra đã load dữ liệu lần đầu chưa
  bool _initialized = false;

  /// Xu ly khi dependency cua widget thay doi.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Chỉ load dữ liệu 1 lần duy nhất
    if (!_initialized) {
      _initialized = true;

      /// Delay sau khi build xong widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<NotificationProvider>()
            .loadNotifications(forceRefresh: true);
      });
    }
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ===================================================
      /// APP BAR
      /// ===================================================
      appBar: AppBar(
        title: const Text('Thông báo'),

        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.mark_email_read),

                /// Disable nút nếu không có thông báo
                onPressed:
                    provider.notifications.isEmpty
                        ? null
                        : () => provider.markAllAsRead(),

                tooltip: 'Đánh dấu đã đọc',
              );
            },
          ),
        ],
      ),

      /// ===================================================
      /// BODY
      /// ===================================================
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          /// Loading dữ liệu
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 10),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => provider.loadNotifications(
                        forceRefresh: true,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Thá»­ láº¡i"),
                    ),
                  ],
                ),
              ),
            );
          }

          /// Không có thông báo
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có thông báo nào.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          /// Danh sách thông báo
          return ListView.separated(
            padding: const EdgeInsets.all(16),

            itemCount: provider.notifications.length,

            separatorBuilder: (context, index) => const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final notification = provider.notifications[index];

              return Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(12),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  /// =========================================
                  /// ICON THÔNG BÁO
                  /// =========================================
                  leading: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.notifications, color: Colors.white),
                      ),

                      /// Chấm đỏ nếu chưa đọc
                      if (!notification.read)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  /// =========================================
                  /// TIÊU ĐỀ
                  /// =========================================
                  title: Text(
                    notification.title,

                    /// Bold nếu chưa đọc
                    style: TextStyle(
                      fontWeight:
                          notification.read
                              ? FontWeight.normal
                              : FontWeight.bold,
                    ),
                  ),

                  /// =========================================
                  /// NỘI DUNG + THỜI GIAN
                  /// =========================================
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      /// Nội dung thông báo
                      Text(notification.message),

                      const SizedBox(height: 8),

                      /// Thời gian tạo
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  /// =========================================
                  /// NÚT ĐÁNH DẤU ĐÃ ĐỌC
                  /// =========================================
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),

                    /// Disable nếu đã đọc
                    onPressed:
                        notification.read
                            ? null
                            : () {
                              context.read<NotificationProvider>().markAsRead(
                                notification.id,
                              );
                            },

                    tooltip: 'Đánh dấu đã đọc',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// =======================================================
  /// FORMAT THỜI GIAN HIỂN THỊ
  /// =======================================================
  ///
  /// VD:
  /// - 5 phút trước
  /// - 2 giờ trước
  /// - 3 ngày trước
  ///
  /// Định dạng ngày thông báo thành chuỗi dễ đọc.
  String _formatDate(DateTime date) {
    final now = DateTime.now();

    /// Khoảng cách thời gian
    final difference = now.difference(date);

    /// Dưới 60 phút
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    }

    /// Dưới 24 giờ
    if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    }

    /// Theo ngày
    return '${difference.inDays} ngày trước';
  }
}
