import 'package:flutter/material.dart';

import '../../../../repositories/interfaces/i_product_admin_repository.dart';
import '../../models/admin_product_model.dart';
import '../models/admin_product_variant.dart';

class ProductAdminProvider extends ChangeNotifier {
  final IProductAdminRepository repo;

  ProductAdminProvider(this.repo);

  List<AdminProduct> products = [];
  List<AdminProductVariant> variants = [];

  int page = 1;
  final int pageSize = 10;

  bool loading = false;
  bool isFetching = false;
  bool hasMore = true;

  /// Tai du lieu can thiet cho loadProducts.
  Future<void> loadProducts({bool refresh = false}) async {
    if (isFetching) return;

    isFetching = true;
    final targetPage = refresh ? 1 : page;

    if (refresh) {
      hasMore = true;
    }

    if (products.isEmpty) {
      loading = true;
      notifyListeners();
    }

    try {
      final data = await repo.getProducts(page: targetPage, pageSize: pageSize);

      if (refresh) {
        products = data;
        page = 2;
      } else {
        products.addAll(data);
        page++;
      }

      hasMore = data.length >= pageSize;
    } catch (e) {
      debugPrint("Load products error: $e");
    }

    loading = false;
    isFetching = false;
    notifyListeners();
  }

  /// Tao moi du lieu thong qua createProduct.
  Future<void> createProduct({
    required Map<String, dynamic> dto,
    required List<String> imagePaths,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final productId = await repo.createProduct(dto);

      for (final path in imagePaths) {
        await repo.uploadImage(productId, path);
      }

      await loadProducts(refresh: true);
    } catch (e) {
      debugPrint("Create product error: $e");
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Cap nhat du lieu thong qua updateProduct.
  Future<void> updateProduct({
    required int id,
    required Map<String, dynamic> dto,
    required List<String> imagePaths,
  }) async {
    loading = true;
    notifyListeners();

    try {
      await repo.updateProduct(id, dto);

      for (final path in imagePaths) {
        await repo.uploadImage(id, path);
      }

      await loadProducts(refresh: true);
    } catch (e) {
      debugPrint("Update product error: $e");
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Xoa du lieu thong qua deleteProduct.
  Future<void> deleteProduct(int id) async {
    try {
      await repo.deleteProduct(id);
      await loadProducts(refresh: true);
    } catch (e) {
      debugPrint("Delete product error: $e");
      rethrow;
    }
  }

  /// Tai du lieu can thiet cho loadMore.
  void loadMore() {
    if (loading || isFetching || !hasMore) return;
    loadProducts();
  }

  /// Tai du lieu can thiet cho loadVariants.
  Future<void> loadVariants(int productId) async {
    loading = true;
    notifyListeners();

    try {
      variants = await repo.getVariants(productId);
    } catch (e) {
      debugPrint("Load variants error: $e");
      variants = [];
    }

    loading = false;
    notifyListeners();
  }

  /// Luu du lieu tu form hoac state hien tai.
  Future<void> saveVariant({
    required int productId,
    AdminProductVariant? variant,
    required Map<String, dynamic> data,
  }) async {
    loading = true;
    notifyListeners();

    try {
      if (variant == null) {
        await repo.createVariant(productId, data);
      } else {
        await repo.updateVariant(productId, variant.id, data);
      }

      variants = await repo.getVariants(productId);
    } catch (e) {
      debugPrint("Save variant error: $e");
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Xoa du lieu thong qua deleteVariant.
  Future<void> deleteVariant(int productId, int variantId) async {
    loading = true;
    notifyListeners();

    try {
      await repo.deleteVariant(productId, variantId);
      variants = await repo.getVariants(productId);
    } catch (e) {
      debugPrint("Delete variant error: $e");
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
