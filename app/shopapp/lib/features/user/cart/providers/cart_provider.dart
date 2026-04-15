import 'package:flutter/material.dart';
import '../../../../models/cart_item.dart';
import '../../../../repositories/interfaces/i_cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final ICartRepository repo;

  CartProvider(this.repo);

  /// ================= STATE =================

  List<CartItem> _items = [];
  final Set<int> _selectedIds = {};

  bool _loading = false;
  String? _error;

  int _userId = 0;

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// ================= GETTER =================

  List<CartItem> get items => _items;

  bool get loading => _loading;

  String? get error => _error;

  Set<int> get selectedIds => _selectedIds;

  List<CartItem> get selectedItems =>
      _items.where((e) => _selectedIds.contains(e.id)).toList();

  double get totalPrice {
    return selectedItems.fold(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  int get totalQuantity {
    return selectedItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// ================= CORE =================

  Future<void> loadCart(int userId) async {
    _userId = userId;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await repo.getCart(userId);

      /// mặc định select all
      _selectedIds
        ..clear()
        ..addAll(_items.map((e) => e.id));
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// ================= SELECT =================

  void toggleSelect(int itemId) {
    if (_selectedIds.contains(itemId)) {
      _selectedIds.remove(itemId);
    } else {
      _selectedIds.add(itemId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds
      ..clear()
      ..addAll(_items.map((e) => e.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// ================= ADD =================

  Future<void> addToCart({
    required int productId,
    required int variantId,
    int quantity = 1,
  }) async {
    try {
      await repo.addToCart(
        userId: _userId,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      );

      await loadCart(_userId);

      /// AUTO SELECT NEW ITEMS
      _selectedIds.addAll(_items.map((e) => e.id));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ================= UPDATE =================

  Future<void> updateQuantity(int itemId, int quantity) async {
    final index = _items.indexWhere((e) => e.id == itemId);
    if (index == -1) return;

    final oldItem = _items[index];

    _items[index] = CartItem(
      id: oldItem.id,

      productId: oldItem.productId,
      variantId: oldItem.variantId,

      name: oldItem.name,
      variantName: oldItem.variantName,

      price: oldItem.price,
      image: oldItem.image,
      rating: oldItem.rating,

      quantity: quantity,
    );

    notifyListeners();

    try {
      await repo.updateQuantity(itemId, quantity);
    } catch (e) {
      _items[index] = oldItem;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ================= DELETE =================

  Future<void> deleteItem(int itemId) async {
    final index = _items.indexWhere((e) => e.id == itemId);
    if (index == -1) return;

    final removedItem = _items[index];

    /// optimistic
    _items.removeAt(index);
    _selectedIds.remove(itemId);

    notifyListeners();

    try {
      await repo.deleteItem(itemId);
    } catch (e) {
      /// rollback
      _items.insert(index, removedItem);
      _selectedIds.add(itemId);
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ================= UTIL =================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Lấy danh sách sản phẩm đã chọn để thanh toán
  List<CartItem> getCheckoutItems() {
    return _items.where((e) => _selectedIds.contains(e.id)).toList();
  }
}
