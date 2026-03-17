import 'package:flutter/material.dart';
import '../repositories/i_product_repository.dart';
import '../repositories/i_category_repository.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final IProductRepository productRepo;
  final ICategoryRepository categoryRepo;

  const SplashScreen({
    super.key,
    required this.productRepo,
    required this.categoryRepo,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String loadingText = "Đang khởi động...";

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    try {
      setState(() => loadingText = "Đang tải dữ liệu...");

      await Future.wait([
        widget.productRepo.getHomeProducts(page: 1),
        widget.productRepo.getHomeProducts(page: 2),
        widget.categoryRepo.getCategories(),
      ]).timeout(const Duration(seconds: 10));

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() => loadingText = "Hoàn tất");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(repo: widget.productRepo)),
      );
    } catch (e) {
      //debugPrint("Splash error: $e");

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
                    initApp(); // retry
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

            // Loading
            const CircularProgressIndicator(),

            const SizedBox(height: 16),

            // Text trạng thái
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
