import '../../features/admin/models/admin_product_model.dart';
import '../../features/admin/product/models/admin_product_variant.dart';
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

  @override
  Future<List<AdminProductVariant>> getVariants(int productId) {
    return service.getVariants(productId);
  }

  @override
  Future<void> createVariant(int productId, Map<String, dynamic> data) {
    return service.createVariant(productId, data);
  }

  @override
  Future<void> updateVariant(
    int productId,
    int variantId,
    Map<String, dynamic> data,
  ) {
    return service.updateVariant(productId, variantId, data);
  }

  @override
  Future<void> deleteVariant(int productId, int variantId) {
    return service.deleteVariant(productId, variantId);
  }
}
