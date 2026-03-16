import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {

  final ProductService service = ProductService();

  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 10
  }) {
    return service.getHomeProducts(
      page: page,
      pageSize: pageSize,
    );
  }

}