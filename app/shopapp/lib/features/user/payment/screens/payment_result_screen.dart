import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool success;

  const PaymentResultScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 10),
            Text(
              success ? "THANH TOÁN THÀNH CÔNG" : "THANH TOÁN THẤT BẠI",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("VỀ TRANG CHỦ"),
            ),
          ],
        ),
      ),
    );
  }
}
