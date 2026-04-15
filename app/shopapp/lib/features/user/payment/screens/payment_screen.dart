import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/checkout_request.dart';
import '../providers/payment_provider.dart';
import 'payment_webview_screen.dart';

class PaymentScreen extends StatefulWidget {
  final CheckoutRequest request;

  const PaymentScreen({super.key, required this.request});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int method = 2; // 1 for COD, 2 for VNPAY, 3 for MoMo, 4 for Bank Transfer

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // SHIPPING INFO
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Họ tên"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "SĐT"),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: "Địa chỉ"),
            ),

            const SizedBox(height: 20),

            // PAYMENT METHOD
            RadioListTile<int>(
              value: 2,
              groupValue: method,
              title: const Text("VNPay"),
              onChanged: (v) => setState(() => method = v!),
            ),

            RadioListTile<int>(
              value: 3,
              groupValue: method,
              title: const Text("MoMo (coming soon)"),
              onChanged: null,
            ),

            const SizedBox(height: 20),

            // BUTTON
            ElevatedButton(
              onPressed:
                  provider.loading
                      ? null
                      : () async {
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final address = addressCtrl.text.trim();

                        if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vui lòng nhập đầy đủ thông tin"),
                            ),
                          );
                          return;
                        }

                        final amount = widget.request.items.fold(
                          0.0,
                          (sum, item) => sum + item.price * item.quantity,
                        );

                        final updatedRequest = CheckoutRequest(
                          amount: amount,
                          name: name,
                          orderType: "billpayment",
                          orderDescription: "Thanh toan don hang",
                          items: widget.request.items,
                          shippingName: name,
                          shippingPhone: phone,
                          shippingAddress: address,
                        );

                        await context.read<PaymentProvider>().checkout(
                          updatedRequest,
                        );

                        final url = context.read<PaymentProvider>().paymentUrl;

                        if (url != null && url.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentWebViewScreen(url: url),
                            ),
                          );
                        }
                      },
              child:
                  provider.loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text("ĐẶT HÀNG"),
            ),
          ],
        ),
      ),
    );
  }
}
