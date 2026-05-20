import '../../models/attribute_model.dart';

abstract class IAttributeRepository {
  /// Lay du lieu cho getAttributes.
  Future<List<AttributeModel>> getAttributes();

  /// Tao moi du lieu thong qua createAttribute.
  Future<AttributeModel> createAttribute(Map<String, dynamic> data);

  /// Cap nhat du lieu thong qua updateAttribute.
  Future<AttributeModel> updateAttribute(int id, Map<String, dynamic> data);

  /// Xoa du lieu thong qua deleteAttribute.
  Future<void> deleteAttribute(int id);

  /// Xoa du lieu cache hien co.
  void clearCache();
}
