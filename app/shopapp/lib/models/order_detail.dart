import 'order_item.dart';
import 'return_request.dart';

/// Model chứa chi tiết đầy đủ của một đơn hàng.
class OrderDetail {
  /// ID đơn hàng trong database.
  final int id;

  /// Mã đơn hàng hiển thị cho người dùng.
  final String orderCode;

  /// Trạng thái hiện tại của đơn hàng.
  final String status;

  /// Tổng tiền hàng, chưa bao gồm phí vận chuyển.
  final double subtotalPrice;

  /// Phí vận chuyển của đơn hàng.
  final double shippingFee;

  /// Tổng tiền cuối cùng cần thanh toán.
  final double totalPrice;

  /// Tên người nhận hàng.
  final String shippingName;

  /// Số điện thoại người nhận.
  final String shippingPhone;

  /// Địa chỉ giao hàng đầy đủ.
  final String shippingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final ReturnRequestModel? returnRequest;

  /// Danh sách sản phẩm trong đơn hàng.
  final List<OrderItem> items;

  /// Khởi tạo chi tiết đơn hàng.
  const OrderDetail({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.subtotalPrice,
    required this.shippingFee,
    required this.totalPrice,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveredAt,
    required this.returnRequest,
    required this.items,
  });

  /// Tạo chi tiết đơn hàng từ JSON backend trả về.
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];
    final items =
        rawItems is List
            ? rawItems
                .map(
                  (item) => OrderItem.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
            : <OrderItem>[];

    return OrderDetail(
      id: int.tryParse(json["id"]?.toString() ?? "") ?? 0,
      orderCode: json["orderCode"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      subtotalPrice:
          double.tryParse(json["subtotalPrice"]?.toString() ?? "") ?? 0.0,
      shippingFee:
          double.tryParse(json["shippingFee"]?.toString() ?? "") ?? 0.0,
      totalPrice: double.tryParse(json["totalPrice"]?.toString() ?? "") ?? 0.0,
      shippingName: json["shippingName"]?.toString() ?? "",
      shippingPhone: json["shippingPhone"]?.toString() ?? "",
      shippingAddress: json["shippingAddress"]?.toString() ?? "",
      createdAt: _dateOf(json["createdAt"] ?? json["created_at"]),
      updatedAt: _dateOf(json["updatedAt"] ?? json["updated_at"]),
      deliveredAt: _dateOf(json["deliveredAt"] ?? json["delivered_at"]),
      returnRequest:
          json["returnRequest"] == null
              ? null
              : ReturnRequestModel.fromJson(
                Map<String, dynamic>.from(json["returnRequest"]),
              ),
      items: items,
    );
  }

  /// Tạo bản sao đơn hàng với thông tin giao hàng mới, giữ nguyên dữ liệu còn lại.
  OrderDetail copyWith({
    String? shippingName,
    String? shippingPhone,
    String? shippingAddress,
  }) {
    return OrderDetail(
      id: id,
      orderCode: orderCode,
      status: status,
      subtotalPrice: subtotalPrice,
      shippingFee: shippingFee,
      totalPrice: totalPrice,
      shippingName: shippingName ?? this.shippingName,
      shippingPhone: shippingPhone ?? this.shippingPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deliveredAt: deliveredAt,
      returnRequest: returnRequest,
      items: items,
    );
  }
}

DateTime? _dateOf(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
