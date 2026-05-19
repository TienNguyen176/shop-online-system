import 'package:flutter/material.dart';

import '../../../../models/statistic_item.dart';
import '../../../../repositories/interfaces/i_statistic_repository.dart';

/// Provider quản lý dữ liệu thống kê hiển thị trên dashboard admin.
class DashboardProvider extends ChangeNotifier {
  final IStatisticRepository repo;

  DashboardProvider(this.repo);

  /// Danh sách chỉ số thống kê trả về từ backend.
  List<StatisticItem> _items = [];

  /// Trạng thái tải dữ liệu và lỗi để màn hình dashboard phản hồi đúng.
  bool _loading = false;
  String? _error;

  List<StatisticItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  /// Mục có phần trăm cao nhất, dùng để làm nổi bật thống kê tốt nhất.
  StatisticItem? get topItem {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.percent > b.percent ? a : b);
  }

  /// Mục có phần trăm thấp nhất, dùng để cảnh báo hoặc so sánh.
  StatisticItem? get bottomItem {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.percent < b.percent ? a : b);
  }

  /// Tổng phần trăm của toàn bộ chỉ số, dùng cho biểu đồ/tổng quan.
  int get totalPercent {
    return _items.fold(0, (sum, item) => sum + item.percent);
  }

  /// Gọi API thống kê và cập nhật state cho dashboard.
  Future<void> loadStatistic() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await repo.getStatistic();
    } catch (e) {
      _items = [];
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Xóa lỗi hiện tại sau khi UI đã hiển thị hoặc người dùng thử lại.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
