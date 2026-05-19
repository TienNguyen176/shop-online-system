import '../../models/category.dart';

abstract class ICategoryRepository {

  Future<List<Category>> getAllCategories();

  Future<List<Category>> getCategories();

  Future<Category> createCategory(Map<String, dynamic> data);

  Future<Category> updateCategory(int id, Map<String, dynamic> data);

  Future<void> deleteCategory(int id);

  void clearCache();
}
