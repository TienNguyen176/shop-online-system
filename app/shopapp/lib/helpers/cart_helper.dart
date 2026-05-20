import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/user/auth/providers/auth_provider.dart';
import '../features/user/cart/providers/cart_provider.dart';

import '../features/user/auth/screens/login_screen.dart';

import '../models/product_variant.dart';

class CartHelper {
  /// ================= ADD TO CART =================
  static Future<void> addToCart({
    required BuildContext context,
    required int productId,
    ProductVariant? selectedVariant,
    Future<ProductVariant?> Function()? fetchVariant,
  }) async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    /// ===== CHECK LOGIN =====
    if (user == null) {
      final ok = await _showLoginDialog(context);

      if (!context.mounted) return;

      if (!ok) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

      return;
    }

    final cart = context.read<CartProvider>();

    ProductVariant? variant = selectedVariant;

    /// ===== FETCH VARIANT =====
    if (variant == null && fetchVariant != null) {
      variant = await fetchVariant();

      if (!context.mounted) return;
    }

    if (variant == null) {
      _showSnack(context, "Sản phẩm chưa có biến thể");
      return;
    }

    if (variant.stockQuantity <= 0) {
      _showSnack(context, "Sản phẩm đã hết hàng");
      return;
    }

    /// ===== ADD TO CART =====
    try {
      await cart.addToCart(
        productId: productId,
        variantId: variant.id,
        quantity: 1,
      );
    } catch (e) {
      if (!context.mounted) return;

      final message = e.toString();
      final sessionExpired =
          message.contains("Phi") ||
          message.contains("401") ||
          message.toLowerCase().contains("unauthorized");

      if (sessionExpired) {
        await auth.logout();
        if (!context.mounted) return;
        context.read<CartProvider>().clearCart();
        _showSnack(context, "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      _showSnack(context, "Không thể thêm vào giỏ hàng. Vui lòng thử lại.");
      return;
    }

    if (!context.mounted) return;

    _showSnack(context, "Đã thêm vào giỏ hàng");
  }

  /// ================= COMMON =================

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Xu ly logic cho ham _showLoginDialog.
  static Future<bool> _showLoginDialog(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Vui lòng đăng nhập để tiếp tục"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Hủy"),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    return result == true;
  }
}
