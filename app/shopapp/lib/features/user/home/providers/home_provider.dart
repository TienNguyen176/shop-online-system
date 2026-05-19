import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../models/product.dart';
import '../../../../repositories/interfaces/i_product_repository.dart';

class HomeProvider extends ChangeNotifier {
  final IProductRepository repo;

  HomeProvider(this.repo);

  List<Product> products = [];
  List<Product> allProducts = [];
  List<Product> bannerProducts = [];

  final Set<int> loadedIds = {};

  bool loading = false;
  bool loadingBanner = false;
  bool loadingMore = false;
  bool hasMore = true;
  bool isFetching = false;

  int page = 1;
  final int pageSize = 8;

  int? selectedCategoryId;

  Timer? debounce;

  /// ===============================
  /// LOAD PRODUCTS
  /// ===============================
  Future<void> loadBannerProducts() async {
    if (loadingBanner || bannerProducts.isNotEmpty) return;

    loadingBanner = true;
    notifyListeners();

    try {
      bannerProducts = await repo.getBannerProducts();
    } catch (e) {
      bannerProducts = [];
    }

    loadingBanner = false;
    notifyListeners();
  }

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
      );

      if (data.length < pageSize) {
        hasMore = false;
      }

      /// FILTER
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
      // print("Load products error: $e");
    }

    loading = false;
    loadingMore = false;
    isFetching = false;

    notifyListeners();
  }

  /// ===============================
  /// LOAD MORE
  /// ===============================
  Future<void> loadMore() async {
    if (loadingMore || loading || !hasMore || isFetching) return;

    loadingMore = true;
    notifyListeners();

    await loadProducts();

    loadingMore = false;
    notifyListeners();
  }

  /// ===============================
  /// SEARCH (LOCAL)
  /// ===============================
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

  /// ===============================
  /// FILTER CATEGORY
  /// ===============================
  void selectCategory(int id) {
    if (isFetching) return;

    selectedCategoryId = id == 0 ? null : id;
    loadProducts(refresh: true);
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }
}
