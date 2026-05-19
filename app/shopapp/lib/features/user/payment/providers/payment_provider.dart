import 'package:flutter/material.dart';
import '../../../../models/checkout_request.dart';
import '../../../../repositories/interfaces/i_payment_repository.dart';

/// Provider quản lý trạng thái tạo thanh toán và URL thanh toán.
class PaymentProvider extends ChangeNotifier {
  final IPaymentRepository repository;

  PaymentProvider(this.repository);

  /// Cờ loading khi gửi yêu cầu checkout lên backend.
  bool _loading = false;
  bool get loading => _loading;

  /// URL thanh toán trả về từ cổng thanh toán.
  String? _paymentUrl;
  String? get paymentUrl => _paymentUrl;

  /// Id đơn hàng liên quan đến phiên thanh toán hiện tại.
  int? _orderId;
  int? get orderId => _orderId;

  /// Gửi request checkout lên backend để lấy URL thanh toán.
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

  /// Xóa dữ liệu thanh toán cũ sau khi hoàn tất hoặc rời flow thanh toán.
  void clear() {
    _paymentUrl = null;
    _orderId = null;
    notifyListeners();
  }
}
