import '../core/api/api_client.dart';
import '../models/checkout_request.dart';

class PaymentService {
  Future<String> checkout(CheckoutRequest request) async {

    final data = {
      ...request.toJson(),

      // 🔥 thêm 2 dòng này (QUAN TRỌNG)
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

