import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../features/user/profile/models/user_address.dart';
import '../models/order_detail.dart';
import '../models/order_model.dart';

class OrderService {
  /// Lay du lieu cho getOrdersByStatus.
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

  /// Lay du lieu cho getOrderDetail.
  Future<OrderDetail> getOrderDetail(int orderId) async {
    final res = await ApiClient.dio.get("/api/order/$orderId");
    return OrderDetail.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Cap nhat du lieu thong qua updateShippingAddress.
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

  /// Xoa du lieu thong qua deleteOrder.
  Future<void> deleteOrder(int orderId) async {
    try {
      await ApiClient.dio.delete("/api/order/$orderId");
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  /// Tao moi du lieu thong qua createReturnRequest.
  Future<void> createReturnRequest({
    required int orderId,
    required String reason,
  }) async {
    try {
      await ApiClient.dio.post(
        "/api/order/$orderId/return-request",
        data: {"reason": reason},
      );
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  /// Xu ly logic cho ham _errorMessage.
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
