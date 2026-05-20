import '../../models/checkout_request.dart';

abstract class IPaymentRepository {
  /// Thuc hien quy trinh thanh toan don hang.
  Future<String> checkout(CheckoutRequest request);
}
