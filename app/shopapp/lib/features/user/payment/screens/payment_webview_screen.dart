import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'payment_result_screen.dart';

/// Màn WebView mở cổng thanh toán VNPay và theo dõi kết quả redirect.
class PaymentWebViewScreen extends StatefulWidget {
  final String url;

  const PaymentWebViewScreen({super.key, required this.url});

  /// Tao state quan ly vong doi cua widget.
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

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: WebViewWidget(controller: controller),
    );
  }

  /// Mo man hinh hoac hop thoai lien quan.
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
