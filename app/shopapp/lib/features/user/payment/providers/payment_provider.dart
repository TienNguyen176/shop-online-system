import 'package:flutter/material.dart';
import '../../../../models/checkout_request.dart';
import '../../../../repositories/interfaces/i_payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final IPaymentRepository repository;

  PaymentProvider(this.repository);

  bool _loading = false;
  bool get loading => _loading;

  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;

  int? _orderId;
  int? get orderId => _orderId;

  Future<void> checkout(CheckoutRequest request) async {
    try {
      _loading = true;
      notifyListeners();

      final url = await repository.checkout(request);

      _paymentUrl = url;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _paymentUrl = null;
    _orderId = null;
    notifyListeners();
  }
}
