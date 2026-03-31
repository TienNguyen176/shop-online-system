import '../../models/category.dart';
import '../../services/category_service.dart';
import '../interfaces/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryService service = CategoryService();

  /// CACHE
  List<Category>? _treeCache;
  List<Category>? _flatCache;

  /// TREE (UI user)
  @override
  Future<List<Category>> getCategories() async {
    if (_treeCache != null) {
      return _treeCache!;
    }

    final data = await service.getCategories();

    _treeCache = [Category(id: 0, name: "Tất cả", slug: "all"), ...data];

    return _treeCache!;
  }

  /// FLAT
  @override
  Future<List<Category>> getAllCategories() async {
    if (_flatCache != null) {
      return _flatCache!;
    }

    final data = await service.getAllCategories();

    _flatCache = data;

    return _flatCache!;
  }
}
