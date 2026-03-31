import '../models/product_detail.dart';
import '../models/product.dart';

abstract class IProductRepository {
  
  Future<List<Product>> getHomeProducts({int page = 1, int pageSize = 10});

  Future<ProductDetail> getProductDetail(int id);
   Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 10,
    List<String>? brands,
    List<String>? colors,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice, required String search, String? category,
  });

  getBrands() {}
}
