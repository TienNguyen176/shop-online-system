import 'package:flutter/material.dart';
import '../../../../models/category.dart';
import '../../../../../repositories/interfaces/i_category_repository.dart';

/// Provider quản lý danh mục sản phẩm cho các màn hình admin.
class CategoryProvider extends ChangeNotifier {
  final ICategoryRepository repository;

  CategoryProvider(this.repository);

  /// Danh sách danh mục đang được cache trong app.
  List<Category> categories = [];

  /// Cờ loading khi gọi API danh mục.
  bool isLoading = false;

  /// Tải danh mục một lần, nếu đã có dữ liệu thì dùng cache để tránh gọi API lại.
  Future<void> loadCategories() async {
    if (categories.isNotEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      categories = await repository.getCategories();
    } catch (e) {
      debugPrint("Load category error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
