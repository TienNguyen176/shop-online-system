import '../../models/order_model.dart';

abstract class IOrderRepository {
  /// Lay du lieu cho getOrdersByStatus.
  Future<List<OrderModel>> getOrdersByStatus({
    required int userId,
    required String status,
  });
}
