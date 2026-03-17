import '../models/product.dart';
import '../models/product_detail.dart';
import '../services/product_service.dart';
import 'i_product_repository.dart';

class ProductRepository implements IProductRepository {
  final ProductService service = ProductService();

<<<<<<< HEAD
  /// ================= CACHE =================
  final Map<String, List<Product>> _homeCache = {};
  final Map<int, ProductDetail> _detailCache = {};
  final Map<String, List<Product>> _filterCache = {};
=======
  /// CACHE HOME
  final Map<String, List<Product>> _homeCache = {};

  /// CACHE DETAIL
  final Map<int, ProductDetail> _detailCache = {};
>>>>>>> 4d9c391 (apply new gitignore rules)

  /// ================= HOME =================
  @override
  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 8,
    int? categoryId,
  }) async {
    final key = "$page-$pageSize-$categoryId";

<<<<<<< HEAD
=======
    /// Cache
>>>>>>> 4d9c391 (apply new gitignore rules)
    if (_homeCache.containsKey(key)) {
      return _homeCache[key]!;
    }

<<<<<<< HEAD
<<<<<<< HEAD
    final data = await service.getHomeProducts(
      page: page,
      pageSize: pageSize,
    );
=======
    final data = await service.getHomeProducts(page: page, pageSize: pageSize);
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
    final data = await service.getHomeProducts(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
    );
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)

    _homeCache[key] = data;
    return data;
  }

  /// ================= DETAIL =================
  @override
  Future<ProductDetail> getProductDetail(int id) async {
<<<<<<< HEAD
=======
    /// Cache
>>>>>>> 4d9c391 (apply new gitignore rules)
    if (_detailCache.containsKey(id)) {
      return _detailCache[id]!;
    }

    final data = await service.getProductDetail(id);
<<<<<<< HEAD

    _detailCache[id] = data;
    return data;
  }

  /// ================= FILTER =================
  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 10,
    List<String>? brands,
    List<String>? colors,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? category, // ✅ Thêm category
  }) async {
    final key =
        "$page-$pageSize-${brands?.join(",")}-${colors?.join(",")}-${sizes?.join(",")}-$minPrice-$maxPrice-$search-$category"; // ✅ Thêm category vào key cache

    if (_filterCache.containsKey(key)) {
      return _filterCache[key]!;
    }

    final data = await service.getProducts(
      page: page,
      pageSize: pageSize,
      brands: brands,
      colors: colors,
      sizes: sizes,
      minPrice: minPrice,
      maxPrice: maxPrice,
      search: search,
      category: category, // ✅ Truyền category vào service
    );

    _filterCache[key] = data;

    return data;
  }

  /// ================= BRANDS =================
  @override
  Future<List<String>> getBrands() async {
    final data = await service.getBrands();
    return data;
  }
}
=======
    _detailCache[id] = data;

    return data;
  }
}
>>>>>>> 4d9c391 (apply new gitignore rules)
