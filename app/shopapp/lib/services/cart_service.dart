import '../core/api/api_client.dart';
import '../models/cart_item.dart';

class CartService {
  /// ADD TO CART
  Future<void> addToCart({
    required int userId,
    required int productId,
    required int variantId,
    int quantity = 1,
  }) async {
    await ApiClient.dio.post(
      "/api/cart/add",
      data: {
        "userId": userId,
        "productId": productId,
        "variantId": variantId,
        "quantity": quantity,
      },
    );
  }

  /// GET CART
  Future<List<CartItem>> getCart(int userId) async {
    final res = await ApiClient.dio.get("/api/cart/$userId");

    final data = res.data;

    final List raw = data is List ? data : data["data"] ?? [];

    return raw.map((e) => CartItem.fromJson(e)).toList();
  }

  /// UPDATE QUANTITY
  Future<void> updateQuantity(int itemId, int quantity) async {
    await ApiClient.dio.put(
      "/api/cart/update/$itemId",
      data: {"quantity": quantity},
    );
  }

  /// DELETE ITEM
  Future<void> deleteItem(int itemId) async {
    await ApiClient.dio.delete("/api/cart/delete/$itemId");
  }
}
