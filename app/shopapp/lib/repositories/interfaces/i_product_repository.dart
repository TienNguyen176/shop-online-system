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
  });

  Future<List<String>> getBrands();

  Future<List<Product>> getBannerProducts();

  Future<ProductDetail> getProductDetail(int id);
  
}
