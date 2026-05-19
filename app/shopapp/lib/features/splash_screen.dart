import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user/auth/providers/auth_provider.dart';
import 'user/cart/providers/cart_provider.dart';
import '../repositories/interfaces/i_category_repository.dart';

import '../routes/app_routes.dart';

/// Màn splash: khởi động app, restore session và điều hướng theo trạng thái đăng nhập.
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

  /// Tải dữ liệu nền, khôi phục phiên đăng nhập và điều hướng tới màn phù hợp.
  Future<void> initApp() async {
    try {
      setState(() => loadingText = "Đang tải dữ liệu...");

      final categoryRepo = context.read<ICategoryRepository>();
      final auth = context.read<AuthProvider>();

      /// LOAD DATA
      await Future.wait([
        categoryRepo.getCategories(),
        auth.restoreSession(),
      ]).timeout(const Duration(seconds: 10));

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final userId = _userIdFrom(auth.user);
      final role = _roleFrom(auth.user);

      if (auth.isLoggedIn && role == "admin") {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.admin,
          arguments: userId ?? 0,
        );
        return;
      }

      if (auth.isLoggedIn) {
        if (userId != null) {
          await context.read<CartProvider>().loadCart(userId);
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.login);
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

  /// Lấy userId từ dữ liệu user, hỗ trợ cả key thường và key viết hoa.
  int? _userIdFrom(Map<String, dynamic>? user) {
    final id = user?["id"] ?? user?["Id"];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? "");
  }

  /// Lấy role của user để quyết định vào admin hay home người dùng.
  String _roleFrom(Map<String, dynamic>? user) {
    final role = user?["role"] ?? user?["Role"];
    return role?.toString().trim().toLowerCase() ?? "user";
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
