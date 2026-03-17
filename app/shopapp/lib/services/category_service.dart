import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  /// GET TREE (level 1)
  Future<List<Category>> getCategories() async {
    final res = await ApiClient.dio.get("/api/categories/tree");

    final List data = res.data;

    return data.map((e) => Category.fromJson(e)).toList();
  }
}
