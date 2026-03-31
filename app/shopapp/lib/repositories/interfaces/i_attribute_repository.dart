import '../../models/attribute_model.dart';

abstract class IAttributeRepository {
  Future<List<AttributeModel>> getAttributes();
}
