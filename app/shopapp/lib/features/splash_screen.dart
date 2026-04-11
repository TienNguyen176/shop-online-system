import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/interfaces/i_category_repository.dart';

import 'user/home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String loadingText = "Đang khởi động...";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initApp();
    });
  }

  Future<void> initApp() async {
    try {
      setState(() => loadingText = "Đang tải dữ liệu...");

      final categoryRepo = context.read<ICategoryRepository>();

      /// LOAD DATA
      await Future.wait([
        categoryRepo.getCategories(),
      ]).timeout(const Duration(seconds: 10));

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HomeScreen()),
      // );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Lỗi"),
              content: const Text("Không thể tải dữ liệu"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    initApp();
                  },
                  child: const Text("Thử lại"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef2fb),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/icon.jpg",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            const CircularProgressIndicator(),

            const SizedBox(height: 16),

            Text(
              loadingText,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
