import 'order_item.dart';

class CheckoutRequest {
  final double amount;
  final String name;
  final String orderType;
  final String orderDescription;

  final List<OrderItem> items;

  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;

  CheckoutRequest({
    required this.amount,
    required this.name,
    required this.orderType,
    required this.orderDescription,
    required this.items,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
  });

  Map<String, dynamic> toJson() => {
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
