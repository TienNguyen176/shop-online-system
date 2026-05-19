import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../models/cart_item.dart';
import '../../../../models/checkout_request.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payment/screens/payment_screen.dart';
import '../../payment/utils/order_mapper.dart';
import '../providers/cart_provider.dart';

/// Màn hình giỏ hàng: hiển thị sản phẩm, chọn item, đổi số lượng và chuyển sang thanh toán.
class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  static const primary = Color(0xff2563eb);
  static const primaryDark = Color(0xff1d4ed8);
  static const bg = Color(0xffeef2fb);
  static const textDark = Color(0xff1f2937);
  static const textMuted = Color(0xff64748b);
  static const border = Color(0xffdbeafe);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadCart());
  }

  /// Định dạng tiền theo kiểu Việt Nam, dùng dấu chấm tách hàng nghìn.
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
          appBar: _appBar(context),
          body: Stack(children: [_buildList(cart), _bottomBar(cart)]),
        );
      },
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: textDark,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          tooltip: "Quay lại",
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: primaryDark.withOpacity(0.12),
            elevation: 2,
          ),
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      titleSpacing: 8,
      title: const Text(
        "Giỏ hàng",
        style: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }

  /// Xây dựng danh sách giỏ hàng theo trạng thái loading/rỗng/có dữ liệu.
  Widget _buildList(CartProvider cart) {
    if (cart.loading) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (cart.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 58,
                color: Color(0xff94a3b8),
              ),
              const SizedBox(height: 12),
              const Text(
                "Không tải được giỏ hàng",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                cart.error!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _reloadCart,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    if (cart.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: Color(0xff94a3b8),
            ),
            SizedBox(height: 12),
            Text(
              "Giỏ hàng trống",
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Sản phẩm bạn chọn sẽ xuất hiện tại đây.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 140),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _cartItem(cart, cart.items[i]),
    );
  }

  /// Hiển thị một sản phẩm trong giỏ hàng, hỗ trợ chọn và vuốt để xóa.
  Widget _cartItem(CartProvider cart, CartItem item) {
    final checked = cart.selectedIds.contains(item.id);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDeleteDialog(),
      onDismissed: (_) => cart.deleteItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xffef4444),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffe5eefc)),
          boxShadow: [
            BoxShadow(
              color: primaryDark.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              activeColor: primary,
              side: const BorderSide(color: Color(0xffcbd5e1), width: 1.4),
              onChanged: (_) => cart.toggleSelect(item.id),
            ),
            _CartImage(imageUrl: _imageUrl(item.image)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${formatPrice(item.price)}đ",
                    style: const TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _qty(cart, item),
                      IconButton(
                        tooltip: "Xóa",
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xffef4444),
                        ),
                        onPressed: () async {
                          final confirm = await _confirmDeleteDialog();
                          if (confirm) {
                            cart.deleteItem(item.id);
                          }
                        },
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

  /// Cụm nút tăng/giảm số lượng sản phẩm.
  Widget _qty(CartProvider cart, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap:
                item.quantity <= 1
                    ? null
                    : () => cart.updateQuantity(item.id, item.quantity - 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 16, color: textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "${item.quantity}",
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, size: 16, color: primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Thanh dưới cùng hiển thị tổng tiền và nút mua hàng.
  Widget _bottomBar(CartProvider cart) {
    final selected = cart.selectedIds.length;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, -6),
                color: primaryDark.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value:
                    cart.items.isNotEmpty &&
                    cart.selectedIds.length == cart.items.length,
                activeColor: primary,
                side: const BorderSide(color: Color(0xffcbd5e1), width: 1.4),
                onChanged:
                    (v) => v == true ? cart.selectAll() : cart.clearSelection(),
              ),
              const Text(
                "Tất cả",
                style: TextStyle(color: textDark, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tổng tiền",
                    style: TextStyle(
                      fontSize: 12,
                      color: textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${formatPrice(cart.totalPrice)}đ",
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: selected == 0 ? null : _openPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selected == 0 ? const Color(0xffcbd5e1) : primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xffcbd5e1),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Mua ($selected)",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tạo CheckoutRequest từ các item đã chọn và mở màn thanh toán.
  void _openPayment() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final cart = context.read<CartProvider>();
    final selectedItems =
        cart.items.where((e) => cart.selectedIds.contains(e.id)).toList();

    final total = selectedItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    final request = CheckoutRequest(
      userId: user['id'] is int ? user['id'] : int.parse(user['id'].toString()),
      amount: total,
      name: user['name'] ?? "User",
      orderType: "billpayment",
      orderDescription: "Thanh toán đơn hàng",
      items: selectedItems.map((e) => mapCartItem(e)).toList(),
      shippingName: user['name'] ?? "",
      shippingPhone: "",
      shippingAddress: "",
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(request: request)),
    );
  }

  /// Hỏi xác nhận trước khi xóa sản phẩm khỏi giỏ hàng.
  Future<bool> _confirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    "Xóa sản phẩm?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng không?",
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Hủy"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffef4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Xóa"),
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  String? _imageUrl(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }

    final cleanApi = AppConfig.apiUrl.replaceAll(RegExp(r"/+$"), "");
    final cleanPath = trimmed.replaceAll(RegExp(r"^/+"), "");
    return "$cleanApi/$cleanPath";
  }

  /// Tải lại giỏ hàng của user hiện tại.
  void _reloadCart() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final id = user['id'];
    final userId = id is int ? id : int.tryParse(id.toString());
    if (userId != null) {
      context.read<CartProvider>().loadCart(userId, force: true);
    }
  }
}

class _CartImage extends StatelessWidget {
  final String? imageUrl;

  const _CartImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          imageUrl == null
              ? _fallback()
              : CachedNetworkImage(
                imageUrl: imageUrl!,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                placeholder: (_, __) => _loading(),
                errorWidget: (_, __, ___) => _fallback(),
              ),
    );
  }

  Widget _loading() {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xffe0ecff),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _ShoppingCartScreenState.primary,
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xffe0ecff),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xff94a3b8),
        size: 30,
      ),
    );
  }
}
