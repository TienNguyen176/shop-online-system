import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/order_model.dart';
import '../providers/order_status_provider.dart';

class OrderStatusScreen extends StatefulWidget {
  final int userId;

  const OrderStatusScreen({super.key, required this.userId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  static const primary = Color(0xff2563eb);
  static const primaryDark = Color(0xff1d4ed8);
  static const bg = Color(0xffeef2fb);
  static const textDark = Color(0xff1f2937);
  static const textMuted = Color(0xff64748b);
  static const border = Color(0xffdbeafe);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderStatusProvider>().loadOrders(widget.userId);
    });
  }

  String formatPrice(num? price) {
    return (price ?? 0)
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderStatusProvider>(
      builder: (_, orderStatus, __) {
        return Scaffold(
          backgroundColor: bg,
          appBar: _appBar(context),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                _tabs(orderStatus),
                Expanded(child: _buildList(orderStatus)),
              ],
            ),
          ),
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
        "Đơn hàng",
        style: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _tabs(OrderStatusProvider orderStatus) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
      child: Row(
        children: List.generate(OrderStatusProvider.tabs.length, (index) {
          final selected = orderStatus.selectedIndex == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == OrderStatusProvider.tabs.length - 1 ? 0 : 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => orderStatus.changeTab(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? primary : border,
                      width: 1,
                    ),
                    boxShadow: [
                      if (selected)
                        BoxShadow(
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                          color: primaryDark.withOpacity(0.18),
                        ),
                    ],
                  ),
                  child: Text(
                    OrderStatusProvider.tabs[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildList(OrderStatusProvider orderStatus) {
    if (orderStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (orderStatus.error != null) {
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
                "Không tải được đơn hàng",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                orderStatus.error!,
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
                onPressed: () => orderStatus.loadOrders(widget.userId),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    if (orderStatus.orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: Color(0xff94a3b8),
            ),
            SizedBox(height: 12),
            Text(
              "Chưa có đơn hàng",
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Các đơn hàng của bạn sẽ xuất hiện tại đây.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: () => orderStatus.loadOrders(widget.userId),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        itemCount: orderStatus.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _orderItem(orderStatus.orders[index]),
      ),
    );
  }

  Widget _orderItem(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe5eefc)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: primaryDark.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.orderCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(order.status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            text: order.shippingName,
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.phone_outlined, text: order.shippingPhone),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: order.shippingAddress,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xffe5eefc)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                "Tổng tiền",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "${formatPrice(order.totalPrice)}đ",
                style: const TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
        return const Color(0xff16a34a);
      case "SHIPPING":
        return primary;
      case "PENDING":
      default:
        return const Color(0xffffb020);
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
        return "Đã giao";
      case "SHIPPING":
        return "Đang giao";
      case "PENDING":
        return "Chờ xác nhận";
      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _OrderStatusScreenState.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isEmpty ? "Chưa cập nhật" : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _OrderStatusScreenState.textDark,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
