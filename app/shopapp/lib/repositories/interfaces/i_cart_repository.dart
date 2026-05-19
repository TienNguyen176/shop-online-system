import '../../models/cart_item.dart';

abstract class ICartRepository {
  Future<void> addToCart({
    required int userId,
    required int productId,
    required int variantId,
    int quantity,
  });

  Future<List<CartItem>> getCart(int userId, {bool forceRefresh = false});

  Future<void> updateQuantity(int itemId, int quantity);

  Future<void> deleteItem(int itemId);
}
