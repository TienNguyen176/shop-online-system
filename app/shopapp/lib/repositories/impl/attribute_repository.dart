import '../../models/attribute_model.dart';
import '../../services/attribute_service.dart';
import '../interfaces/i_attribute_repository.dart';

class AttributeRepository implements IAttributeRepository {
  final AttributeService service = AttributeService();

  /// CACHE
  List<AttributeModel>? _attributesCache;

  /// GET ALL ATTRIBUTES
  @override
  Future<List<AttributeModel>> getAttributes() async {
    if (_attributesCache != null) {
      return _attributesCache!;
    }

    final data = await service.getAttributes();

    _attributesCache = data;

    return _attributesCache!;
  }

  /// REFRESH CACHE (optional but recommended)
  Future<List<AttributeModel>> refreshAttributes() async {
    final data = await service.getAttributes();
    _attributesCache = data;
    return _attributesCache!;
  }

  /// CLEAR CACHE (use when admin updates attributes)
  void clearCache() {
    _attributesCache = null;
  }
}
