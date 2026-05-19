import '../models/category.dart';
import '../core/api/api_client.dart';

class CategoryService {
  
  Future<List<Category>> getAllCategories() async {
    final res = await ApiClient.dio.get("/api/categories");

    final List data = res.data;

    return data.map((e) => Category.fromJson(e)).toList();
  }

  /// GET TREE (level 1)
  Future<List<Category>> getCategories() async {
    final res = await ApiClient.dio.get("/api/categories/tree");

    final List data = res.data;

    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final res = await ApiClient.dio.post("/api/categories", data: data);
    return Category.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final res = await ApiClient.dio.put("/api/categories/$id", data: data);
    return Category.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteCategory(int id) async {
    await ApiClient.dio.delete("/api/categories/$id");
  }
}
