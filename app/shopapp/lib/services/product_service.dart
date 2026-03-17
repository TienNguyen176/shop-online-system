import '../models/product.dart';
import '../models/product_detail.dart';
import 'api_client.dart';

class ProductService {
  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 8,
    int? categoryId,
  }) async {
    final res = await ApiClient.dio.get(
      "/api/products/home",
      queryParameters: {
        "page": page,
        "pageSize": pageSize,
        if (categoryId != null && categoryId != 0) "categoryId": categoryId,
      },
    );

    final List data = res.data;

    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<ProductDetail> getProductDetail(int id) async {
    final res = await ApiClient.dio.get("/api/products/$id");

    return ProductDetail.fromJson(res.data);
  }
}
