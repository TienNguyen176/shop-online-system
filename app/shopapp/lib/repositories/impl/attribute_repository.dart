import '../../models/attribute_model.dart';
import '../../services/attribute_service.dart';
import '../interfaces/i_attribute_repository.dart';

class AttributeRepository implements IAttributeRepository {
  final AttributeService service = AttributeService();

  List<AttributeModel>? _attributesCache;

  @override
  Future<List<AttributeModel>> getAttributes() async {
    if (_attributesCache != null) {
      return _attributesCache!;
    }

    final data = await service.getAttributes();
    _attributesCache = data;
    return _attributesCache!;
  }

  Future<List<AttributeModel>> refreshAttributes() async {
    final data = await service.getAttributes();
    _attributesCache = data;
    return _attributesCache!;
  }

  @override
  Future<AttributeModel> createAttribute(Map<String, dynamic> data) async {
    final created = await service.createAttribute(data);
    clearCache();
    return created;
  }

  @override
  Future<AttributeModel> updateAttribute(
    int id,
    Map<String, dynamic> data,
  ) async {
    final updated = await service.updateAttribute(id, data);
    clearCache();
    return updated;
  }

  @override
  Future<void> deleteAttribute(int id) async {
    await service.deleteAttribute(id);
    clearCache();
  }

  @override
  void clearCache() {
    _attributesCache = null;
  }
}
