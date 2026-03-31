import '../models/product.dart';
import '../models/product_detail.dart';
import 'api_client.dart';

class ProductService {

  /// ================= HOME =================
  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await ApiClient.dio.get(
      "/api/products/home", // 👉 giữ nguyên nếu backend có
      queryParameters: {
        "page": page,
        "pageSize": pageSize,
      },
    );

    final List data = res.data;

    return data.map((e) => Product.fromJson(e)).toList();
  }

  /// ================= BRANDS =================
  Future<List<String>> getBrands() async {
    final res = await ApiClient.dio.get("/api/products/brands");

    final List data = res.data;

    /// ✅ clean nhẹ
    return data.map((e) => e.toString().trim()).toList();
  }

  /// ================= DETAIL =================
  Future<ProductDetail> getProductDetail(int id) async {
    final res = await ApiClient.dio.get("/api/products/$id");
    return ProductDetail.fromJson(res.data);
  }

  /// ================= FILTER =================
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 10,
    List<String>? brands,
    List<String>? colors,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice, String? search, String? category,
  }) async {

    final query = {
      "page": page,
      "pageSize": pageSize,

      /// 🔥 FIX CHÍNH: bỏ join
      if (brands != null && brands.isNotEmpty)
        "brands": brands,

      if (colors != null && colors.isNotEmpty)
        "colors": colors,

      if (sizes != null && sizes.isNotEmpty)
        "sizes": sizes,

      if (minPrice != null) "minPrice": minPrice,
      if (maxPrice != null) "maxPrice": maxPrice,
    };

    print("CALL FILTER API: $query");

    final res = await ApiClient.dio.get(
      "/api/products",
      queryParameters: query,
    );

    /// ⚠️ đảm bảo không crash nếu API lỗi
    final List data = res.data["items"] ?? [];

    return data.map((e) => Product.fromJson(e)).toList();
  }

  getBrandAttributes(String selectedBrand) {}
}