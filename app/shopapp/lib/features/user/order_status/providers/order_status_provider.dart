import 'package:flutter/material.dart';

import '../../../../models/order_model.dart';
import '../../../../repositories/interfaces/i_order_repository.dart';

class OrderStatusProvider extends ChangeNotifier {
  final IOrderRepository repo;

  OrderStatusProvider(this.repo);

  static const List<String> tabs = [
    "Chờ xác nhận",
    "Chờ giao hàng",
    "Đã giao",
    "Đã hủy",
  ];

  static const List<String> apiStatus = [
    "PENDING",
    "PAID",
    "DELIVERED",
    "CANCEL",
  ];

  List<OrderModel> _orders = [];
  bool _loading = false;
  String? _error;
  int _selectedIndex = 0;
  int _userId = 0;

  List<OrderModel> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;
  String get selectedStatus => apiStatus[_selectedIndex];

  Future<void> loadOrders(int userId) async {
    _userId = userId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await repo.getOrdersByStatus(
        userId: userId,
        status: selectedStatus,
      );
    } catch (e) {
      _orders = [];
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> changeTab(int index) async {
    if (index == _selectedIndex) return;

    _selectedIndex = index;
    notifyListeners();

    if (_userId != 0) {
      await loadOrders(_userId);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
