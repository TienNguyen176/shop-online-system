import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'payment_result_screen.dart';

/// Màn WebView mở cổng thanh toán VNPay và theo dõi kết quả redirect.
class PaymentWebViewScreen extends StatefulWidget {
  final String url;

  const PaymentWebViewScreen({super.key, required this.url});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController controller;
  bool _handledResult = false;

  @override
  /// Khởi tạo WebViewController và cấu hình xử lý URL callback thanh toán.
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final url = request.url;
                final uri = Uri.tryParse(url);

                if (_isVnPayReturn(uri)) {
                  final responseCode = uri?.queryParameters["vnp_ResponseCode"];
                  final transactionStatus =
                      uri?.queryParameters["vnp_TransactionStatus"];
                  final success =
                      responseCode == "00" &&
                      (transactionStatus == null || transactionStatus == "00");

                  _openResult(success);
                  return NavigationDecision.prevent;
                }

                // SUCCESS
                if (url.contains("payment-success")) {
                  _openResult(true);
                  return NavigationDecision.prevent;
                }

                // FAIL
                if (url.contains("payment-fail")) {
                  _openResult(false);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: WebViewWidget(controller: controller),
    );
  }

  bool _isVnPayReturn(Uri? uri) {
    if (uri == null) return false;

    return uri.path.contains("/api/payment/vnpay-return") ||
        uri.path.contains("/payment/vnpay-return");
  }

  void _openResult(bool success) {
    if (_handledResult || !mounted) return;
    _handledResult = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(success: success),
      ),
    );
  }
}
