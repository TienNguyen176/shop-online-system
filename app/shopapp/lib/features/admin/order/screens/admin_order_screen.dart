import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_order_model.dart';
import '../models/admin_return_request_model.dart';
import '../providers/admin_order_provider.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  static const primary = Color(0xff2563eb);
  static const bg = Color(0xffeef2fb);
  static const textDark = Color(0xff1f2937);
  static const textMuted = Color(0xff64748b);
  static const border = Color(0xffdbeafe);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrderProvider>(
      builder: (context, provider, _) {
        return Container(
          color: bg,
          child: Column(
            children: [
              _StatusTabs(provider: provider),
              Expanded(child: _body(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(AdminOrderProvider provider) {
    final isReturnTab = provider.selectedStatus.startsWith("RETURN_");
    final isPendingReturnTab = provider.selectedStatus == "RETURN_PENDING";
    final isEmpty =
        isReturnTab ? provider.returnRequests.isEmpty : provider.orders.isEmpty;

    if (provider.loading && isEmpty) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textDark),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => provider.loadOrders(),
                icon: const Icon(Icons.refresh),
                label: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return const Center(
        child: Text(
          "Chưa có đơn hàng",
          style: TextStyle(color: textMuted, fontWeight: FontWeight.w700),
        ),
      );
    }

    if (isReturnTab) {
      return RefreshIndicator(
        color: primary,
        onRefresh: () => provider.loadOrders(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: provider.returnRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final request = provider.returnRequests[index];
            return _ReturnRequestCard(
              request: request,
              loading: provider.loading,
              showActions: isPendingReturnTab,
              onApprove:
                  () => _confirmReviewReturn(provider, request, "APPROVED"),
              onReject:
                  () => _confirmReviewReturn(provider, request, "REJECTED"),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: () => provider.loadOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: provider.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final order = provider.orders[index];
          return _OrderCard(
            order: order,
            loading: provider.loading,
            onApprove: () => _confirmApprove(provider, order),
          );
        },
      ),
    );
  }

  Future<void> _confirmApprove(
    AdminOrderProvider provider,
    AdminOrderModel order,
  ) async {
    final nextStatus = order.status.toUpperCase() == "PENDING"
        ? "PAID"
        : order.status.toUpperCase() == "PAID"
            ? "DELIVERED"
            : "";

    if (nextStatus.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Duyệt đơn hàng"),
        content: Text("Chuyển đơn ${order.orderCode} sang $nextStatus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Duyệt"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.approve(order);
    }
  }

  Future<void> _confirmReviewReturn(
    AdminOrderProvider provider,
    AdminReturnRequestModel request,
    String status,
  ) async {
    final approved = status == "APPROVED";
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(approved ? "Duyệt hoàn tiền" : "Từ chối hoàn tiền"),
            content: Text(
              "${approved ? "Duyệt" : "Từ chối"} yêu cầu của đơn ${request.orderCode}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Đóng"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(approved ? "Duyệt" : "Từ chối"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await provider.reviewReturnRequest(request: request, status: status);
    }
  }
}

class _StatusTabs extends StatelessWidget {
  final AdminOrderProvider provider;

  const _StatusTabs({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: provider.statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = provider.statuses[index];
          final selected = status == provider.selectedStatus;

          return ChoiceChip(
            selected: selected,
            label: Text(_statusLabel(status)),
            onSelected: (_) => provider.loadOrders(status: status),
            selectedColor: _AdminOrderScreenState.primary,
            labelStyle: TextStyle(
              color: selected ? Colors.white : _AdminOrderScreenState.textDark,
              fontWeight: FontWeight.w800,
            ),
            side: const BorderSide(color: _AdminOrderScreenState.border),
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      "ALL" => "Tất cả",
      "PENDING" => "Chờ duyệt",
      "PAID" => "Đã duyệt",
      "DELIVERED" => "Đã giao",
      "RETURN_PENDING" => "Hoàn tiền chờ duyệt",
      "RETURN_APPROVED" => "Hoàn tiền đã duyệt",
      "RETURN_REJECTED" => "Hoàn tiền từ chối",
      _ => status,
    };
  }
}

class _OrderCard extends StatelessWidget {
  final AdminOrderModel order;
  final bool loading;
  final VoidCallback onApprove;

  const _OrderCard({
    required this.order,
    required this.loading,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.status.toUpperCase();
    final canApprove = status == "PENDING" || status == "PAID";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe5eefc)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 7),
            color: Colors.blue.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderCode,
                  style: const TextStyle(
                    color: _AdminOrderScreenState.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(icon: Icons.person_outline, text: order.shippingName),
          const SizedBox(height: 6),
          _InfoLine(icon: Icons.phone_outlined, text: order.shippingPhone),
          const SizedBox(height: 6),
          _InfoLine(
            icon: Icons.location_on_outlined,
            text: order.shippingAddress,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xffe5eefc)),
          const SizedBox(height: 10),
          _TimeLine(order: order),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "${_formatPrice(order.totalPrice)}đ",
                style: const TextStyle(
                  color: _AdminOrderScreenState.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (canApprove)
                FilledButton.icon(
                  onPressed: loading ? null : onApprove,
                  icon: Icon(
                    status == "PENDING"
                        ? Icons.payments_outlined
                        : Icons.local_shipping_outlined,
                    size: 18,
                  ),
                  label: Text(
                    status == "PENDING"
                        ? "Duyệt thanh toán"
                        : "Xác nhận đã giao",
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnRequestCard extends StatelessWidget {
  final AdminReturnRequestModel request;
  final bool loading;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ReturnRequestCard({
    required this.request,
    required this.loading,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe5eefc)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 7),
            color: Colors.blue.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.orderCode,
                  style: const TextStyle(
                    color: _AdminOrderScreenState.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _ReturnStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 10),
          _InfoLine(icon: Icons.person_outline, text: request.shippingName),
          const SizedBox(height: 6),
          _InfoLine(icon: Icons.phone_outlined, text: request.shippingPhone),
          const SizedBox(height: 6),
          _InfoLine(
            icon: Icons.location_on_outlined,
            text: request.shippingAddress,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xffe5eefc)),
          const SizedBox(height: 10),
          _InfoLine(
            icon: Icons.assignment_return_outlined,
            text: request.reason.isEmpty ? "Không có lý do" : request.reason,
          ),
          const SizedBox(height: 6),
          _TimeLineRow(label: "Đã giao", time: request.deliveredAt),
          _TimeLineRow(label: "Gửi yêu cầu", time: request.createdAt),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "${_formatPrice(request.totalPrice)}đ",
                style: const TextStyle(
                  color: _AdminOrderScreenState.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (showActions)
                OutlinedButton.icon(
                  onPressed: loading ? null : onReject,
                  icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text("Từ chối"),
              ),
              if (showActions) const SizedBox(width: 8),
              if (showActions)
                FilledButton.icon(
                  onPressed: loading ? null : onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text("Duyệt"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnStatusBadge extends StatelessWidget {
  final String status;

  const _ReturnStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      "APPROVED" => const Color(0xff16a34a),
      "REJECTED" => const Color(0xffef4444),
      _ => _AdminOrderScreenState.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        switch (normalized) {
          "APPROVED" => "Đã duyệt",
          "REJECTED" => "Từ chối",
          _ => "Chờ duyệt",
        },
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      "DELIVERED" => const Color(0xff16a34a),
      "PAID" => _AdminOrderScreenState.primary,
      "CANCEL" || "FAILED" => const Color(0xffef4444),
      _ => const Color(0xffffb020),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      "PENDING" => "Chờ duyệt",
      "PAID" => "Đã duyệt",
      "DELIVERED" => "Đã giao",
      "CANCEL" => "Đã hủy",
      _ => status,
    };
  }
}

class _TimeLine extends StatelessWidget {
  final AdminOrderModel order;

  const _TimeLine({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimeLineRow(label: "Tạo đơn", time: order.createdAt),
        _TimeLineRow(label: "Duyệt thanh toán", time: order.updatedAt),
        _TimeLineRow(label: "Đã giao", time: order.deliveredAt),
      ],
    );
  }
}

class _TimeLineRow extends StatelessWidget {
  final String label;
  final DateTime? time;

  const _TimeLineRow({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 16,
            color: _AdminOrderScreenState.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _AdminOrderScreenState.textMuted),
            ),
          ),
          Text(
            _formatDate(time),
            style: const TextStyle(
              color: _AdminOrderScreenState.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _AdminOrderScreenState.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isEmpty ? "Chưa cập nhật" : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _AdminOrderScreenState.textDark),
          ),
        ),
      ],
    );
  }
}

String _formatPrice(num price) {
  return price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
}

String _formatDate(DateTime? date) {
  if (date == null) return "--";
  String two(int value) => value.toString().padLeft(2, "0");
  return "${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}";
}
