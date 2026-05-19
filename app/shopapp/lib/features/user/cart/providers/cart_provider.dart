import 'package:flutter/material.dart';
import '../../../../models/cart_item.dart';
import '../../../../repositories/interfaces/i_cart_repository.dart';

/// Provider quản lý trạng thái giỏ hàng: danh sách item, chọn item, tổng tiền và thao tác CRUD.
class CartProvider extends ChangeNotifier {
  final ICartRepository repo;

  CartProvider(this.repo);

  /// Danh sách sản phẩm trong giỏ hàng.
  List<CartItem> _items = [];

  /// Tập id của các item đang được chọn để thanh toán.
  final Set<int> _selectedIds = {};

  /// Trạng thái tải dữ liệu và lỗi hiện tại của giỏ hàng.
  bool _loading = false;
  String? _error;

  /// User hiện tại và cờ cache để tránh tải lại giỏ hàng không cần thiết.
  int _userId = 0;
  bool _hasLoaded = false;

  /// Tổng số lượng sản phẩm trong giỏ hàng, dùng cho badge giỏ hàng.
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  List<CartItem> get items => _items;

  bool get loading => _loading;

  String? get error => _error;

  Set<int> get selectedIds => _selectedIds;

  /// Danh sách item đang được chọn.
  List<CartItem> get selectedItems =>
      _items.where((e) => _selectedIds.contains(e.id)).toList();

  /// Tổng tiền của các sản phẩm đang được chọn để thanh toán.
  double get totalPrice {
    return selectedItems.fold(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  /// Tổng số lượng của các sản phẩm đang được chọn.
  int get totalQuantity {
    return selectedItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Tải giỏ hàng theo userId, có thể ép tải lại bằng force.
  Future<void> loadCart(int userId, {bool force = false}) async {
    if (!force && _hasLoaded && _userId == userId) {
      return;
    }

    _userId = userId;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await repo.getCart(userId, forceRefresh: force);

      /// Mặc định chọn tất cả item sau khi tải giỏ hàng.
      _selectedIds
        ..clear()
        ..addAll(_items.map((e) => e.id));

      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Bật/tắt chọn một sản phẩm trong giỏ hàng.
  void toggleSelect(int itemId) {
    if (_selectedIds.contains(itemId)) {
      _selectedIds.remove(itemId);
    } else {
      _selectedIds.add(itemId);
    }
    notifyListeners();
  }

  /// Chọn tất cả sản phẩm trong giỏ.
  void selectAll() {
    _selectedIds
      ..clear()
      ..addAll(_items.map((e) => e.id));
    notifyListeners();
  }

  /// Bỏ chọn toàn bộ sản phẩm trong giỏ.
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Thêm sản phẩm vào giỏ và tải lại giỏ hàng sau khi thêm.
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

      await loadCart(_userId, force: true);

      /// Tự chọn các item hiện có để người dùng có thể thanh toán ngay.
      _selectedIds.addAll(_items.map((e) => e.id));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Cập nhật số lượng item theo kiểu optimistic update, lỗi thì rollback.
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

  /// Xóa item khỏi giỏ theo kiểu optimistic update, lỗi thì rollback.
  Future<void> deleteItem(int itemId) async {
    final index = _items.indexWhere((e) => e.id == itemId);
    if (index == -1) return;

    final removedItem = _items[index];

    /// Xóa trước trên UI để thao tác có cảm giác nhanh.
    _items.removeAt(index);
    _selectedIds.remove(itemId);

    notifyListeners();

    try {
      await repo.deleteItem(itemId);
    } catch (e) {
      /// Khôi phục lại item nếu API xóa thất bại.
      _items.insert(index, removedItem);
      _selectedIds.add(itemId);
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Xóa lỗi hiện tại để UI không tiếp tục hiển thị lỗi cũ.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Dọn toàn bộ dữ liệu giỏ hàng khi đăng xuất hoặc đổi user.
  void clearCart() {
    _items = [];
    _selectedIds.clear();
    _userId = 0;
    _hasLoaded = false;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  /// Lấy danh sách sản phẩm đã chọn để truyền sang màn thanh toán.
  List<CartItem> getCheckoutItems() {
    return _items.where((e) => _selectedIds.contains(e.id)).toList();
  }
}
