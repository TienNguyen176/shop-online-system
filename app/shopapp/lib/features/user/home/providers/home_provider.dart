import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../models/product.dart';
import '../../../../repositories/interfaces/i_product_repository.dart';

/// Provider quản lý dữ liệu trang chủ: banner, danh sách sản phẩm, tìm kiếm và phân trang.
class HomeProvider extends ChangeNotifier {
  final IProductRepository repo;

  HomeProvider(this.repo);

  /// Danh sách sản phẩm đang hiển thị trên màn hình.
  List<Product> products = [];

  /// Danh sách gốc dùng cho tìm kiếm local.
  List<Product> allProducts = [];

  /// Danh sách sản phẩm nổi bật dùng cho banner.
  List<Product> bannerProducts = [];

  /// Bộ id đã tải để tránh thêm trùng sản phẩm khi phân trang.
  final Set<int> loadedIds = {};

  /// Các cờ loading để UI phản hồi đúng từng khu vực.
  bool loading = false;
  bool loadingBanner = false;
  bool loadingMore = false;
  bool hasMore = true;
  bool isFetching = false;

  /// Thông tin phân trang danh sách sản phẩm.
  int page = 1;
  final int pageSize = 8;

  /// Danh mục đang được chọn, null nghĩa là tất cả.
  int? selectedCategoryId;

  /// Timer debounce để giảm số lần lọc khi người dùng nhập tìm kiếm.
  Timer? debounce;

  /// Tải danh sách sản phẩm dùng cho banner trang chủ.
  Future<void> loadBannerProducts({bool refresh = false}) async {
    if (loadingBanner || (!refresh && bannerProducts.isNotEmpty)) return;

    loadingBanner = true;
    notifyListeners();

    try {
      bannerProducts = await repo.getBannerProducts(forceRefresh: refresh);
    } catch (e) {
      bannerProducts = [];
    }

    loadingBanner = false;
    notifyListeners();
  }

  /// Tải danh sách sản phẩm theo trang, có thể refresh về trang đầu.
  Future<void> loadProducts({bool refresh = false}) async {
    if (isFetching) return;

    isFetching = true;

    int currentPage = refresh ? 1 : page;

    if (refresh) {
      page = 1;
      hasMore = true;

      products.clear();
      allProducts.clear();
      loadedIds.clear();
    }

    if (!hasMore) {
      isFetching = false;
      return;
    }

    if (products.isEmpty) {
      loading = true;
      notifyListeners();
    }

    try {
      final data = await repo.getHomeProducts(
        page: currentPage,
        pageSize: pageSize,
        categoryId: selectedCategoryId,
        forceRefresh: refresh,
      );

      if (data.length < pageSize) {
        hasMore = false;
      }

      /// Lọc bỏ sản phẩm đã tải trước đó để tránh trùng item.
      final filtered = data.where((p) => loadedIds.add(p.id)).toList();

      if (filtered.isNotEmpty) {
        if (currentPage == 1) {
          products = List.from(filtered);
          allProducts = List.from(filtered);
        } else {
          products.addAll(filtered);
          allProducts.addAll(filtered);
        }

        page++;
      } else {
        hasMore = false;
      }
    } catch (e) {
      // Có thể gắn logger ở đây nếu cần theo dõi lỗi tải sản phẩm.
    }

    loading = false;
    loadingMore = false;
    isFetching = false;

    notifyListeners();
  }

  /// Tải thêm sản phẩm khi người dùng cuộn gần cuối danh sách.
  Future<void> loadMore() async {
    if (loadingMore || loading || !hasMore || isFetching) return;

    loadingMore = true;
    notifyListeners();

    await loadProducts();

    loadingMore = false;
    notifyListeners();
  }

  /// Debounce từ khóa tìm kiếm và lọc sản phẩm trên danh sách đã tải.
  void search(String keyword) {
    debounce?.cancel();

    debounce = Timer(const Duration(milliseconds: 400), () {
      if (keyword.isEmpty) {
        products = List.from(allProducts);
      } else {
        products =
            allProducts.where((p) {
              return p.name.toLowerCase().contains(keyword.toLowerCase());
            }).toList();
      }

      notifyListeners();
    });
  }

  /// Chọn danh mục và tải lại sản phẩm thuộc danh mục đó.
  void selectCategory(int id) {
    if (isFetching) return;

    selectedCategoryId = id == 0 ? null : id;
    loadProducts(refresh: true);
  }

  /// Hủy debounce khi provider bị dispose để tránh callback chạy sau khi màn hình đóng.
  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }
}
