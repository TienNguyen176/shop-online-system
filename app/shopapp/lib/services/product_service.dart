import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await ApiClient.dio.get(
      "/api/products/home",
      queryParameters: {"page": page, "pageSize": pageSize},
    );

    final List data = res.data;

    return data.map((e) => Product.fromJson(e)).toList();
  }
}
