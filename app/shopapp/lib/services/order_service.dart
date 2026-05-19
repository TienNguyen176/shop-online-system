import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../features/user/profile/models/user_address.dart';
import '../models/order_detail.dart';
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

  Future<OrderDetail> getOrderDetail(int orderId) async {
    final res = await ApiClient.dio.get("/api/order/$orderId");
    return OrderDetail.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<OrderDetail> updateShippingAddress({
    required int orderId,
    required UserAddress address,
  }) async {
    final res = await ApiClient.dio.put(
      "/api/order/$orderId/shipping-address",
      data: address.toRequest(),
    );
    return OrderDetail.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      await ApiClient.dio.delete("/api/order/$orderId");
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(Object error) {
    if (error is! DioException) return error.toString();

    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map && data["message"] != null) {
      return "HTTP $statusCode: ${data["message"]}";
    }

    return statusCode == null ? error.toString() : "HTTP $statusCode";
  }
}
