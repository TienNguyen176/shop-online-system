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
      _showSnack(context, "Sáº£n pháº©m chÆ°a cÃ³ biáº¿n thá»ƒ");
      return;
    }

    if (variant.stockQuantity <= 0) {
      _showSnack(context, "San pham da het hang");
      return;
    }

    /// ===== ADD TO CART =====
    await cart.addToCart(
      productId: productId,
      variantId: variant.id,
      quantity: 1,
    );

    if (!context.mounted) return;

    _showSnack(context, "ÄÃ£ thÃªm vÃ o giá» hÃ ng");
  }

  /// ================= COMMON =================

  static void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
                    const Text("Vui lÃ²ng Ä‘Äƒng nháº­p Ä‘á»ƒ tiáº¿p tá»¥c"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Huá»·"),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              "ÄÄƒng nháº­p",
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
