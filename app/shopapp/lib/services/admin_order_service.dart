import '../core/api/api_client.dart';
import '../features/admin/order/models/admin_order_model.dart';
import '../features/admin/order/models/admin_return_request_model.dart';

class AdminOrderService {
  /// Lay du lieu cho getOrders.
  Future<List<AdminOrderModel>> getOrders({String? status}) async {
    final res = await ApiClient.dio.get(
      "/api/admin/orders",
      queryParameters: {
        if (status != null && status.isNotEmpty) "status": status,
      },
    );

    final data = res.data;
    final List raw = data is List ? data : data["data"] ?? [];
    return raw
        .map((e) => AdminOrderModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Cap nhat du lieu thong qua updateStatus.
  Future<AdminOrderModel> updateStatus({
    required int orderId,
    required String status,
  }) async {
    final res = await ApiClient.dio.put(
      "/api/admin/orders/$orderId/status",
      data: {"status": status},
    );

    return AdminOrderModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Lay du lieu cho getReturnRequests.
  Future<List<AdminReturnRequestModel>> getReturnRequests({
    String? status,
  }) async {
    final res = await ApiClient.dio.get(
      "/api/admin/orders/return-requests",
      queryParameters: {
        if (status != null && status.isNotEmpty) "status": status,
      },
    );

    final data = res.data;
    final List raw = data is List ? data : data["data"] ?? [];
    return raw
        .map(
          (e) => AdminReturnRequestModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  /// Cap nhat du lieu thong qua updateReturnRequestStatus.
  Future<AdminReturnRequestModel> updateReturnRequestStatus({
    required int requestId,
    required String status,
  }) async {
    final res = await ApiClient.dio.put(
      "/api/admin/orders/return-requests/$requestId/status",
      data: {"status": status},
    );

    return AdminReturnRequestModel.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }
}
