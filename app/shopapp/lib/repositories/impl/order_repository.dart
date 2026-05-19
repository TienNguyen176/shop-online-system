import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../interfaces/i_order_repository.dart';

class OrderRepository implements IOrderRepository {
  final OrderService service = OrderService();

  final Map<String, List<OrderModel>> _orderCache = {};

  @override
  Future<List<OrderModel>> getOrdersByStatus({
    required int userId,
    required String status,
  }) async {
    final key = "$userId:$status";

    if (_orderCache.containsKey(key)) {
      return _orderCache[key]!;
    }

    final data = await service.getOrdersByStatus(
      userId: userId,
      status: status,
    );

    _orderCache[key] = data;

    return data;
  }

  void clearCache() {
    _orderCache.clear();
  }
}
