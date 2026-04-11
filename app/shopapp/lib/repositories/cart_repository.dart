import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CartRepository {

  Future<void> addToCart({
    required int productId,
    required int variantId,
    int quantity = 1,
  }) async {
    final url = Uri.parse("${AppConfig.apiUrl}/api/cart/add");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId":    1,
        "productId": productId,
        "variantId": variantId,
        "quantity":  quantity,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Add to cart failed: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> getCart(int userId) async {
    final url = Uri.parse("${AppConfig.apiUrl}/api/cart/$userId");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("Load cart failed: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    final List raw;
    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map && decoded["data"] is List) {
      raw = decoded["data"] as List;
    } else {
      return [];
    }

    return raw.map<Map<String, dynamic>>((item) {
      return {
        "id":       _safeInt(item["id"]),
        "name":     _safeString(item["name"]),
        "price":    _safeDouble(item["price"]),
        "image":    _safeString(item["image"]),
        "rating":   _safeDouble(item["rating"]),
        "quantity": _safeInt(item["quantity"]),
      };
    }).toList();
  }

  // ✅ Update quantity
  Future<void> updateQuantity(int itemId, int quantity) async {
    final url = Uri.parse("${AppConfig.apiUrl}/api/cart/update/$itemId");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"quantity": quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception("Update failed: ${response.body}");
    }
  }

  // ✅ Delete item
  Future<void> deleteItem(int itemId) async {
    final url = Uri.parse("${AppConfig.apiUrl}/api/cart/delete/$itemId");
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception("Delete failed: ${response.body}");
    }
  }

  int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _safeString(dynamic v) {
    if (v == null) return "";
    return v.toString().trim();
  }
}