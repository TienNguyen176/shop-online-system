import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../providers/cart_provider.dart';
import '../../../../models/cart_item.dart';
import '../../auth/providers/auth_provider.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  static const primary = Color(0xFFEE4D2D);
  static const bg = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<CartProvider>().loadCart(user['id']);
      }
    });
  }

  String formatPrice(num price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        return Scaffold(
          backgroundColor: bg,
          appBar: _appBar(),

          // 🔥 FIX SHOPEE LAYOUT
          body: Stack(children: [_buildList(cart), _bottomBar(cart)]),
        );
      },
    );
  }

  // ================= APP BAR =================
  AppBar _appBar() {
    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      title: const Text("Giỏ hàng"),
      centerTitle: true,
    );
  }

  // ================= LIST =================
  Widget _buildList(CartProvider cart) {
    if (cart.loading) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (cart.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text("Giỏ hàng trống"),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = cart.items[i];
        return _cartItem(cart, item);
      },
    );
  }

  // ================= ITEM (SWIPE DELETE + ANIMATION) =================
  Widget _cartItem(CartProvider cart, CartItem item) {
    final image =
        item.image.isNotEmpty ? "${AppConfig.apiUrl}/${item.image}" : null;

    final checked = cart.selectedIds.contains(item.id);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await _confirmDeleteDialog();
      },

      onDismissed: (_) {
        cart.deleteItem(item.id);
      },

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            Checkbox(
              value: checked,
              activeColor: primary,
              onChanged: (_) => cart.toggleSelect(item.id),
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  image != null
                      ? Image.network(
                        image,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        width: 75,
                        height: 75,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "₫${formatPrice(item.price)}",
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _qty(cart, item),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => cart.deleteItem(item.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= QTY =================
  Widget _qty(CartProvider cart, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => cart.updateQuantity(item.id, item.quantity - 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("${item.quantity}"),
          ),
          InkWell(
            onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM BAR (SHOPEE STYLE FIXED) =================
  Widget _bottomBar(CartProvider cart) {
    final selected = cart.selectedIds.length;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
            ],
          ),

          child: Row(
            children: [
              Checkbox(
                value:
                    cart.items.isNotEmpty &&
                    cart.selectedIds.length == cart.items.length,
                activeColor: primary,
                onChanged:
                    (v) => v == true ? cart.selectAll() : cart.clearSelection(),
              ),

              const Text("Tất cả"),

              const Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tổng tiền",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "₫${formatPrice(cart.totalPrice)}",
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: selected == 0 ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected == 0 ? Colors.grey : primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Mua ($selected)"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Xoá sản phẩm?"),
                content: const Text(
                  "Bạn có chắc muốn xoá sản phẩm này khỏi giỏ hàng không?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Huỷ"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Xoá"),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
