import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../interfaces/i_order_repository.dart';

class OrderRepository implements IOrderRepository {
  final OrderService service = OrderService();

  @override
  Future<List<OrderModel>> getOrdersByStatus({
    required int userId,
    required String status,
  }) async {
    return service.getOrdersByStatus(userId: userId, status: status);
  }
}
