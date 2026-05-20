import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../models/order_detail.dart';
import '../../../../models/order_item.dart';
import '../../../../services/order_service.dart';
import '../../profile/models/user_address.dart';
import '../../profile/services/address_service.dart';

/// Màn chi tiết đơn hàng đang chờ xác nhận, cho phép đổi địa chỉ và hủy đơn.
class PendingOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const PendingOrderDetailScreen({super.key, required this.orderId});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<PendingOrderDetailScreen> createState() =>
      _PendingOrderDetailScreenState();
}

class _PendingOrderDetailScreenState extends State<PendingOrderDetailScreen> {
  static const shopee = Color(0xff2563eb);
  static const bg = Color(0xffeef2fb);
  static const textDark = Color(0xff1f2937);
  static const textMuted = Color(0xff6b7280);
  static const border = Color(0xffdbeafe);

  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();

  OrderDetail? _order;
  List<UserAddress> _addresses = [];
  bool _loading = true;
  bool _updatingAddress = false;
  bool _cancelling = false;
  bool _requestingReturn = false;
  bool _changed = false;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Tải song song chi tiết đơn hàng và danh sách địa chỉ của người dùng.
  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final results = await Future.wait([
        _orderService.getOrderDetail(widget.orderId),
        _addressService.getAddresses(),
      ]);
      if (!mounted) return;
      setState(() {
        _order = results[0] as OrderDetail;
        _addresses = results[1] as List<UserAddress>;
      });
    } catch (e) {
      _showMessage("Không thể tải chi tiết đơn hàng");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final order = _order;
    final canEditOrder = order?.status.toUpperCase() == "PENDING";
    final canRequestReturn = _canRequestReturn(order);
    final hasBottomAction = canEditOrder || canRequestReturn;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: textDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context, _changed),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text(
            "Chi tiết đơn hàng",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body:
            _loading
                ? const Center(child: CircularProgressIndicator(color: shopee))
                : order == null
                ? _emptyState()
                : Stack(
                  children: [
                    RefreshIndicator(
                      color: shopee,
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          12,
                          10,
                          12,
                          hasBottomAction ? 104 : 24,
                        ),
                        children: [
                          _AddressCard(
                            order: order,
                            loading: _updatingAddress,
                            canEdit: canEditOrder,
                            onTap: _openAddressPicker,
                          ),
                          const SizedBox(height: 10),
                          _OrderTimelineCard(order: order),
                          const SizedBox(height: 10),
                          if (order.returnRequest != null) ...[
                            _ReturnRequestCard(order: order),
                            const SizedBox(height: 10),
                          ],
                          _ProductSection(items: order.items),
                          const SizedBox(height: 10),
                          _SummaryCard(order: order),
                        ],
                      ),
                    ),
                    if (canEditOrder)
                      _BottomCancelBar(
                        loading: _cancelling,
                        onCancel: _cancelOrderSafe,
                      ),
                    if (canRequestReturn)
                      _BottomReturnBar(
                        loading: _requestingReturn,
                        onReturn: _createReturnRequest,
                      ),
                  ],
                ),
      ),
    );
  }

  /// Hiển thị trạng thái rỗng khi không tìm thấy đơn hàng.
  bool _canRequestReturn(OrderDetail? order) {
    if (order == null) return false;
    if (order.status.toUpperCase() != "DELIVERED") return false;
    if (order.returnRequest != null) return false;

    final deliveredAt = order.deliveredAt;
    if (deliveredAt == null) return false;

    return !DateTime.now().isAfter(deliveredAt.add(const Duration(days: 7)));
  }

  /// Xu ly logic cho ham _emptyState.
  Widget _emptyState() {
    return const Center(
      child: Text(
        "Không tìm thấy đơn hàng",
        style: TextStyle(color: textMuted, fontWeight: FontWeight.w700),
      ),
    );
  }

  /// Mở danh sách địa chỉ để chọn địa chỉ giao hàng mới cho đơn.
  Future<void> _openAddressPicker() async {
    if (_updatingAddress || _addresses.isEmpty) {
      if (_addresses.isEmpty) _showMessage("Bạn chưa có địa chỉ đã lưu");
      return;
    }

    final selected = await showModalBottomSheet<UserAddress>(
      context: context,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => _AddressPickerSheet(addresses: _addresses),
    );

    if (selected == null) return;

    try {
      setState(() => _updatingAddress = true);
      final updated = await _orderService.updateShippingAddress(
        orderId: widget.orderId,
        address: selected,
      );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _changed = true;
      });
      _showMessage("Đã đổi địa chỉ giao hàng");
    } catch (e) {
      _showMessage("Không thể đổi địa chỉ giao hàng");
    } finally {
      if (mounted) setState(() => _updatingAddress = false);
    }
  }

  // ignore: unused_element
  /// Xu ly logic cho ham _cancelOrder.
  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hủy đơn hàng"),
            content: const Text("Đơn hàng sẽ bị xóa khỏi hệ thống."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Đóng"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: shopee),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hủy đơn"),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _cancelling = true);
      await _orderService.deleteOrder(widget.orderId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Cancel order error: $e");
      _showMessage(e.toString().replaceFirst("Exception: ", ""));
      _showMessage("Không thể hủy đơn hàng");
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  /// Xác nhận và gọi API hủy đơn bằng cách đổi trạng thái sang CANCEL.
  Future<void> _cancelOrderSafe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Huy don hang"),
            content: const Text("Don hang se bi xoa khoi he thong."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Dong"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: shopee),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Huy don"),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _cancelling = true);
      await _orderService.deleteOrder(widget.orderId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Cancel order error: $e");
      _showMessage(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  /// Hiển thị thông báo ngắn ở cuối màn hình.
  Future<void> _createReturnRequest() async {
    var reasonText = "";

    final reason = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Trả hàng / hoàn tiền"),
            content: TextField(
              onChanged: (value) => reasonText = value,
              autofocus: true,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Nhập lý do trả hàng",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đóng"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: shopee),
                onPressed: () => Navigator.pop(context, reasonText.trim()),
                child: const Text("Gửi yêu cầu"),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (reason == null) return;
    if (reason.isEmpty) {
      _showMessage("Vui lòng nhập lý do trả hàng");
      return;
    }

    try {
      setState(() => _requestingReturn = true);
      await _orderService.createReturnRequest(
        orderId: widget.orderId,
        reason: reason,
      );
      await _load();
      if (!mounted) return;
      setState(() => _changed = true);
      _showMessage("Đã gửi yêu cầu trả hàng/hoàn tiền");
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _requestingReturn = false);
    }
  }

  /// Hien thi thong bao nhanh cho nguoi dung.
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }
}

