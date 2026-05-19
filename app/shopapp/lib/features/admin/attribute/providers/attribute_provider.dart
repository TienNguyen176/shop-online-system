import 'package:flutter/material.dart';

import '../../../../models/attribute_model.dart';
import '../../../../repositories/interfaces/i_attribute_repository.dart';

class AttributeProvider with ChangeNotifier {
  final IAttributeRepository repository;

  AttributeProvider(this.repository);

  List<AttributeModel> _attributes = [];
  List<AttributeModel> get attributes => _attributes;

  bool isLoading = false;
  String? error;

  Future<void> loadAttributes({bool refresh = false}) async {
    if (!refresh && _attributes.isNotEmpty) return;
    if (refresh) repository.clearCache();

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _attributes = await repository.getAttributes();
    } catch (e) {
      error = e.toString();
      debugPrint("Load attributes error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveAttribute({
    AttributeModel? attribute,
    required String name,
    required List<String> values,
  }) async {
    final data = {
      "name": name,
      "values": values,
    };

    if (attribute == null) {
      await repository.createAttribute(data);
    } else {
      await repository.updateAttribute(attribute.id, data);
    }

    await loadAttributes(refresh: true);
  }

  Future<void> deleteAttribute(int id) async {
    await repository.deleteAttribute(id);
    await loadAttributes(refresh: true);
  }
}
