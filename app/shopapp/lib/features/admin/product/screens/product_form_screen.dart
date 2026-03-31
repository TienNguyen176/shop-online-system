import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../models/admin_product_model.dart';
import '../../category/providers/category_provider.dart';
import '../providers/product_admin_provider.dart';
import '../../attribute/providers/attribute_provider.dart';

class AttributeRow {
  int? attributeId;
  String? attributeName;
  String? value;

  AttributeRow({this.attributeId, this.attributeName, this.value});
}

class ProductFormScreen extends StatefulWidget {
  final AdminProduct? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  int? selectedCategoryId;

  final ImagePicker picker = ImagePicker();
  List<String> images = [];

  List<AttributeRow> attributeRows = [];

  final Color primary = const Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<CategoryProvider>().loadCategories();
      await context.read<AttributeProvider>().loadAttributes();

      if (!mounted) return;

      if (widget.product != null) {
        _loadEditData();
      }
    });
  }

  // ================= CHECK IMAGE TYPE =================
  bool _isNetwork(String path) {
    return path.startsWith("http");
  }

  String _buildImageUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${AppConfig.apiUrl}/$path";
  }

  // ================= LOAD EDIT =================
  void _loadEditData() {
    final p = widget.product!;
    final attrProvider = context.read<AttributeProvider>();

    nameCtrl.text = p.name;
    brandCtrl.text = p.brand ?? "";
    descCtrl.text = p.description ?? "";
    selectedCategoryId = p.categoryId;

    final imageUrl =
        (p.image != null && p.image!.isNotEmpty)
            ? _buildImageUrl(p.image!)
            : null;

    images = imageUrl != null ? [imageUrl] : [];

    final Map<int, AttributeRow> map = {};

    for (var attr in attrProvider.attributes) {
      map[attr.id] = AttributeRow(
        attributeId: attr.id,
        attributeName: attr.name,
      );
    }

    attributeRows = map.values.toList();

    setState(() {});
  }

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        images.add(file.path);
      });
    }
  }

  // ================= IMAGE WIDGET =================
  Widget _buildImage(String path) {
    final isNetwork = _isNetwork(path);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child:
          isNetwork
              ? Image.network(path, width: 100, height: 100, fit: BoxFit.cover)
              : Image.file(
                File(path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
    );
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {
    final provider = context.read<ProductAdminProvider>();

    final dto = {
      "name": nameCtrl.text,
      "description": descCtrl.text,
      "brand": brandCtrl.text,
      "categoryId": selectedCategoryId,
      "variants": [],
    };

    /// chỉ gửi file local (không gửi URL)
    final localImages = images.where((e) => !_isNetwork(e)).toList();

    await provider.createProduct(dto: dto, imagePaths: localImages);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ================= INPUT =================
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

  @override
  void dispose() {
    nameCtrl.dispose();
    brandCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attrProvider = context.watch<AttributeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildAttributeSection(attrProvider),
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
                onPressed: _submit,
                child: const Text("Save Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= IMAGE SECTION =================
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
          const Text("Images"),
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
                  onTap: pickImage,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO =================
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(controller: nameCtrl, decoration: _input("Product Name")),
          const SizedBox(height: 10),
          TextField(controller: brandCtrl, decoration: _input("Brand")),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: _input("Description"),
          ),
        ],
      ),
    );
  }

  // ================= ATTRIBUTE =================
  Widget _buildAttributeSection(AttributeProvider attrProvider) {
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
            "Attributes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...attributeRows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: row.attributeId,
                      decoration: _input("Attribute"),
                      items:
                          attrProvider.attributes.map((attr) {
                            return DropdownMenuItem<int>(
                              value: attr.id,
                              child: Text(
                                attr.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                      onChanged: (id) {
                        final selected = attrProvider.attributes.firstWhere(
                          (e) => e.id == id,
                        );

                        setState(() {
                          row.attributeId = selected.id;
                          row.attributeName = selected.name;
                          row.value = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: row.value,
                      decoration: _input("Value"),
                      items:
                          (attrProvider.attributes
                                  .firstWhere(
                                    (e) => e.id == row.attributeId,
                                    orElse: () => attrProvider.attributes.first,
                                  )
                                  .values)
                              .map((val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(
                                    val,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              })
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          row.value = val;
                        });
                      },
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        attributeRows.remove(row);
                      });
                    },
                  ),
                ],
              ),
            );
          }),

          TextButton.icon(
            onPressed: () {
              setState(() {
                attributeRows.add(AttributeRow());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Attribute"),
          ),
        ],
      ),
    );
  }
}
