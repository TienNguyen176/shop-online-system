import '../../models/product.dart';
import '../../models/product_detail.dart';
import '../../services/product/product_service.dart';
import '../interfaces/i_product_repository.dart';

class ProductRepository implements IProductRepository {
  final ProductService service = ProductService();

  /// CACHE HOME
  final Map<String, List<Product>> _homeCache = {};
  List<String>? _brandCache;
  List<Product>? _bannerCache;

  /// CACHE DETAIL
  final Map<int, ProductDetail> _detailCache = {};

  /// ================= HOME =================
  @override
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
    final key =
        "$page-$pageSize-$categoryId-$categoryIds-$search-$brand-$brands-$minRating-$minPrice-$maxPrice";

    /// Cache
    if (_homeCache.containsKey(key)) {
      return _homeCache[key]!;
    }

    final data = await service.getHomeProducts(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
      categoryIds: categoryIds,
      search: search,
      brand: brand,
      brands: brands,
      minRating: minRating,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    _homeCache[key] = data;
    return data;
  }

  @override
  Future<List<String>> getBrands() async {
    if (_brandCache != null) {
      return _brandCache!;
    }

    final data = await service.getBrands();
    _brandCache = data;
    return data;
  }

  @override
  Future<List<Product>> getBannerProducts() async {
    if (_bannerCache != null) {
      return _bannerCache!;
    }

    final data = await service.getBannerProducts();
    _bannerCache = data;
    return data;
  }

  /// ================= DETAIL =================
  @override
  Future<ProductDetail> getProductDetail(int id) async {
    /// Cache
    if (_detailCache.containsKey(id)) {
      return _detailCache[id]!;
    }

    final data = await service.getProductDetail(id);
    _detailCache[id] = data;

    return data;
  }
}
