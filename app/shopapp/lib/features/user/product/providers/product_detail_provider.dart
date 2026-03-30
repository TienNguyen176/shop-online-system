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

    Map<String, String> defaultSelected = {};
    for (var attr in data.attributes) {
      if (attr.values.isNotEmpty) {
        defaultSelected[attr.name] = attr.values.first;
      }
    }

    product = data;
    selectedAttributes = defaultSelected;
    loading = false;

    notifyListeners();
  }

  void select(String key, String value) {
    selectedAttributes[key] = value;
    notifyListeners();
  }

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
    } catch (e) {
      return null;
    }
  }
}