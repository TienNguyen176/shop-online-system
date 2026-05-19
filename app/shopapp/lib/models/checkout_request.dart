import 'order_item.dart';

/// Model gom toàn bộ dữ liệu cần gửi lên backend khi người dùng thanh toán.
class CheckoutRequest {
  /// ID của người dùng đang đặt hàng.
  final int userId;

  /// Tổng số tiền cần thanh toán, đã bao gồm phí vận chuyển nếu có.
  final double amount;

  /// Tên người thanh toán/khách hàng.
  final String name;

  /// Loại giao dịch gửi sang cổng thanh toán.
  final String orderType;

  /// Nội dung mô tả đơn hàng hiển thị ở hệ thống thanh toán.
  final String orderDescription;

  /// Danh sách sản phẩm được chọn để tạo đơn hàng.
  final List<OrderItem> items;

  /// Tên người nhận hàng.
  final String shippingName;

  /// Số điện thoại người nhận hàng.
  final String shippingPhone;

  /// Địa chỉ giao hàng đầy đủ.
  final String shippingAddress;

  /// Khởi tạo request thanh toán với đầy đủ thông tin đơn hàng và giao hàng.
  CheckoutRequest({
    required this.userId,
    required this.amount,
    required this.name,
    required this.orderType,
    required this.orderDescription,
    required this.items,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
  });

  /// Chuyển model Dart thành JSON để gửi qua API tạo URL thanh toán.
  Map<String, dynamic> toJson() => {
    "userId": userId,
    "amount": amount,
    "name": name,
    "orderType": orderType,
    "orderDescription": orderDescription,
    "items": items.map((e) => e.toJson()).toList(),
    "shippingName": shippingName,
    "shippingPhone": shippingPhone,
    "shippingAddress": shippingAddress,
  };
}
