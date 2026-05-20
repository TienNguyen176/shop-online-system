import '../../features/admin/models/admin_product_model.dart';
import '../../features/admin/product/models/admin_product_variant.dart';
import '../../services/product/product_admin_service.dart';
import '../interfaces/i_product_admin_repository.dart';

class ProductAdminRepository implements IProductAdminRepository {
  final ProductAdminService service = ProductAdminService();

  /// Lay du lieu cho getProducts.
  @override
  Future<List<AdminProduct>> getProducts({int page = 1, int pageSize = 10}) {
    return service.getProducts(page: page, pageSize: pageSize);
  }

  /// Tao moi du lieu thong qua createProduct.
  @override
  Future<int> createProduct(Map<String, dynamic> data) {
    return service.createProduct(data);
  }

  /// Cap nhat du lieu thong qua updateProduct.
  @override
  Future<void> updateProduct(int id, Map<String, dynamic> data) {
    return service.updateProduct(id, data);
  }

  /// Xoa du lieu thong qua deleteProduct.
  @override
  Future<void> deleteProduct(int id) {
    return service.deleteProduct(id);
  }

  @override
  Future<String> uploadImage(int productId, String filePath) {
    return service.uploadImage(productId, filePath);
  }

  /// Lay du lieu cho getVariants.
  @override
  Future<List<AdminProductVariant>> getVariants(int productId) {
    return service.getVariants(productId);
  }

  /// Tao moi du lieu thong qua createVariant.
  @override
  Future<void> createVariant(int productId, Map<String, dynamic> data) {
    return service.createVariant(productId, data);
  }

  /// Cap nhat du lieu thong qua updateVariant.
  @override
  Future<void> updateVariant(
    int productId,
    int variantId,
    Map<String, dynamic> data,
  ) {
    return service.updateVariant(productId, variantId, data);
  }

  /// Xoa du lieu thong qua deleteVariant.
  @override
  Future<void> deleteVariant(int productId, int variantId) {
    return service.deleteVariant(productId, variantId);
  }
}
