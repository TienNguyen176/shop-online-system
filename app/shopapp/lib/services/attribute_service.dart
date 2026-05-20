import '../core/api/api_client.dart';

import '../../models/attribute_model.dart';

class AttributeService {
  /// Lay du lieu cho getAttributes.
  Future<List<AttributeModel>> getAttributes() async {
    final res = await ApiClient.dio.get("/api/attributes");

    final List data = res.data;

    return data.map((e) => AttributeModel.fromJson(e)).toList();
  }

  /// Tao moi du lieu thong qua createAttribute.
  Future<AttributeModel> createAttribute(Map<String, dynamic> data) async {
    final res = await ApiClient.dio.post("/api/attributes", data: data);
    return AttributeModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Cap nhat du lieu thong qua updateAttribute.
  Future<AttributeModel> updateAttribute(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await ApiClient.dio.put("/api/attributes/$id", data: data);
    return AttributeModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Xoa du lieu thong qua deleteAttribute.
  Future<void> deleteAttribute(int id) async {
    await ApiClient.dio.delete("/api/attributes/$id");
  }
}
