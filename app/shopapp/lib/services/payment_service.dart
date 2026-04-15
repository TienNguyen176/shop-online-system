import '../core/api/api_client.dart';
import '../models/checkout_request.dart';

class PaymentService {
  Future<String> checkout(CheckoutRequest request) async {
    final res = await ApiClient.dio.post(
      "/api/payment/checkout",
      data: request.toJson(),
    );

    return res.data["paymentUrl"];
  }
}
