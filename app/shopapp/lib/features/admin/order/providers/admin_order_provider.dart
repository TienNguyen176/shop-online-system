import 'package:flutter/material.dart';

import '../../../../services/admin_order_service.dart';
import '../models/admin_order_model.dart';
import '../models/admin_return_request_model.dart';

class AdminOrderProvider extends ChangeNotifier {
  final AdminOrderService service;

  AdminOrderProvider(this.service);

  final List<String> statuses = const [
    "ALL",
    "PENDING",
    "PAID",
    "DELIVERED",
    "RETURN_PENDING",
    "RETURN_APPROVED",
    "RETURN_REJECTED",
  ];

  List<AdminOrderModel> orders = [];
  List<AdminReturnRequestModel> returnRequests = [];
  String selectedStatus = "ALL";
  bool loading = false;
  String? error;

  Future<void> loadOrders({String? status}) async {
    selectedStatus = status ?? selectedStatus;
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (selectedStatus.startsWith("RETURN_")) {
        orders = [];
        returnRequests = await service.getReturnRequests(
          status: selectedStatus.replaceFirst("RETURN_", ""),
        );
      } else {
        returnRequests = [];
        orders = await service.getOrders(
          status: selectedStatus == "ALL" ? null : selectedStatus,
        );
      }
    } catch (e) {
      error = e.toString();
      orders = [];
      returnRequests = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> approve(AdminOrderModel order) async {
    final nextStatus = switch (order.status.toUpperCase()) {
      "PENDING" => "PAID",
      "PAID" => "DELIVERED",
      _ => "",
    };

    if (nextStatus.isEmpty) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      await service.updateStatus(orderId: order.id, status: nextStatus);
      await loadOrders(status: selectedStatus);
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }

  Future<void> reviewReturnRequest({
    required AdminReturnRequestModel request,
    required String status,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await service.updateReturnRequestStatus(
        requestId: request.id,
        status: status,
      );
      await loadOrders(status: selectedStatus);
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    }
  }
}
