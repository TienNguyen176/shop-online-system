import '../core/api/api_client.dart';

import '../../models/attribute_model.dart';

class AttributeService {
  Future<List<AttributeModel>> getAttributes() async {
    final res = await ApiClient.dio.get("/api/attributes");

    final List data = res.data;

    return data.map((e) => AttributeModel.fromJson(e)).toList();
  }

  Future<AttributeModel> createAttribute(Map<String, dynamic> data) async {
    final res = await ApiClient.dio.post("/api/attributes", data: data);
    return AttributeModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<AttributeModel> updateAttribute(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await ApiClient.dio.put("/api/attributes/$id", data: data);
    return AttributeModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteAttribute(int id) async {
    await ApiClient.dio.delete("/api/attributes/$id");
  }
}
