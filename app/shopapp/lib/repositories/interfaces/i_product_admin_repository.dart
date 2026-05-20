import '../../features/admin/models/admin_product_model.dart';
import '../../features/admin/product/models/admin_product_variant.dart';

abstract class IProductAdminRepository {
  /// Lay du lieu cho getProducts.
  Future<List<AdminProduct>> getProducts({int page, int pageSize});

  /// Tao moi du lieu thong qua createProduct.
  Future<int> createProduct(Map<String, dynamic> data);

  /// Cap nhat du lieu thong qua updateProduct.
  Future<void> updateProduct(int id, Map<String, dynamic> data);

  /// Xoa du lieu thong qua deleteProduct.
  Future<void> deleteProduct(int id);

  Future<String> uploadImage(int productId, String filePath);

  /// Lay du lieu cho getVariants.
  Future<List<AdminProductVariant>> getVariants(int productId);

  /// Tao moi du lieu thong qua createVariant.
  Future<void> createVariant(int productId, Map<String, dynamic> data);

  /// Cap nhat du lieu thong qua updateVariant.
  Future<void> updateVariant(
    int productId,
    int variantId,
    Map<String, dynamic> data,
  );

  /// Xoa du lieu thong qua deleteVariant.
  Future<void> deleteVariant(int productId, int variantId);
}
