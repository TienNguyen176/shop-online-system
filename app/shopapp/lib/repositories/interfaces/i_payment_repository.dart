import '../../models/checkout_request.dart';

abstract class IPaymentRepository {
  Future<String> checkout(CheckoutRequest request);
}
