import '../../features/admin/models/admin_product_model.dart';
import '../../services/product/product_admin_service.dart';
import '../interfaces/i_product_admin_repository.dart';

class ProductAdminRepository implements IProductAdminRepository {
  final ProductAdminService service = ProductAdminService();

  @override
  Future<List<AdminProduct>> getProducts({int page = 1, int pageSize = 10}) {
    return service.getProducts(page: page, pageSize: pageSize);
  }

  @override
  Future<int> createProduct(Map<String, dynamic> data) {
    return service.createProduct(data);
  }

  @override
  Future<void> updateProduct(int id, Map<String, dynamic> data) {
    return service.updateProduct(id, data);
  }

  @override
  Future<void> deleteProduct(int id) {
    return service.deleteProduct(id);
  }

  @override
  Future<String> uploadImage(int productId, String filePath) {
    return service.uploadImage(productId, filePath);
  }
}
