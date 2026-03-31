import 'package:flutter/material.dart';

import '../../../../models/attribute_model.dart';
import '../../../../repositories/interfaces/i_attribute_repository.dart';

class AttributeProvider with ChangeNotifier {
  final IAttributeRepository repository;

  AttributeProvider(this.repository);

  List<AttributeModel> _attributes = [];
  List<AttributeModel> get attributes => _attributes;

  bool isLoading = false;

  Future<void> loadAttributes() async {
    isLoading = true;
    notifyListeners();

    try {
      _attributes = await repository.getAttributes();
    } catch (e) {
      debugPrint("Load attributes error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
