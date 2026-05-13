import '../models/user_notification.dart';

final List<UserNotification> mockNotifications = [
  UserNotification(
    id: 1,
    title: 'Đơn hàng mới',
    message: 'Đơn hàng #A123 đang được xử lý.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  UserNotification(
    id: 2,
    title: 'Giảm giá hấp dẫn',
    message: 'Giảm 10% cho đơn hàng tiếp theo của bạn.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  UserNotification(
    id: 3,
    title: 'Cập nhật sản phẩm',
    message: 'Sản phẩm yêu thích của bạn vừa có hàng trở lại.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
