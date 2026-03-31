import 'package:flutter/material.dart';
import '../../../../models/category.dart';
import '../../../../../repositories/interfaces/i_category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final ICategoryRepository repository;

  CategoryProvider(this.repository);

  List<Category> categories = [];
  bool isLoading = false;

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
