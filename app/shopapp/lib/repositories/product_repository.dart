import '../models/product.dart';
import '../models/product_detail.dart';
import '../services/product_service.dart';
import 'i_product_repository.dart';

class ProductRepository implements IProductRepository {
  final ProductService service = ProductService();

  /// CACHE HOME
  final Map<String, List<Product>> _homeCache = {};

  /// CACHE DETAIL
  final Map<int, ProductDetail> _detailCache = {};

  /// ================= HOME =================
  @override
  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final key = "$page-$pageSize";

    /// Cache
    if (_homeCache.containsKey(key)) {
      return _homeCache[key]!;
    }

    final data = await service.getHomeProducts(page: page, pageSize: pageSize);

    _homeCache[key] = data;
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