/// Card địa chỉ giao hàng trong chi tiết đơn.
class _AddressCard extends StatelessWidget {
  final OrderDetail order;
  final bool loading;
  final bool canEdit;
  final VoidCallback onTap;

  const _AddressCard({
    required this.order,
    required this.loading,
    required this.canEdit,
    required this.onTap,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: loading || !canEdit ? null : onTap,
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffbfdbfe),
                    Color(0xffbfdbfe),
                    Color(0xff2563eb),
                    Color(0xff2563eb),
                  ],
                  stops: [0, 0.45, 0.45, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: _PendingOrderDetailScreenState.shopee,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Địa chỉ nhận hàng",
                          style: TextStyle(
                            color: _PendingOrderDetailScreenState.shopee,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${order.shippingName}  ${order.shippingPhone}",
                          style: const TextStyle(
                            color: _PendingOrderDetailScreenState.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.shippingAddress,
                          style: const TextStyle(
                            color: _PendingOrderDetailScreenState.textDark,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _PendingOrderDetailScreenState.shopee,
                        ),
                      )
                      : canEdit
                          ? const Icon(Icons.chevron_right, color: Colors.grey)
                          : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTimelineCard extends StatelessWidget {
  final OrderDetail order;

  const _OrderTimelineCard({required this.order});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final status = order.status.toUpperCase();
    final cancelled = status == "CANCEL" || status == "FAILED";

    final steps =
        cancelled
            ? [
              _TimelineStep(
                title: "Đã đặt hàng",
                subtitle: "Đơn hàng đã được tạo",
                time: order.createdAt,
                active: order.createdAt != null,
                icon: Icons.receipt_long_outlined,
              ),
              _TimelineStep(
                title: "Đã hủy",
                subtitle: "Đơn hàng đã bị hủy",
                time: order.updatedAt,
                active: true,
                icon: Icons.cancel_outlined,
              ),
            ]
            : [
              _TimelineStep(
                title: "Đã đặt hàng",
                subtitle: "Đơn hàng đã được tạo",
                time: order.createdAt,
                active: order.createdAt != null,
                icon: Icons.receipt_long_outlined,
              ),
              _TimelineStep(
                title: "Đã thanh toán",
                subtitle: "Shop đang chuẩn bị giao hàng",
                time: order.updatedAt,
                active: status == "PAID" || status == "DELIVERED",
                icon: Icons.payments_outlined,
              ),
              _TimelineStep(
                title: "Đã giao hàng",
                subtitle: "Đơn hàng đã giao thành công",
                time: order.deliveredAt,
                active: status == "DELIVERED",
                icon: Icons.local_shipping_outlined,
              ),
            ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                color: _PendingOrderDetailScreenState.shopee,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Mốc thời gian đơn hàng",
                  style: TextStyle(
                    color: _PendingOrderDetailScreenState.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _TimelineStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            steps.length,
            (index) => _TimelineRow(
              step: steps[index],
              isLast: index == steps.length - 1,
            ),
          ),
        ],
      ),
    );
  }

}

