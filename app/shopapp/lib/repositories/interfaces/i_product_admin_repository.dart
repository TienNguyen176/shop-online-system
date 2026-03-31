import '../../features/admin/models/admin_product_model.dart';

abstract class IProductAdminRepository {
  Future<List<AdminProduct>> getProducts({int page, int pageSize});

  Future<int> createProduct(Map<String, dynamic> data);

  Future<void> updateProduct(int id, Map<String, dynamic> data);

  Future<void> deleteProduct(int id);

  Future<String> uploadImage(int productId, String filePath);
}
