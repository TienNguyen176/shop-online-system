import 'package:flutter/material.dart';

import '../../../../models/category.dart';
import '../../../../repositories/interfaces/i_category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final ICategoryRepository repository;

  CategoryProvider(this.repository);

  List<Category> categories = [];
  List<Category> flatCategories = [];
  bool isLoading = false;
  String? error;

  /// Tai du lieu can thiet cho loadCategories.
  Future<void> loadCategories({bool refresh = false}) async {
    if (!refresh && categories.isNotEmpty && flatCategories.isNotEmpty) return;
    if (refresh) {
      repository.clearCache();
      categories = [];
      flatCategories = [];
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      flatCategories = await repository.getAllCategories();
      notifyListeners();

      try {
        categories = await repository.getCategories();
      } catch (treeError) {
        categories = flatCategories;
        debugPrint("Load category tree error: $treeError");
      }
    } catch (e) {
      error = e.toString();
      debugPrint("Load category error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Luu du lieu tu form hoac state hien tai.
  Future<void> saveCategory({
    Category? category,
    required String name,
    required String slug,
    int? parentId,
    String? image,
  }) async {
    final data = {
      "name": name,
      "slug": slug,
      "parentId": parentId,
      "image": image,
    };

    if (category == null) {
      await repository.createCategory(data);
    } else {
      await repository.updateCategory(category.id, data);
    }

    await loadCategories(refresh: true);
  }

  /// Xoa du lieu thong qua deleteCategory.
  Future<void> deleteCategory(int id) async {
    await repository.deleteCategory(id);
    await loadCategories(refresh: true);
  }
}
