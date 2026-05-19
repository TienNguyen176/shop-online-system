import 'package:flutter/material.dart';

import '../../../../models/product_detail.dart';
import '../../../../models/product_variant.dart';
import '../../../../repositories/interfaces/i_product_repository.dart';

/// Provider quản lý dữ liệu và lựa chọn biến thể trong màn hình chi tiết sản phẩm.
class ProductDetailProvider extends ChangeNotifier {
  final IProductRepository repo;

  ProductDetailProvider(this.repo);

  /// Thông tin chi tiết sản phẩm hiện tại.
  ProductDetail? product;

  /// Cờ loading khi tải chi tiết sản phẩm.
  bool loading = true;

  /// Các thuộc tính người dùng đang chọn, ví dụ màu sắc hoặc kích thước.
  Map<String, String> selectedAttributes = {};

  /// Tải chi tiết sản phẩm và tự chọn biến thể còn hàng đầu tiên làm mặc định.
  Future<void> load(int productId) async {
    loading = true;
    notifyListeners();

    final data = await repo.getProductDetail(productId);

    product = data;

    /// Chọn variant mặc định để màn hình có giá, kho và thuộc tính ban đầu.
    if (data.variants.isNotEmpty) {
      final defaultVariant = data.variants.firstWhere(
        (v) => v.stockQuantity > 0,
        orElse: () => data.variants.first,
      );

      /// Lấy bộ thuộc tính từ variant mặc định.
      selectedAttributes = Map.from(defaultVariant.attributes);
    } else {
      selectedAttributes = {};
    }

    loading = false;
    notifyListeners();
  }

  /// Cập nhật một thuộc tính khi người dùng chọn option trên UI.
  void select(String key, String value) {
    selectedAttributes[key] = value;
    notifyListeners();
  }

  /// Tìm biến thể khớp với toàn bộ thuộc tính đang chọn.
  ProductVariant? get selectedVariant {
    if (product == null) return null;

    try {
      return product!.variants.firstWhere((v) {
        for (var key in selectedAttributes.keys) {
          if (v.attributes[key] != selectedAttributes[key]) {
            return false;
          }
        }
        return true;
      });
    } catch (_) {
      return null;
    }
  }
}
