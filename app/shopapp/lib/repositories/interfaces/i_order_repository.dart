import '../../models/order_model.dart';

abstract class IOrderRepository {
  Future<List<OrderModel>> getOrdersByStatus({
    required int userId,
    required String status,
  });
}
