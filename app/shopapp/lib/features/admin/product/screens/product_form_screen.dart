import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../category/providers/category_provider.dart';
import '../../models/admin_product_model.dart';
import '../providers/product_admin_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final AdminProduct? product;

  const ProductFormScreen({super.key, this.product});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  int? selectedCategoryId;

  final ImagePicker picker = ImagePicker();
  final List<String> images = [];

  final Color primary = const Color(0xFF4F46E5);

  bool get isEdit => widget.product != null;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<CategoryProvider>().loadCategories();

      if (!mounted) return;

      if (isEdit) {
        _loadEditData();
      }
    });
  }

  /// Xu ly logic cho ham _isNetwork.
  bool _isNetwork(String path) {
    return path.startsWith("http");
  }

  /// Xu ly logic cho ham _buildImageUrl.
  String _buildImageUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${AppConfig.apiUrl}/$path";
  }

  /// Tai du lieu can thiet cho _loadEditData.
  void _loadEditData() {
    final p = widget.product!;

    nameCtrl.text = p.name;
    brandCtrl.text = p.brand ?? "";
    descCtrl.text = p.description ?? "";
    selectedCategoryId = p.categoryId;

    final imageUrl =
        (p.image != null && p.image!.isNotEmpty)
            ? _buildImageUrl(p.image!)
            : null;

    if (imageUrl != null) {
      images.add(imageUrl);
    }

    setState(() {});
  }

  /// Xu ly logic cho ham _pickFromCamera.
  Future<void> _pickFromCamera() async {
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    setState(() {
      images.add(file.path);
    });
  }

  /// Xu ly logic cho ham _pickFromGallery.
  Future<void> _pickFromGallery() async {
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    setState(() {
      images.addAll(files.map((file) => file.path));
    });
  }

  /// Xu ly logic cho ham _showImageSourceSheet.
  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text("Chụp ảnh"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text("Chọn từ file/thư viện"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Xu ly logic cho ham _buildImage.
  Widget _buildImage(String path) {
    final isNetwork = _isNetwork(path);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              isNetwork
                  ? Image.network(
                    path,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                  : Image.file(
                    File(path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
        ),
        if (!isNetwork)
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () {
                setState(() {
                  images.remove(path);
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  /// Xu ly logic cho ham _submit.
  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên sản phẩm")),
      );
      return;
    }

    final provider = context.read<ProductAdminProvider>();
    final dto = {
      "name": name,
      "description": descCtrl.text.trim(),
      "brand": brandCtrl.text.trim(),
      "categoryId": selectedCategoryId,
    };

    final localImages = images.where((path) => !_isNetwork(path)).toList();

    try {
      if (isEdit) {
        await provider.updateProduct(
          id: widget.product!.id,
          dto: dto,
          imagePaths: localImages,
        );
      } else {
        await provider.createProduct(dto: dto, imagePaths: localImages);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Cập nhật sản phẩm thành công"
                : "Thêm sản phẩm thành công",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Cập nhật sản phẩm thất bại: $e"
                : "Thêm sản phẩm thất bại: $e",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Xu ly logic cho ham _input.
  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// Giai phong controller, listener va tai nguyen khi widget bi huy.
  @override
  void dispose() {
    nameCtrl.dispose();
    brandCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductAdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(isEdit ? "Sửa sản phẩm" : "Thêm sản phẩm"),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildInfoSection(categoryProvider),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: productProvider.loading ? null : _submit,
                child:
                    productProvider.loading
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text("Lưu sản phẩm"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xu ly logic cho ham _buildImageSection.
  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hình ảnh sản phẩm",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...images.map(
                  (path) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildImage(path),
                  ),
                ),
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xu ly logic cho ham _buildInfoSection.
  Widget _buildInfoSection(CategoryProvider categoryProvider) {
    final categories = categoryProvider.flatCategories;
    final selectedExists = categories.any((c) => c.id == selectedCategoryId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(controller: nameCtrl, decoration: _input("Tên sản phẩm")),
          const SizedBox(height: 10),
          TextField(controller: brandCtrl, decoration: _input("Thương hiệu")),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: selectedExists ? selectedCategoryId : null,
            decoration: _input("Danh mục"),
            items:
                categories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: _input("Mô tả"),
          ),
        ],
      ),
    );
  }
}
