import '../core/api/api_client.dart';
import '../models/checkout_request.dart';

class PaymentService {
  /// Thuc hien quy trinh thanh toan don hang.
  Future<String> checkout(CheckoutRequest request) async {
    final data = {
      ...request.toJson(),

      "Phone": request.shippingPhone,
      "Address": request.shippingAddress,
    };

    final res = await ApiClient.dio.post(
      "/api/payment/create-vnpay-url",
      data: data,
    );

    return res.data["paymentUrl"];
  }
}
