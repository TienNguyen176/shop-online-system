import '../../models/product.dart';
import '../../models/product_detail.dart';
import '../../core/api/api_client.dart';

class ProductService {
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
  }) async {
    final res = await ApiClient.dio.get(
      "/api/products/",
      queryParameters: {
        "page": page,
        "pageSize": pageSize,
        if (categoryId != null && categoryId != 0) "categoryId": categoryId,
        if (categoryIds != null && categoryIds.isNotEmpty)
          "categoryIds": categoryIds.join(","),
        if (search != null && search.trim().isNotEmpty) "search": search,
        if (brand != null && brand.trim().isNotEmpty) "brand": brand,
        if (brands != null && brands.isNotEmpty) "brands": brands.join(","),
        if (minRating != null) "minRating": minRating,
        if (minPrice != null) "minPrice": minPrice,
        if (maxPrice != null) "maxPrice": maxPrice,
      },
    );

    final List data = res.data;

    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<String>> getBrands() async {
    final res = await ApiClient.dio.get("/api/products/brands");

    final List data = res.data;

    return data.map((e) => e.toString()).toList();
  }

  Future<List<Product>> getBannerProducts() async {
    final res = await ApiClient.dio.get("/api/products/banner");

    final List data = res.data;

    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<ProductDetail> getProductDetail(int id) async {
    final res = await ApiClient.dio.get("/api/products/$id");

    return ProductDetail.fromJson(res.data);
  }
}
