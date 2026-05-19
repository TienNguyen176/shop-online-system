import '../../models/category.dart';
import '../../services/category_service.dart';
import '../interfaces/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryService service = CategoryService();

  List<Category>? _treeCache;
  List<Category>? _flatCache;

  @override
  Future<List<Category>> getCategories() async {
    if (_treeCache != null) {
      return _treeCache!;
    }

    final data = await service.getCategories();
    _treeCache = [Category(id: 0, name: "Tất cả", slug: "all"), ...data];
    return _treeCache!;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    if (_flatCache != null) {
      return _flatCache!;
    }

    final data = await service.getAllCategories();
    _flatCache = data;
    return _flatCache!;
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> data) async {
    final created = await service.createCategory(data);
    clearCache();
    return created;
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final updated = await service.updateCategory(id, data);
    clearCache();
    return updated;
  }

  @override
  Future<void> deleteCategory(int id) async {
    await service.deleteCategory(id);
    clearCache();
  }

  @override
  void clearCache() {
    _treeCache = null;
    _flatCache = null;
  }
}
