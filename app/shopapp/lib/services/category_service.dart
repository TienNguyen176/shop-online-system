import '../models/category.dart';
import '../core/api/api_client.dart';

class CategoryService {
  
  /// Lay du lieu cho getAllCategories.
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

  /// Tao moi du lieu thong qua createCategory.
  Future<Category> createCategory(Map<String, dynamic> data) async {
    final res = await ApiClient.dio.post("/api/categories", data: data);
    return Category.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Cap nhat du lieu thong qua updateCategory.
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final res = await ApiClient.dio.put("/api/categories/$id", data: data);
    return Category.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Xoa du lieu thong qua deleteCategory.
  Future<void> deleteCategory(int id) async {
    await ApiClient.dio.delete("/api/categories/$id");
  }
}
