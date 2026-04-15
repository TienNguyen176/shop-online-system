import 'order_item.dart';

class CheckoutRequest {
  final int userId;
  final double totalPrice;
  final int paymentMethodId;

  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;

  final List<OrderItem> items;

  CheckoutRequest({
    required this.userId,
    required this.totalPrice,
    required this.paymentMethodId,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "totalPrice": totalPrice,
    "paymentMethodId": paymentMethodId,
    "shippingName": shippingName,
    "shippingPhone": shippingPhone,
    "shippingAddress": shippingAddress,
    "items": items.map((e) => e.toJson()).toList(),
  };
}
