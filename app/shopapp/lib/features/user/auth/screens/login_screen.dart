import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffeef2fb),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff1d4ed8).withOpacity(0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset("assets/icon.jpg", fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Next4Shop",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff1f2937),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Đăng nhập để tiếp tục mua sắm",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff64748b),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _SocialLoginButton(
                    label: "Tiếp tục với Google",
                    assetPath: "assets/google_icon.jpg",
                    foregroundColor: const Color(0xff1f2937),
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xffdbe3ef),
                    loading: auth.loading,
                    onPressed: () async {
                      await auth.loginGoogle();
                      await _handleLoginResult(context, auth);
                    },
                  ),
                  const SizedBox(height: 14),
                  _SocialLoginButton(
                    label: "Tiếp tục với Facebook",
                    assetPath: "assets/facebook_icon.jpg",
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff1877f2),
                    borderColor: const Color(0xff1877f2),
                    loading: auth.loading,
                    onPressed: () async {
                      await auth.loginFacebook();
                      await _handleLoginResult(context, auth);
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child:
                        auth.loading
                            ? const SizedBox(
                              key: ValueKey("loading"),
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: Color(0xff2563eb),
                              ),
                            )
                            : const SizedBox(key: ValueKey("idle"), height: 26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _handleLoginResult(
    BuildContext context,
    AuthProvider auth,
  ) async {
    if (auth.accessToken != null && context.mounted) {
      final userId = _userIdFrom(auth.user);
      final role = _roleFrom(auth.user);

      if (role == "admin") {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.admin,
          arguments: userId ?? 0,
        );
        return;
      }

      if (userId != null) {
        await context.read<CartProvider>().loadCart(userId);
      }

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.userHome);
    }

    if (auth.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(auth.error!),
        ),
      );
    }
  }

  static int? _userIdFrom(Map<String, dynamic>? user) {
    final id = user?["id"] ?? user?["Id"];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? "");
  }

  static String _roleFrom(Map<String, dynamic>? user) {
    final role = user?["role"] ?? user?["Role"];
    return role?.toString().trim().toLowerCase() ?? "user";
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final String assetPath;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool loading;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.assetPath,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.7),
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
