import '../../models/cart_item.dart';

abstract class ICartRepository {
  /// Them du lieu moi vao danh sach hoac gio hang.
  Future<void> addToCart({
    required int userId,
    required int productId,
    required int variantId,
    int quantity,
  });

  /// Lay du lieu cho getCart.
  Future<List<CartItem>> getCart(int userId, {bool forceRefresh = false});

  /// Cap nhat du lieu thong qua updateQuantity.
  Future<void> updateQuantity(int itemId, int quantity);

  /// Xoa du lieu thong qua deleteItem.
  Future<void> deleteItem(int itemId);
}
