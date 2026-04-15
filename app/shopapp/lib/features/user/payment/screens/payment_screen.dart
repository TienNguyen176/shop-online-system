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
              title: const Text("MoMo"),
              onChanged: (v) => setState(() => method = v!),
            ),

            const SizedBox(height: 20),

            // BUTTON
            ElevatedButton(
              onPressed:
                  provider.loading
                      ? null
                      : () async {
                        final updatedRequest = CheckoutRequest(
                          userId: widget.request.userId,
                          totalPrice: widget.request.totalPrice,
                          paymentMethodId: method,
                          shippingName: nameCtrl.text,
                          shippingPhone: phoneCtrl.text,
                          shippingAddress: addressCtrl.text,
                          items: widget.request.items,
                        );

                        await context.read<PaymentProvider>().checkout(
                          updatedRequest,
                        );

                        if (context.read<PaymentProvider>().paymentUrl !=
                            null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PaymentWebViewScreen(
                                    url:
                                        context
                                            .read<PaymentProvider>()
                                            .paymentUrl!,
                                  ),
                            ),
                          );
                        }
                      },
              child:
                  provider.loading
                      ? const CircularProgressIndicator()
                      : const Text("ĐẶT HÀNG"),
            ),
          ],
        ),
      ),
    );
  }
}
