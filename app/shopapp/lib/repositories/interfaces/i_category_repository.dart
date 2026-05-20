import '../../models/category.dart';

abstract class ICategoryRepository {

  /// Lay du lieu cho getAllCategories.
  Future<List<Category>> getAllCategories();

  /// Lay du lieu cho getCategories.
  Future<List<Category>> getCategories();

  /// Tao moi du lieu thong qua createCategory.
  Future<Category> createCategory(Map<String, dynamic> data);

  /// Cap nhat du lieu thong qua updateCategory.
  Future<Category> updateCategory(int id, Map<String, dynamic> data);

  /// Xoa du lieu thong qua deleteCategory.
  Future<void> deleteCategory(int id);

  /// Xoa du lieu cache hien co.
  void clearCache();
}
