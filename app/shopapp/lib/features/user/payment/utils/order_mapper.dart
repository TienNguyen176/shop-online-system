import '../../../../models/cart_item.dart';
import '../../../../models/order_item.dart';

OrderItem mapCartItem(CartItem item) {
  return OrderItem(
    productId: item.productId,
    variantId: item.variantId,
    productName: item.name,
    variantName: item.variantName,
    quantity: item.quantity,
    price: item.price,
  );
}
