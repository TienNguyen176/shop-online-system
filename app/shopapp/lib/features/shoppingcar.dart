import 'package:flutter/material.dart';
import 'package:shopapp/repositories/cart_repository.dart';
import 'package:shopapp/config/app_config.dart';

class Shoppingcar extends StatefulWidget {
  const Shoppingcar({super.key});

  @override
  State<Shoppingcar> createState() => _ShoppingcarState();
}

class _ShoppingcarState extends State<Shoppingcar> {
  final CartRepository repo = CartRepository();

  List<Map<String, dynamic>> cartItems = [];
  Set<int> selectedIds = {};
  bool loading = true;

  // ── Màu chủ đạo ──────────────────────────────────────────
  static const Color _primary   = Color(0xFFEE4D2D); // Shopee orange-red
  static const Color _bg        = Color(0xFFF5F5F5);
  static const Color _cardBg    = Colors.white;
  static const Color _textMain  = Color(0xFF212121);
  static const Color _textGrey  = Color(0xFF9E9E9E);
  static const Color _divider   = Color(0xFFEEEEEE);

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final data = await repo.getCart(1);
      setState(() {
        cartItems = data;
        selectedIds = data.map((e) => _getInt(e["id"])).toSet();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  double get totalPrice {
    double total = 0;
    for (var item in cartItems) {
      if (!selectedIds.contains(_getInt(item["id"]))) continue;
      total += _getDouble(item["price"]) * _getInt(item["quantity"]);
    }
    return total;
  }

  bool get isAllSelected =>
      cartItems.isNotEmpty &&
      cartItems.every((e) => selectedIds.contains(_getInt(e["id"])));

  Future<void> updateQty(int index, int newQty) async {
    if (newQty <= 0) { await deleteItem(index); return; }
    try {
      await repo.updateQuantity(_getInt(cartItems[index]["id"]), newQty);
      setState(() => cartItems[index]["quantity"] = newQty);
    } catch (e) {
      _showSnack("Lỗi cập nhật");
    }
  }

  Future<void> deleteItem(int index) async {
    final id = _getInt(cartItems[index]["id"]);
    try {
      await repo.deleteItem(id);
      setState(() {
        selectedIds.remove(id);
        cartItems.removeAt(index);
      });
    } catch (e) {
      _showSnack("Lỗi xoá");
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  double _getDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _getInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _formatPrice(double price) {
    // 500000 → "500.000"
    final s = price.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,

      // ── AppBar ─────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: _primary,
            boxShadow: [
              BoxShadow(color: Color(0x29000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Giỏ Hàng",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _buildCartItem(index),
            ),

      // ── Bottom bar ──────────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Empty state ────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Giỏ hàng trống",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text("Hãy thêm sản phẩm vào giỏ nhé!",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("Mua sắm ngay",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Cart item card ─────────────────────────────────────────
  Widget _buildCartItem(int index) {
    final item      = cartItems[index];
    final int id    = _getInt(item["id"]);
    final double price = _getDouble(item["price"]);
    final int qty   = _getInt(item["quantity"]);
    final bool checked = selectedIds.contains(id);
    final String imageUrl = item["image"].toString().isNotEmpty
        ? "${AppConfig.apiUrl}/${item["image"]}"
        : "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Shop header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.storefront, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 6),
                const Text(
                  "SHOP",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _textMain),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, size: 16, color: _textGrey),
              ],
            ),
          ),

          Divider(height: 1, color: _divider),

          // ── Item row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: checked,
                    activeColor: _primary,
                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) => setState(() {
                      v == true ? selectedIds.add(id) : selectedIds.remove(id);
                    }),
                  ),
                ),

                // Ảnh sản phẩm
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey.shade100,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade300,
                                size: 32),
                          )
                        : Icon(Icons.image_outlined,
                            color: Colors.grey.shade300, size: 32),
                  ),
                ),

                const SizedBox(width: 10),

                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5,
                            color: _textMain,
                            height: 1.4),
                      ),
                      const SizedBox(height: 6),

                      // Badge phân loại
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Phân loại",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_down,
                                size: 14, color: Colors.grey.shade500),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Giá + qty controls
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Giá
                          Text(
                            "₫${_formatPrice(price)}",
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),

                          const Spacer(),

                          // Nút xoá
                          GestureDetector(
                            onTap: () => _confirmDelete(index),
                            child: Icon(Icons.delete_outline,
                                size: 20, color: Colors.grey.shade400),
                          ),

                          const SizedBox(width: 8),

                          // − qty +
                          _buildQtyControl(qty, index),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Qty control ────────────────────────────────────────────
  Widget _buildQtyControl(int qty, int index) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            icon: Icons.remove,
            color: qty <= 1 ? Colors.grey.shade300 : _textMain,
            onTap: () => updateQty(index, qty - 1),
          ),
          Container(
            width: 1,
            height: 28,
            color: Colors.grey.shade300,
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                "$qty",
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(width: 1, height: 28, color: Colors.grey.shade300),
          _qtyBtn(icon: Icons.add, color: _textMain,
              onTap: () => updateQty(index, qty + 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = _textMain,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  // ── Confirm delete dialog ──────────────────────────────────
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Xoá sản phẩm",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text("Bạn có chắc muốn xoá sản phẩm này?",
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Huỷ",
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteItem(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Xoá",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    final int selectedCount = selectedIds.length;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [

              // Checkbox tất cả
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isAllSelected,
                  activeColor: _primary,
                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (v) => setState(() {
                    if (v == true)
                      selectedIds =
                          cartItems.map((e) => _getInt(e["id"])).toSet();
                    else
                      selectedIds.clear();
                  }),
                ),
              ),

              const Text("Tất cả",
                  style: TextStyle(fontSize: 13, color: _textMain)),

              const Spacer(),

              // Tổng tiền
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Tổng tiền:",
                      style: TextStyle(fontSize: 11, color: _textGrey)),
                  Text(
                    "₫${_formatPrice(totalPrice)}",
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // Nút mua hàng
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: selectedCount == 0 ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedCount == 0 ? Colors.grey.shade300 : _primary,
                    elevation: selectedCount == 0 ? 0 : 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    selectedCount == 0
                        ? "Mua hàng"
                        : "Mua ($selectedCount)",
                    style: TextStyle(
                      color: selectedCount == 0
                          ? Colors.grey.shade500
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}