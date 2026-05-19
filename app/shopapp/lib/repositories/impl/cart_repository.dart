import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../interfaces/i_cart_repository.dart';

class CartRepository implements ICartRepository {
  final CartService service = CartService();

  /// CACHE theo user
  final Map<int, List<CartItem>> _cartCache = {};

  @override
  Future<void> addToCart({
    required int userId,
    required int productId,
    required int variantId,
    int quantity = 1,
  }) async {
    await service.addToCart(
      userId: userId,
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );

    /// clear cache để reload
    _cartCache.remove(userId);
  }

  @override
  Future<List<CartItem>> getCart(int userId, {bool forceRefresh = false}) async {
    /// dùng cache nếu có
    if (!forceRefresh && _cartCache.containsKey(userId)) {
      return _cartCache[userId]!;
    }

    final data = await service.getCart(userId);

    _cartCache[userId] = data;

    return data;
  }

  @override
  Future<void> updateQuantity(int itemId, int quantity) async {
    await service.updateQuantity(itemId, quantity);

    /// clear toàn bộ cache (hoặc optimize sau)
    _cartCache.clear();
  }

  @override
  Future<void> deleteItem(int itemId) async {
    await service.deleteItem(itemId);

    _cartCache.clear();
  }
}
