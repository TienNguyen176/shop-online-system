import '../../models/product_detail.dart';
import '../../models/product.dart';

abstract class IProductRepository {

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

  Future<List<String>> getBrands({bool forceRefresh = false});

  Future<List<Product>> getBannerProducts({bool forceRefresh = false});

  Future<ProductDetail> getProductDetail(int id, {bool forceRefresh = false});
  
}
