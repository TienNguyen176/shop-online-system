import '../../features/admin/models/admin_product_model.dart';
import '../../features/admin/product/models/admin_product_variant.dart';

abstract class IProductAdminRepository {
  Future<List<AdminProduct>> getProducts({int page, int pageSize});

  Future<int> createProduct(Map<String, dynamic> data);

  Future<void> updateProduct(int id, Map<String, dynamic> data);

  Future<void> deleteProduct(int id);

  Future<String> uploadImage(int productId, String filePath);

  Future<List<AdminProductVariant>> getVariants(int productId);

  Future<void> createVariant(int productId, Map<String, dynamic> data);

  Future<void> updateVariant(
    int productId,
    int variantId,
    Map<String, dynamic> data,
  );

  Future<void> deleteVariant(int productId, int variantId);
}
