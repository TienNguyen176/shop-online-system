import '../models/category.dart';
import '../services/category_service.dart';
import 'i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  final CategoryService service = CategoryService();

  /// CACHE
  List<Category>? _cache;

  @override
  Future<List<Category>> getCategories() async {

    if (_cache != null) {
      return _cache!;
    }

    final data = await service.getCategories();

    /// Thêm "Tất cả"
    _cache = [Category(id: 0, name: "Tất cả", slug: "all"), ...data];

    return _cache!;
  }
}