class _TimelineStep {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool active;
  final IconData icon;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.active,
    required this.icon,
  });
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final color =
        step.active
            ? _PendingOrderDetailScreenState.shopee
            : const Color(0xffcbd5e1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        step.active
                            ? color.withOpacity(0.12)
                            : const Color(0xfff1f5f9),
                    shape: BoxShape.circle,
                    border: Border.all(color: color),
                  ),
                  child: Icon(step.icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color:
                          step.active
                              ? color.withOpacity(0.35)
                              : const Color(0xffe2e8f0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 8 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color:
                          step.active
                              ? _PendingOrderDetailScreenState.textDark
                              : _PendingOrderDetailScreenState.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.subtitle,
                    style: const TextStyle(
                      color: _PendingOrderDetailScreenState.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(step.time),
            style: TextStyle(
              color:
                  step.time == null
                      ? _PendingOrderDetailScreenState.textMuted
                      : _PendingOrderDetailScreenState.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStatusBadge extends StatelessWidget {
  final String status;

  const _TimelineStatusBadge({required this.status});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      "DELIVERED" => const Color(0xff16a34a),
      "PAID" => _PendingOrderDetailScreenState.shopee,
      "CANCEL" || "FAILED" => const Color(0xffef4444),
      _ => const Color(0xffffb020),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReturnRequestCard extends StatelessWidget {
  final OrderDetail order;

  const _ReturnRequestCard({required this.order});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final request = order.returnRequest!;
    final status = request.status.toUpperCase();
    final color = switch (status) {
      "APPROVED" => const Color(0xff16a34a),
      "REJECTED" => const Color(0xffef4444),
      _ => _PendingOrderDetailScreenState.shopee,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.assignment_return_outlined, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Yêu cầu trả hàng/hoàn tiền",
                        style: TextStyle(
                          color: _PendingOrderDetailScreenState.textDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      _returnStatusLabel(status),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  request.reason.isEmpty ? "Không có lý do" : request.reason,
                  style: const TextStyle(
                    color: _PendingOrderDetailScreenState.textMuted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Gửi lúc ${_formatDate(request.createdAt)}",
                  style: const TextStyle(
                    color: _PendingOrderDetailScreenState.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section danh sách sản phẩm thuộc đơn hàng.
class _ProductSection extends StatelessWidget {
  final List<OrderItem> items;

  const _ProductSection({required this.items});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const ListTile(
            dense: true,
            leading: Icon(Icons.storefront_outlined, color: Colors.black87),
            title: Text(
              "Next4Shop",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(
            height: 1,
            color: _PendingOrderDetailScreenState.border,
          ),
          ...items.map((item) => _ProductTile(item: item)),
        ],
      ),
    );
  }
}

/// Một dòng sản phẩm trong đơn hàng.
class _ProductTile extends StatelessWidget {
  final OrderItem item;

  const _ProductTile({required this.item});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _PendingOrderDetailScreenState.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _ProductImage(imageUrl: _imageUrl(item.image)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _PendingOrderDetailScreenState.textDark,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (item.variantName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.variantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _PendingOrderDetailScreenState.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${_formatPrice(item.price)}đ",
                      style: const TextStyle(
                        color: _PendingOrderDetailScreenState.shopee,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "x${item.quantity}",
                      style: const TextStyle(
                        color: _PendingOrderDetailScreenState.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chuẩn hóa đường dẫn ảnh sản phẩm thành URL đầy đủ.
  String _imageUrl(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return "";
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }

    final cleanApi = AppConfig.apiUrl.replaceAll(RegExp(r"/+$"), "");
    final cleanPath = trimmed.replaceAll(RegExp(r"^/+"), "");
    return "$cleanApi/$cleanPath";
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _fallback();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => _loading(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  /// Hien thi trang thai dang tai du lieu.
  Widget _loading() {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _PendingOrderDetailScreenState.shopee,
        ),
      ),
    );
  }

  /// Hien thi giao dien thay the khi khong tai duoc du lieu.
  Widget _fallback() {
    return const Center(child: Icon(Icons.image_outlined, color: Colors.grey));
  }
}

/// Card tổng kết tiền hàng, phí ship và tổng thanh toán.
class _SummaryCard extends StatelessWidget {
  final OrderDetail order;

  const _SummaryCard({required this.order});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final quantity = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: "Tổng tiền hàng ($quantity sản phẩm)",
            value: "${_formatPrice(order.subtotalPrice)}đ",
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: "Phí vận chuyển",
            value: "${_formatPrice(order.shippingFee)}đ",
          ),
          const Divider(
            height: 24,
            color: _PendingOrderDetailScreenState.border,
          ),
          _SummaryRow(
            label: "Tổng thanh toán",
            value: "${_formatPrice(order.totalPrice)}đ",
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color:
                  strong
                      ? _PendingOrderDetailScreenState.textDark
                      : _PendingOrderDetailScreenState.textMuted,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                strong
                    ? _PendingOrderDetailScreenState.shopee
                    : _PendingOrderDetailScreenState.textDark,
            fontSize: strong ? 18 : 14,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Thanh dưới cùng chứa nút hủy đơn.
class _BottomCancelBar extends StatelessWidget {
  final bool loading;
  final VoidCallback onCancel;

  const _BottomCancelBar({required this.loading, required this.onCancel});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: loading ? null : onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: _PendingOrderDetailScreenState.shopee,
                disabledBackgroundColor: const Color(0xffd1d5db),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon:
                  loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.cancel_outlined),
              label: const Text(
                "Hủy đơn",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet cho phép chọn địa chỉ đã lưu để cập nhật đơn hàng.
class _BottomReturnBar extends StatelessWidget {
  final bool loading;
  final VoidCallback onReturn;

  const _BottomReturnBar({required this.loading, required this.onReturn});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: loading ? null : onReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: _PendingOrderDetailScreenState.shopee,
                disabledBackgroundColor: const Color(0xffd1d5db),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon:
                  loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.assignment_return_outlined),
              label: const Text(
                "Trả hàng / Hoàn tiền",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  final List<UserAddress> addresses;

  const _AddressPickerSheet({required this.addresses});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Chọn địa chỉ giao hàng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: addresses.length,
              separatorBuilder:
                  (_, __) => const Divider(
                    height: 1,
                    color: _PendingOrderDetailScreenState.border,
                  ),
              itemBuilder: (_, index) {
                final address = addresses[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: _PendingOrderDetailScreenState.shopee,
                  ),
                  title: Text(
                    "${address.receiverName}  ${address.phone}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(address.fullAddress),
                  trailing:
                      address.isDefault
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _PendingOrderDetailScreenState.shopee,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Mặc định",
                              style: TextStyle(
                                color: _PendingOrderDetailScreenState.shopee,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                          : null,
                  onTap: () => Navigator.pop(context, address),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dinh dang gia tien de hien thi tren giao dien.
String _formatPrice(num price) {
  return price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
}

/// Dinh dang ngay gio de hien thi tren giao dien.
String _formatDate(DateTime? date) {
  if (date == null) return "--";
  String two(int value) => value.toString().padLeft(2, "0");
  return "${two(date.day)}/${two(date.month)}/${date.year} "
      "${two(date.hour)}:${two(date.minute)}";
}

/// Chuyen ma trang thai thanh nhan hien thi cho nguoi dung.
String _statusLabel(String status) {
  return switch (status.toUpperCase()) {
    "PENDING" => "Chờ xác nhận",
    "PAID" => "Chờ giao hàng",
    "DELIVERED" => "Đã giao",
    "CANCEL" => "Đã hủy",
    "FAILED" => "Thất bại",
    _ => status,
  };
}

/// Chuyen ma trang thai thanh nhan hien thi cho nguoi dung.
String _returnStatusLabel(String status) {
  return switch (status.toUpperCase()) {
    "APPROVED" => "Đã duyệt",
    "REJECTED" => "Từ chối",
    "PENDING" => "Chờ duyệt",
    _ => status,
  };
}
