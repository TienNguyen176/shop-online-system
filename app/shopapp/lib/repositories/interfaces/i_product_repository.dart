import '../../models/product_detail.dart';
import '../../models/product.dart';

abstract class IProductRepository {

  /// Lay du lieu cho getHomeProducts.
  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 8,
    int? categoryId,
    List<int>? categoryIds,
    String? search,
    String? brand,
    List<String>? brands,
    double? minRating,
    double? minPrice,
    double? maxPrice,
    bool forceRefresh = false,
  });

  /// Lay du lieu cho getBrands.
  Future<List<String>> getBrands({bool forceRefresh = false});

  /// Lay du lieu cho getBannerProducts.
  Future<List<Product>> getBannerProducts({bool forceRefresh = false});

  /// Lay du lieu cho getProductDetail.
  Future<ProductDetail> getProductDetail(int id, {bool forceRefresh = false});
  
}
