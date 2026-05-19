import '../core/api/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  Future<List<OrderModel>> getOrdersByStatus({
    required int userId,
    required String status,
  }) async {
    final res = await ApiClient.dio.get(
      "/api/order/user/$userId/status/$status",
    );

    final data = res.data;
    final List raw = data is List ? data : data["data"] ?? [];

    return raw.map((e) => OrderModel.fromJson(e)).toList();
  }
}
