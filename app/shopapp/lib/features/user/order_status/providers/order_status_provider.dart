import 'package:flutter/material.dart';

import '../../../../models/order_model.dart';
import '../../../../repositories/interfaces/i_order_repository.dart';

/// Provider quản lý danh sách đơn hàng theo từng tab trạng thái.
class OrderStatusProvider extends ChangeNotifier {
  final IOrderRepository repo;

  OrderStatusProvider(this.repo);

  /// Tên tab hiển thị cho người dùng.
  static const List<String> tabs = [
    "Chờ xác nhận",
    "Chờ giao hàng",
    "Đã giao",
    "Đã hủy",
  ];

  /// Trạng thái tương ứng với API backend.
  static const List<String> apiStatus = [
    "PENDING",
    "PAID",
    "DELIVERED",
    "CANCEL",
  ];

  /// Danh sách đơn hàng của tab hiện tại.
  List<OrderModel> _orders = [];

  /// Trạng thái tải dữ liệu và lỗi để màn hình order status xử lý UI.
  bool _loading = false;
  String? _error;

  /// Tab đang được chọn và user hiện tại để reload khi đổi tab.
  int _selectedIndex = 0;
  int _userId = 0;

  List<OrderModel> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;
  String get selectedStatus => apiStatus[_selectedIndex];

  /// Tải danh sách đơn hàng theo userId và trạng thái tab hiện tại.
  Future<void> loadOrders(int userId, {bool showLoading = true}) async {
    _userId = userId;
    if (showLoading) {
      _error = null;
      _loading = true;
      notifyListeners();
    }

    try {
      _orders = await repo.getOrdersByStatus(
        userId: userId,
        status: selectedStatus,
      );
    } catch (e) {
      if (showLoading) {
        _orders = [];
        _error = e.toString();
      }
    }

    if (showLoading) {
      _loading = false;
    }
    notifyListeners();
  }

  /// Đổi tab trạng thái và tải lại đơn hàng tương ứng.
  Future<void> changeTab(int index) async {
    if (index == _selectedIndex) return;

    _selectedIndex = index;
    notifyListeners();

    if (_userId != 0) {
      await loadOrders(_userId);
    }
  }

  /// Xóa lỗi hiện tại để UI không tiếp tục hiển thị lỗi cũ.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}