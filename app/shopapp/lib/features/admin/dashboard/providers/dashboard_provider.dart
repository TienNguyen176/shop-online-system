import 'package:flutter/material.dart';

import '../../../../models/statistic_item.dart';
import '../../../../repositories/interfaces/i_statistic_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final IStatisticRepository repo;

  DashboardProvider(this.repo);

  List<StatisticItem> _items = [];
  bool _loading = false;
  String? _error;

  List<StatisticItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  StatisticItem? get topItem {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.percent > b.percent ? a : b);
  }

  StatisticItem? get bottomItem {
    if (_items.isEmpty) return null;
    return _items.reduce((a, b) => a.percent < b.percent ? a : b);
  }

  int get totalPercent {
    return _items.fold(0, (sum, item) => sum + item.percent);
  }

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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
