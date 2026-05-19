import 'package:flutter/material.dart';

import '../../../../models/attribute_model.dart';
import '../../../../repositories/interfaces/i_attribute_repository.dart';

/// Provider quản lý danh sách thuộc tính sản phẩm trong trang admin.
class AttributeProvider with ChangeNotifier {
  final IAttributeRepository repository;

  AttributeProvider(this.repository);

  /// Danh sách thuộc tính lấy từ backend.
  List<AttributeModel> _attributes = [];
  List<AttributeModel> get attributes => _attributes;

  /// Cờ loading để màn hình biết khi nào cần hiển thị trạng thái chờ.
  bool isLoading = false;

  /// Tải toàn bộ thuộc tính sản phẩm để dùng khi tạo hoặc sửa sản phẩm.
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
