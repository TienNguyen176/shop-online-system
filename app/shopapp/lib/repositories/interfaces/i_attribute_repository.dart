import '../../models/attribute_model.dart';

abstract class IAttributeRepository {
  Future<List<AttributeModel>> getAttributes();

  Future<AttributeModel> createAttribute(Map<String, dynamic> data);

  Future<AttributeModel> updateAttribute(int id, Map<String, dynamic> data);

  Future<void> deleteAttribute(int id);

  void clearCache();
}
