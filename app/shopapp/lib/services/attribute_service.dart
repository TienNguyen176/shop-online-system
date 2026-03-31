import '../core/api/api_client.dart';

import '../../models/attribute_model.dart';

class AttributeService {
  Future<List<AttributeModel>> getAttributes() async {
    final res = await ApiClient.dio.get("/api/attributes");

    final List data = res.data;

    return data.map((e) => AttributeModel.fromJson(e)).toList();
  }
}
