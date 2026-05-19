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
  static const primary = Color(0xFFEE4D2D);
  static const bg = Color(0xFFF5F5F5);

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
          appBar: _appBar(),
          body: Column(
            children: [
              _tabs(orderStatus),
              Expanded(child: _buildList(orderStatus)),
            ],
          ),
        );
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      title: const Text("Tình trạng đơn hàng"),
    );
  }

  Widget _tabs(OrderStatusProvider orderStatus) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? primary : bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    OrderStatusProvider.tabs[index],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
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

    if (orderStatus.orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text("Không có đơn hàng"),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: () => orderStatus.loadOrders(widget.userId),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: orderStatus.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _orderItem(orderStatus.orders[index]),
      ),
    );
  }

  Widget _orderItem(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.orderCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                order.status,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Người nhận: ${order.shippingName}"),
          const SizedBox(height: 4),
          Text("SĐT: ${order.shippingPhone}"),
          const SizedBox(height: 4),
          Text("Địa chỉ: ${order.shippingAddress}"),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "₫${formatPrice(order.totalPrice)}",
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
