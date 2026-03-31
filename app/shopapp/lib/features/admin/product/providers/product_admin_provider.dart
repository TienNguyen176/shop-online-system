import 'package:flutter/material.dart';

import '../../models/admin_product_model.dart';
import '../../../../repositories/interfaces/i_product_admin_repository.dart';

class ProductAdminProvider extends ChangeNotifier {
  final IProductAdminRepository repo;

  ProductAdminProvider(this.repo);

  List<AdminProduct> products = [];

  int page = 1;
  final int pageSize = 10;

  bool loading = false;
  bool isFetching = false;
  bool hasMore = true;

  /// =========================
  /// LOAD PRODUCTS
  /// =========================
  Future<void> loadProducts({bool refresh = false}) async {
    if (isFetching) return;

    isFetching = true;

    if (refresh) {
      page = 1;
      hasMore = true;
      products.clear();
    }

    if (products.isEmpty) {
      loading = true;
      notifyListeners();
    }

    try {
      final data = await repo.getProducts(page: page, pageSize: pageSize);

      if (data.length < pageSize) {
        hasMore = false;
      }

      products.addAll(data);
      page++;
    } catch (e) {
      debugPrint("Load products error: $e");
    }

    loading = false;
    isFetching = false;

    notifyListeners();
  }

  /// =========================
  /// CREATE PRODUCT
  /// =========================
  Future<void> createProduct({
    required Map<String, dynamic> dto,
    required List<String> imagePaths,
  }) async {
    try {
      loading = true;
      notifyListeners();

      /// 1. CREATE PRODUCT
      final productId = await repo.createProduct(dto);

      /// 2. UPLOAD IMAGES
      for (var path in imagePaths) {
        await repo.uploadImage(productId, path);
      }

      /// 3. RELOAD LIST
      await loadProducts(refresh: true);
    } catch (e) {
      debugPrint("Create product error: $e");
    }

    loading = false;
    notifyListeners();
  }

  /// =========================
  /// UPDATE PRODUCT
  /// =========================
  Future<void> updateProduct({
    required int id,
    required Map<String, dynamic> dto,
  }) async {
    try {
      loading = true;
      notifyListeners();

      await repo.updateProduct(id, dto);

      await loadProducts(refresh: true);
    } catch (e) {
      debugPrint("Update product error: $e");
    }

    loading = false;
    notifyListeners();
  }

  /// =========================
  /// DELETE PRODUCT
  /// =========================
  Future<void> deleteProduct(int id) async {
    await repo.deleteProduct(id);
    await loadProducts(refresh: true);
  }

  /// =========================
  /// LOAD MORE (SCROLL)
  /// =========================
  void loadMore() {
    if (loading || isFetching || !hasMore) return;

    loadProducts();
  }
}
