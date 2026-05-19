import 'package:flutter/material.dart';

import '../../models/admin_product_model.dart';
import '../../../../repositories/interfaces/i_product_admin_repository.dart';

/// Provider quản lý danh sách sản phẩm ở khu vực admin.
class ProductAdminProvider extends ChangeNotifier {
  final IProductAdminRepository repo;

  ProductAdminProvider(this.repo);

  /// Danh sách sản phẩm admin đang hiển thị.
  List<AdminProduct> products = [];

  /// Thông tin phân trang khi tải danh sách sản phẩm.
  int page = 1;
  final int pageSize = 10;

  /// Các cờ trạng thái giúp UI hiển thị loading và chặn gọi API trùng.
  bool loading = false;
  bool isFetching = false;
  bool hasMore = true;

  /// Tải sản phẩm theo trang, có thể refresh để quay về trang đầu.
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

  /// Tạo sản phẩm mới, upload ảnh đi kèm rồi tải lại danh sách.
  Future<void> createProduct({
    required Map<String, dynamic> dto,
    required List<String> imagePaths,
  }) async {
    try {
      loading = true;
      notifyListeners();

      /// Tạo sản phẩm trước để lấy id phục vụ upload ảnh.
      final productId = await repo.createProduct(dto);

      /// Upload từng ảnh đã chọn cho sản phẩm vừa tạo.
      for (var path in imagePaths) {
        await repo.uploadImage(productId, path);
      }

      /// Tải lại danh sách để admin thấy sản phẩm mới.
      await loadProducts(refresh: true);
    } catch (e) {
      debugPrint("Create product error: $e");
    }

    loading = false;
    notifyListeners();
  }

  /// Cập nhật thông tin sản phẩm và refresh danh sách sau khi lưu.
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

  /// Xóa sản phẩm theo id rồi tải lại danh sách admin.
  Future<void> deleteProduct(int id) async {
    await repo.deleteProduct(id);
    await loadProducts(refresh: true);
  }

  /// Tải thêm sản phẩm khi cuộn xuống cuối danh sách.
  void loadMore() {
    if (loading || isFetching || !hasMore) return;

    loadProducts();
  }
}
