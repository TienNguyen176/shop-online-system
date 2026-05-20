import '../../models/category.dart';
import '../../services/category_service.dart';
import '../interfaces/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryService service = CategoryService();

  List<Category>? _treeCache;
  List<Category>? _flatCache;

  /// Lay du lieu cho getCategories.
  @override
  Future<List<Category>> getCategories() async {
    if (_treeCache != null) {
      return _treeCache!;
    }

    final data = await service.getCategories();
    _treeCache = [Category(id: 0, name: "Tất cả", slug: "all"), ...data];
    return _treeCache!;
  }

  /// Lay du lieu cho getAllCategories.
  @override
  Future<List<Category>> getAllCategories() async {
    if (_flatCache != null) {
      return _flatCache!;
    }

    final data = await service.getAllCategories();
    _flatCache = data;
    return _flatCache!;
  }

  /// Tao moi du lieu thong qua createCategory.
  @override
  Future<Category> createCategory(Map<String, dynamic> data) async {
    final created = await service.createCategory(data);
    clearCache();
    return created;
  }

  /// Cap nhat du lieu thong qua updateCategory.
  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final updated = await service.updateCategory(id, data);
    clearCache();
    return updated;
  }

  /// Xoa du lieu thong qua deleteCategory.
  @override
  Future<void> deleteCategory(int id) async {
    await service.deleteCategory(id);
    clearCache();
  }

  /// Xoa du lieu cache hien co.
  @override
  void clearCache() {
    _treeCache = null;
    _flatCache = null;
  }
}
