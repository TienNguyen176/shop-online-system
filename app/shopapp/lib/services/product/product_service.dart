import '../../models/product.dart';
import '../../models/product_detail.dart';
import '../../core/api/api_client.dart';

class ProductService {
  /// Lấy danh sách sản phẩm cho trang chủ với bộ lọc và phân trang.
  ///
  /// Tham số:
  /// - [page]: số trang cần lấy.
  /// - [pageSize]: số lượng sản phẩm trên mỗi trang.
  /// - [categoryId]: lọc theo một danh mục cụ thể.
  /// - [categoryIds]: lọc theo danh sách nhiều danh mục.
  /// - [search]: tìm kiếm theo tên hoặc mô tả.
  /// - [brand]: lọc theo thương hiệu.
  /// - [brands]: lọc theo nhiều thương hiệu.
  /// - [minRating]: lọc sản phẩm có đánh giá tối thiểu.
  /// - [minPrice]: giá tối thiểu.
  /// - [maxPrice]: giá tối đa.
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

  /// Lấy danh sách tên thương hiệu từ API.
  Future<List<String>> getBrands() async {
    final res = await ApiClient.dio.get("/api/products/brands");

    final List data = res.data;

    return data.map((e) => e.toString()).toList();
  }

  /// Lấy danh sách sản phẩm banner để hiển thị ở đầu trang.
  Future<List<Product>> getBannerProducts() async {
    final res = await ApiClient.dio.get("/api/products/banner");

    final List data = res.data;

    return data.map((e) => Product.fromJson(e)).toList();
  }

  /// Lấy chi tiết sản phẩm theo [id].
  Future<ProductDetail> getProductDetail(int id) async {
    final res = await ApiClient.dio.get("/api/products/$id");

    return ProductDetail.fromJson(res.data);
  }
}
