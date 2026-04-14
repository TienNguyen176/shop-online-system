import 'package:flutter/material.dart';

import '../../../../models/product_detail.dart';
import '../../../../models/product_variant.dart';
import '../../../../repositories/interfaces/i_product_repository.dart';

class ProductDetailProvider extends ChangeNotifier {
  final IProductRepository repo;

  ProductDetailProvider(this.repo);

  ProductDetail? product;
  bool loading = true;

  Map<String, String> selectedAttributes = {};

  Future<void> load(int productId) async {
    loading = true;
    notifyListeners();

    final data = await repo.getProductDetail(productId);

    product = data;

    /// Chọn variant mặc định
    if (data.variants.isNotEmpty) {
      final defaultVariant = data.variants.firstWhere(
        (v) => v.stockQuantity > 0,
        orElse: () => data.variants.first,
      );

      /// Derive attributes từ variant
      selectedAttributes = Map.from(defaultVariant.attributes);
    } else {
      selectedAttributes = {};
    }

    loading = false;
    notifyListeners();
  }

  /// Chọn attribute
  void select(String key, String value) {
    selectedAttributes[key] = value;
    notifyListeners();
  }

  /// Derive variant từ attributes
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
