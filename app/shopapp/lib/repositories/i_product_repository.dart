import '../models/product_detail.dart';
import '../models/product.dart';

abstract class IProductRepository {

  Future<List<Product>> getHomeProducts({
    int page = 1,
    int pageSize = 8,
    int? categoryId,
  });

  Future<ProductDetail> getProductDetail(int id);
<<<<<<< HEAD
<<<<<<< HEAD
   Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 10,
    List<String>? brands,
    List<String>? colors,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice, required String search, String? category,
  });

  getBrands() {}
=======
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
  
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)
}
