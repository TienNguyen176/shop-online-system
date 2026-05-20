import 'dart:io';
import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../../features/admin/models/admin_product_model.dart';
import '../../features/admin/product/models/admin_product_variant.dart';

class ProductAdminService {
  final dio = ApiClient.dio;

  /// =========================
  /// GET PRODUCTS
  /// =========================
  Future<List<AdminProduct>> getProducts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await dio.get(
      "/api/admin/products",
      queryParameters: {"page": page, "pageSize": pageSize},
    );

    final List data = res.data['data'];

    return data.map((e) => AdminProduct.fromJson(e)).toList();
  }

  /// =========================
  /// CREATE PRODUCT
  /// =========================
  Future<int> createProduct(Map<String, dynamic> data) async {
    final res = await dio.post("/api/admin/products", data: data);

    return res.data['id'];
  }

  /// =========================
  /// UPDATE PRODUCT
  /// =========================
  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await dio.put("/api/admin/products/$id", data: data);
  }

  /// =========================
  /// DELETE PRODUCT
  /// =========================
  Future<void> deleteProduct(int id) async {
    await dio.delete("/api/admin/products/$id");
  }

  /// =========================
  /// UPLOAD IMAGE
  /// =========================
  Future<String> uploadImage(int productId, String filePath) async {
    final file = File(filePath);

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });

    final res = await dio.post(
      "/api/admin/products/$productId/upload-image",
      data: formData,
      options: Options(contentType: "multipart/form-data"),
    );

    return res.data['url'];
  }

  /// Lay du lieu cho getVariants.
  Future<List<AdminProductVariant>> getVariants(int productId) async {
    final res = await dio.get("/api/admin/products/$productId/variants");
    final List data = res.data;

    return data.map((e) => AdminProductVariant.fromJson(e)).toList();
  }

  /// Tao moi du lieu thong qua createVariant.
  Future<void> createVariant(int productId, Map<String, dynamic> data) async {
    await dio.post("/api/admin/products/$productId/variants", data: data);
  }

  /// Cap nhat du lieu thong qua updateVariant.
  Future<void> updateVariant(
    int productId,
    int variantId,
    Map<String, dynamic> data,
  ) async {
    await dio.put(
      "/api/admin/products/$productId/variants/$variantId",
      data: data,
    );
  }

  /// Xoa du lieu thong qua deleteVariant.
  Future<void> deleteVariant(int productId, int variantId) async {
    await dio.delete("/api/admin/products/$productId/variants/$variantId");
  }
}
