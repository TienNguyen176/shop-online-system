import '../../models/checkout_request.dart';
import '../../services/payment_service.dart';
import '../interfaces/i_payment_repository.dart';

class PaymentRepository implements IPaymentRepository {
  final PaymentService service = PaymentService();

  /// CACHE
  String? _lastPaymentUrl;

  @override
  Future<String> checkout(CheckoutRequest request) async {
    final url = await service.checkout(request);

    _lastPaymentUrl = url;

    return url;
  }

  /// OPTIONAL: reuse last payment (retry flow)
  String? get lastPaymentUrl => _lastPaymentUrl;
}
