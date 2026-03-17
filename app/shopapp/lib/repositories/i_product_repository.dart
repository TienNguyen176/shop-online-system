import '../models/product_detail.dart';
import '../models/product.dart';

abstract class IProductRepository {

  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 8,
    int? categoryId,
  });

  Future<ProductDetail> getProductDetail(int id);
  
}
